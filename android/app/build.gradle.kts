import java.util.Properties

plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// ---------------------------------------------------------------------------
// Release signing
// ---------------------------------------------------------------------------
// Google Play rejects any APK/AAB that is signed with the Android debug key:
//   "You uploaded an APK or Android App Bundle that was signed in debug mode.
//    You need to sign your APK or Android App Bundle in release mode."
//
// So we NEVER fall back to the debug signing config any more. When no upload
// keystore is configured, a *release* build fails loudly instead of silently
// producing a debug-signed artifact (debug builds keep working as usual).
//
// Configure the keystore in android/key.properties (git-ignored — see
// android/key.properties.example):
//
//     storeFile=upload-keystore.jks   # path relative to android/app/
//     storePassword=...
//     keyAlias=upload
//     keyPassword=...
//     # storeType=pkcs12              # optional, auto-detected when omitted
//
// ...or through the environment variables STORE_FILE / STORE_PASSWORD /
// KEY_ALIAS / KEY_PASSWORD, which is what CI uses.
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.isFile && keystorePropertiesFile.length() > 0L) {
    keystorePropertiesFile.inputStream().use { keystoreProperties.load(it) }
}

fun signingValue(name: String): String? =
    (keystoreProperties.getProperty(name) ?: System.getenv(name))?.trim()?.takeIf { it.isNotEmpty() }

val signingStoreFile = signingValue("storeFile")
val signingStorePassword = signingValue("storePassword")
val signingKeyAlias = signingValue("keyAlias")
val signingKeyPassword = signingValue("keyPassword")
val signingStoreType = signingValue("storeType")

val missingSigningValues = mapOf(
    "storeFile" to signingStoreFile,
    "storePassword" to signingStorePassword,
    "keyAlias" to signingKeyAlias,
    "keyPassword" to signingKeyPassword,
).filterValues { it == null }.keys

/** True when the user asked for a release artifact (flutter build apk|appbundle --release). */
fun isReleaseBuildRequested(): Boolean =
    gradle.startParameter.taskNames.any { it.contains("release", ignoreCase = true) }

val signingHelpMessage: String = """
    |Release signing is not configured, so this build would be signed with the
    |Android DEBUG key and Google Play would reject it:
    |
    |  "You uploaded an APK or Android App Bundle that was signed in debug mode."
    |
    |Fix it (pick one):
    |  1. Local build : bash tools/create_release_keystore.sh
    |  2. GitHub CI   : set the repository secrets KEYSTORE_BASE64,
    |                   KEYSTORE_PASSWORD, KEY_ALIAS, KEY_PASSWORD
    |                   (Settings > Secrets and variables > Actions).
    |
    |See README.md > "Release signing".
""".trimMargin()

android {
    namespace = "com.nakudin.malamazainabmuhadara2"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.nakudin.malamazainabmuhadara2"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true
    }

    signingConfigs {
        if (missingSigningValues.isEmpty()) {
            create("release") {
                val uploadKeystore = file(signingStoreFile!!)
                if (!uploadKeystore.isFile) {
                    throw GradleException(
                        "Release keystore not found: ${uploadKeystore.absolutePath}\n" +
                            "Check 'storeFile' in android/key.properties — paths are relative to android/app/."
                    )
                }
                storeFile = uploadKeystore
                storePassword = signingStorePassword!!
                keyAlias = signingKeyAlias!!
                keyPassword = signingKeyPassword!!
                if (signingStoreType != null) {
                    storeType = signingStoreType!!
                }
            }
        }
    }

    buildTypes {
        release {
            if (missingSigningValues.isEmpty()) {
                signingConfig = signingConfigs.getByName("release")
            } else if (isReleaseBuildRequested()) {
                // Fail here rather than shipping a bundle Play Console will refuse.
                throw GradleException(signingHelpMessage)
            }
        }
    }
}

// Belt and braces: catch release packaging tasks even when the task names above
// are not what we expect (e.g. Gradle invoked through the tooling API).
gradle.taskGraph.whenReady {
    val packagesReleaseArtifact = allTasks.any { task ->
        val name = task.name
        name.startsWith("packageRelease", ignoreCase = true) ||
            name.startsWith("bundleRelease", ignoreCase = true) ||
            name.startsWith("assembleRelease", ignoreCase = true) ||
            name.startsWith("signRelease", ignoreCase = true)
    }
    if (packagesReleaseArtifact && missingSigningValues.isNotEmpty()) {
        throw GradleException(signingHelpMessage)
    }
}

dependencies {
    implementation("com.google.android.gms:play-services-ads:23.6.0")
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
