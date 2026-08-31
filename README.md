# Malama Zainab Jaafar Muhadara 2

Offline audio Muhadara app for **Malama Zainab Jaafar**. Built with Flutter,
based on the Albaniy Zaria audio app template.

## Features

- 20 offline Muhadara lessons (~20 hours of audio) built into the app
- Auto-plays the next lesson (playlist mode)
- Resume from where you stopped — every lesson saves its position
- Background playback with lock-screen and notification controls
- Shuffle, loop, and seek controls
- AdMob banner ads (free app)

## Build

Android release artifacts are built automatically by GitHub Actions
(`.github/workflows/build.yml`) on every push to `main`:

- `malamazainab2-release-aab` — Play Store bundle (AAB), signed with the upload keystore
- `malamazainab2-release-apk` — signed release APK
- `malamazainab2-debug-apk` — debug APK (sideload/testing only — never upload it to Play)

To create a GitHub release with the binaries, run the workflow manually
(workflow_dispatch) and pass a `release_tag` (e.g. `v1.0.0`).

## Package

`com.nakudin.malamazainabmuhadara2`

## Ads

- AdMob app ID: `ca-app-pub-9529770421530115~7791968877`
- Banner unit: `ca-app-pub-9529770421530115/9868251691`

## Release signing (read this before building for Google Play)

Play Console rejects any binary signed with the Android debug key:

> You uploaded an APK or Android App Bundle that was signed in debug mode. You
> need to sign your APK or Android App Bundle in release mode.

Release builds are signed with an **upload keystore** that only you hold. If
`android/key.properties` is missing (locally) or the CI secrets are not set, the
release build **fails with an error** — it never silently falls back to the
debug key and produces a bundle Play will refuse.

### 1. Create the upload keystore (once)

```bash
bash tools/create_release_keystore.sh
```

It creates `android/app/upload-keystore.jks`, writes `android/key.properties`
(both git-ignored) and prints exactly what to paste in as GitHub secrets.

**Back up the keystore file and both passwords** (password manager + an offline
copy). With Play App Signing a lost upload key *can* be reset, but Google asks
for proof of identity and it takes days. Without it, the keystore is
unrecoverable from this repository — it is deliberately git-ignored.

Already have a keystore from another app? You can reuse it: copy it to
`android/app/`, write `android/key.properties` using
`android/key.properties.example`, then run
`bash tools/create_release_keystore.sh --export` to print the secrets.

### 2. Add the secrets for GitHub Actions

Settings → Secrets and variables → Actions → New repository secret:

| Secret | Value |
| --- | --- |
| `KEY_ALIAS` | key alias, e.g. `upload` |
| `KEYSTORE_PASSWORD` | keystore (store) password |
| `KEY_PASSWORD` | key password |
| `KEYSTORE_BASE64` | `base64 -w0 android/app/upload-keystore.jks` |

The workflow decodes the keystore, checks it opens with those passwords, builds,
and then verifies both artifacts are **not** debug-signed. Missing secrets stop
the job with an error rather than uploading a bundle Play Console will reject.

### 3. Build and check locally

```bash
flutter build appbundle --release
bash tools/verify_release_signing.sh build/app/outputs/bundle/release/app-release.aab
```

The verifier prints the signing certificate (Owner + SHA-1/SHA-256) and exits
non-zero if the artifact is signed with `CN=Android Debug`. Compare the SHA-1
with the **upload certificate** shown in Play Console → Setup → App signing.

### Troubleshooting

- **"signed in debug mode"** — the uploaded bundle was built without the
  keystore configured. Configure signing, bump `version` in `pubspec.yaml`
  (`1.0.0+1` → `1.0.1+2`), rebuild, and upload the new AAB. A rejected upload
  does not block a fresh one.
- **`Release signing is not configured`** (Gradle error) — provide
  `android/key.properties`, or export `STORE_FILE`, `STORE_PASSWORD`,
  `KEY_ALIAS`, `KEY_PASSWORD` in the environment.
- **"Your Android App Bundle is signed with the wrong key"** — you signed with a
  key that is not the one registered in Play Console. Use the original upload
  keystore, or request an upload-key reset (only possible with Play App Signing).

## Local build

```bash
flutter pub get
flutter test
flutter analyze
flutter build appbundle --release   # requires android/key.properties
```

## Audio

Source mp3s live in `source_media/`. Bundled audio in `assets/audio/` is
converted to Opus (6 kbps, mono, 16 kHz) to keep the app small
(~59 MB total audio for ~20 hours).