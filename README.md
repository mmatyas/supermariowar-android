SMW on Android
==============

This repository contains build scripts and makefiles for the Android port of [Super Mario War](https://github.com/mmatyas/supermariowar).

This port is experimental and not yet ready to play. The game currently requires at least Android 4.0.3 (API 15), and uses SDL2.

## Requirements

- Android [SDK](https://developer.android.com/sdk/index.html#Other) and [NDK](https://developer.android.com/ndk/index.html), preferably the latest available. Make sure `android` and `ndk-build` is in your `PATH`.
- Android 4.0.3 (API 15) SDK platform (you can install it with `android`)
- Ant (eg. `sudo apt-get install ant`)
- Mercurial (eg. `sudo apt-get install mercurial`), used for pulling SDL sources

## Building instructions

Just run `build.sh`, it will check if the tools are available, pull the SMW source code, get the dependencies, then set up and build the project.
