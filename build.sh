#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "$0")" && pwd)"
project="${SMW_BUILD_DIR:-$root/android-project}"
abi=arm64-v8a
variant=Release

for option in "$@"; do
    case "$option" in
        --abi=*) abi="${option#*=}" ;;
        --debug) variant=Debug ;;
        --help)
            echo "Usage: $0 [--debug] [--abi=arm64-v8a]"
            exit 0 ;;
        *) echo "Unknown option: $option" >&2; exit 1 ;;
    esac
done

if [[ ! -f "$root/third_party/SDL/android-project/app/build.gradle" || ! -f "$root/game/CMakeLists.txt" || ! -d "$root/game/data/maps" ]]; then
    echo "Initialize submodules first: git submodule update --init --recursive" >&2
    exit 1
fi
if [[ -e "$project" ]]; then
    echo "Build directory already exists: $project" >&2
    exit 1
fi

cp -R "$root/third_party/SDL/android-project" "$project"
mkdir -p "$project/app/jni/SDL" "$project/app/jni/game" "$project/app/src/main/assets/data"
git -C "$root/third_party/SDL" archive HEAD | tar -xf - -C "$project/app/jni/SDL"
git -C "$root/game" archive HEAD | tar -xf - -C "$project/app/jni/game"
git -C "$root/game/data" archive HEAD | tar -xf - -C "$project/app/src/main/assets/data"
git -C "$root/game/data" rev-parse HEAD > "$project/app/src/main/assets/smw-assets-version.txt"

cp "$root/custom_files/jni/CMakeLists.txt" "$project/app/jni/CMakeLists.txt"
cp "$root/custom_files/AndroidManifest.xml" "$project/app/src/main/AndroidManifest.xml"
mkdir -p "$project/app/src/main/java/net/smwstuff/supermariowar"
cp "$root/custom_files/MainActivity.java" "$project/app/src/main/java/net/smwstuff/supermariowar/MainActivity.java"
cp "$root/custom_files/GameActivity.java" "$project/app/src/main/java/net/smwstuff/supermariowar/GameActivity.java"
cp "$root/custom_files/game.gradle" "$project/app/game.gradle"
cp -R "$root/custom_files/res/." "$project/app/src/main/res/"
echo "apply from: 'game.gradle'" >> "$project/app/build.gradle"
cmake_bin="$(command -v cmake)"
printf 'cmake.dir=%s\n' "$(dirname "$(dirname "$cmake_bin")")" > "$project/local.properties"

cd "$project"
./gradlew -PBUILD_WITH_CMAKE "-PSMW_ABI=$abi" "assemble$variant"
