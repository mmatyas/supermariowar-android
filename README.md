# Super Mario War for Android

This repository assembles the Android app from SDL3's maintained `android-project` template. `build.sh` copies the template into an ignored build directory, then adds the pinned Super Mario War source, game data, and the small set of Android-specific files under `custom_files`.

The pinned game revision provides the SDL3 port and CMake source lists. SDL3 is pinned to release 3.4.8; the game pins SDL3_image 3.4.4 and SDL3_mixer 3.2.2.

## Build

Install Android SDK platform 35, NDK 29.0.14206865, CMake 3.24 or newer, Ninja, and JDK 17 or newer. Set `ANDROID_HOME` to the SDK directory and put `cmake` on `PATH`. Then initialize submodules:

```sh
git submodule update --init --recursive
./build.sh --debug
```

The debug APK is `android-project/app/build/outputs/apk/debug/app-debug.apk`. Use `./build.sh` for an unsigned release build; `--abi=arm64-v8a` selects the native ABI and defaults to ARM64. The script stops if `android-project` already exists. Remove that generated directory before another build.

The app targets Android API 35 and retains SDL's API 21 minimum. It packages `game/data` inside the APK and copies it to app-private storage on first launch. Existing installations copy updated packaged assets when the pinned data revision changes. User-created files remain in place.

The debug APK uses the local Android debug signing key and is intended for testing. The game has no Android storage permission or manual `adb push` step.
