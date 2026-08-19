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

- `malamazainab2-release-aab` — Play Store bundle (AAB)
- `malamazainab2-release-apk` — signed release APK
- `malamazainab2-debug-apk` — debug APK

To create a GitHub release with the binaries, run the workflow manually
(workflow_dispatch) and pass a `release_tag` (e.g. `v1.0.0`).

## Package

`com.nakudin.malamazainabmuhadara2`

## Ads

- AdMob app ID: `ca-app-pub-9529770421530115~7791968877`
- Banner unit: `ca-app-pub-9529770421530115/9868251691`

## Release signing

The release keystore is stored as GitHub Actions secrets
(`KEYSTORE_BASE64`, `KEYSTORE_PASSWORD`, `KEY_ALIAS`, `KEY_PASSWORD`).
The keystore file itself is never committed to the repository.

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