#! /bin/bash

set -o nounset
set -o errexit

BLACK='\e[30m'
RED='\e[31m'
GREEN='\e[32m'
YELLOW='\e[33m'
BLUE='\e[34m'
MAGENTA='\e[35m'
CYAN='\e[36m'
WHITE='\e[37m'
RESETCOLORS='\e[0m'


echo -e "${YELLOW}SMW Android build script${RESETCOLORS}"


# Read command line parameters
#
CONFIG_ABI='all'
CONFIG_DEBUG=0

for opt in "$@"; do
case $opt in
    --abi=*)
        CONFIG_ABI="${opt#*=}"
        shift
    ;;
    --debug)
        CONFIG_DEBUG=1
        shift
    ;;
    --help)
        echo -e "\nUsage: $0 [options]"
        echo "Options:"
        echo "  --debug          Build in debug mode instead of release"
        echo "                   Adds 'android:debuggable=true' to manifest"
        echo "                   and '-g' to compiler flags"
        echo "  --abi=ABILIST    Build for selected Android ABIs instead of 'all'"
        echo "                   Example: --abi='armeabi x86'"
        echo "                   See the NDK docs for supported values"
        echo -e "  --help           Display this information\n"
        exit
    ;;
    *) # unknown option
    ;;
esac
done


# Testing environment
#
echo -e "\n${YELLOW}Checking environment${RESETCOLORS}"

echo -e "- ${BLUE}target archs:${RESETCOLORS} ${CONFIG_ABI}"
echo -en "- ${BLUE}build mode:${RESETCOLORS} "
if [ $CONFIG_DEBUG -eq 1 ]; then
    echo "debug"
else
    echo "release"
fi
notfound=0
echo -en "- ${BLUE}android:${RESETCOLORS} "; which android || { echo -e "${RED}not found${RESETCOLORS}"; notfound=1; }
echo -en "- ${BLUE}android api-15:${RESETCOLORS} "
    { android list target --compact | grep -xq android-15 && echo "installed"; } || { echo -e "${RED}not installed${RESETCOLORS}"; notfound=1; }
echo -en "- ${BLUE}ndk-build:${RESETCOLORS} "; which ndk-build || { echo -e "${RED}not found${RESETCOLORS}"; notfound=1; }
echo -en "- ${BLUE}ant:${RESETCOLORS} "; which ant || { echo -e "${RED}not found${RESETCOLORS}"; notfound=1; }
echo -en "- ${BLUE}hg:${RESETCOLORS} "; which hg || { echo -e "${RED}not found${RESETCOLORS}"; notfound=1; }
echo -en "- ${BLUE}git:${RESETCOLORS} "; which git || { echo -e "${RED}not found${RESETCOLORS}"; notfound=1; }
if [ $notfound -ne 0 ]; then exit 1; fi


# Pulling base files
#
echo -e "\n${YELLOW}Preparing build directory${RESETCOLORS}"
if [ -e "android-project" ]; then
    echo -e "${RED}error${RESETCOLORS}: The 'android-project' directory already exists, delete it manually"
    exit 1
fi

echo -en "- ${BLUE}pulling SMW${RESETCOLORS}\n"
if [ -e "supermariowar" ]; then
    rm -rf supermariowar
fi
git clone --recursive --depth=1 https://github.com/mmatyas/supermariowar.git

echo -en "- ${BLUE}pulling SDL2${RESETCOLORS}\n"
if [ -e "SDL2" ]; then
    rm -rf SDL2
fi
hg clone http://hg.libsdl.org/SDL SDL2


# Setting up build directory
#
echo -en "- ${BLUE}setting up basic directory structure${RESETCOLORS}\n"
set -o xtrace
cp -R SDL2/android-project ./
mkdir -p android-project/jni
mv SDL2 android-project/jni/
set +o xtrace

cd android-project
echo -en "- ${BLUE}pulling SDL2 image and mixer${RESETCOLORS}\n"
hg clone http://hg.libsdl.org/SDL_image jni/SDL2_image
hg clone http://hg.libsdl.org/SDL_mixer jni/SDL2_mixer


# Setting up SMW files
#
echo -en "- ${BLUE}setting up the project${RESETCOLORS}\n"
set -o xtrace

# top level settings
android update project --name supermariowar --path . --target android-15
cp ../custom_files/AndroidManifest.xml ./
if [ $CONFIG_DEBUG -eq 1 ]; then
    sed -i 's/<application/<application android:debuggable="true"/' AndroidManifest.xml
fi

# SDLActivity
mkdir -p src/net/smwstuff/supermariowar
cp ../custom_files/MainActivity.java ./src/net/smwstuff/supermariowar/
# dependencies
mv ../supermariowar/dependencies/* jni/
mv ../supermariowar/src/{common,common_netplay,smw} jni/src/
# unnecessary files
rm jni/src/common/savepng.cpp
rm jni/src/smw/menu/MenuTemplate.cpp
rm -rf jni/src/smw/menu/xbox
# custom makefiles
cp ../custom_files/jni/Android.mk jni/
cp ../custom_files/jni/Application.mk jni/
cp ../custom_files/jni/enet.mk jni/enet/Android.mk
cp ../custom_files/jni/lz4.mk jni/lz4/Android.mk
cp ../custom_files/jni/yaml-cpp.mk jni/yaml-cpp-noboost/Android.mk
cp ../custom_files/jni/smw.mk jni/src/Android.mk

# custom config
sed -i "s/APP_ABI := all/APP_ABI := $CONFIG_ABI/" jni/Application.mk
if [ $CONFIG_DEBUG -eq 1 ]; then
    sed -i 's/ -O3 / -g /g' jni/src/Android.mk
fi
set +o xtrace


# Build!
#
echo -e "\n${YELLOW}Building${RESETCOLORS}"
ndk-build -j$(nproc)
ant debug
ant release

echo -e "\n${YELLOW}Done!${RESETCOLORS}"
