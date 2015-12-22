SMW on Android
==============

This repository contains build scripts and makefiles for the Android port of [Super Mario War](https://github.com/mmatyas/supermariowar).

This port is experimental and not yet ready to play. The game currently requires at least Android 4.0.3 (API 15), and uses SDL2.

## Requirements

- Android [SDK](https://developer.android.com/sdk/index.html#Other) and [NDK](https://developer.android.com/ndk/index.html), preferably the latest available. Make sure `android` and `ndk-build` is in your `PATH`.
- Android 4.0.3 (API 15) SDK platform (you can install it with `android`)
- Ant (eg. `sudo apt-get install ant`)
- Git (eg. `sudo apt-get install git`)
- wget (most likely you already have it), for pulling SDL2 sources

## Building instructions

Just run `build.sh`, it will check if the tools are available, pull the SMW source code, get the dependencies, then set up and build the project. By default, it builds in Release mode for all platform supported by the NDK; use `--help` to see the optional parameters.

## Debugging

Make sure you've run the build with `--debug`. Connect your Android device, or start the emulator, then

```
adb push supermariowar/data /sdcard/supermariowar/
cd android-project
ant installd
ndk-gdb --start --verbose
```

In some NDK versions you can get errors about a missing gdb.setup file, even in debug build. You can fix this by simply copying or linking the gdb files to `android-project/libs`, eg.:

```
cd libs
ln -s armeabi/gdbserver
ln -s armeabi/gdb.setup
```
