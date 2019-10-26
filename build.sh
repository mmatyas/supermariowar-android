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
        echo "                   Possible values: armeabi, armeabi-v7a, arm64-v8a,"
        echo "                                    x86, x86_64, mips, mips64"
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
echo -en "- ${BLUE}android api-26:${RESETCOLORS} "
    { android list target --compact | grep -xq android-26 && echo "installed"; } || { echo -e "${RED}not installed${RESETCOLORS}"; notfound=1; }
echo -en "- ${BLUE}ndk-build:${RESETCOLORS} "; which ndk-build || { echo -e "${RED}not found${RESETCOLORS}"; notfound=1; }
echo -en "- ${BLUE}ant:${RESETCOLORS} "; which ant || { echo -e "${RED}not found${RESETCOLORS}"; notfound=1; }
echo -en "- ${BLUE}git:${RESETCOLORS} "; which git || { echo -e "${RED}not found${RESETCOLORS}"; notfound=1; }
echo -en "- ${BLUE}wget:${RESETCOLORS} "; which wget || { echo -e "${RED}not found${RESETCOLORS}"; notfound=1; }
if [ $notfound -ne 0 ]; then exit 1; fi


# Pulling base files
#
echo -e "\n${YELLOW}Preparing build directory${RESETCOLORS}"
if [ -e "android-project-ant" ]; then
    echo -e "${RED}error${RESETCOLORS}: The 'android-project-ant' directory already exists, delete it manually"
    exit 1
fi

# Pull SMW
echo -en "- ${BLUE}checking SMW... "
if [ ! -d "supermariowar" ]; then
    echo -e "cloning${RESETCOLORS}"
    rm -rf supermariowar
    git clone --recursive --depth=1 https://github.com/mmatyas/supermariowar.git
else
    echo -e "ok${RESETCOLORS}"
fi

# Download SDL2
echo -e "- ${BLUE}checking SDL2${RESETCOLORS}"
if [ ! -f "SDL2.tar.gz" ] && [ ! -d "SDL2" ]; then
    echo -e "  - ${BLUE}pulling core${RESETCOLORS}"
    wget https://hg.libsdl.org/SDL/archive/default.tar.gz -O SDL2.tar.gz
else
    echo -e "  - ${BLUE}core ok${RESETCOLORS}"
fi
# Extract SDL2
if [ ! -d "SDL2" ]; then
    mkdir SDL2-tmp # in case tar fails
    tar xzf SDL2.tar.gz -C SDL2-tmp --strip-components=1
    mv SDL2-tmp SDL2
fi
# Download SDL2_image
if [ ! -f "SDL2_image.tar.gz" ]; then
    echo -e "  - ${BLUE}pulling image${RESETCOLORS}"
    wget https://hg.libsdl.org/SDL_image/archive/default.tar.gz -O SDL2_image.tar.gz
else
    echo -e "  - ${BLUE}image ok${RESETCOLORS}"
fi
# Download SDL2_mixer
if [ ! -f "SDL2_mixer.tar.gz" ]; then
    echo -e "  - ${BLUE}pulling mixer${RESETCOLORS}"
    wget https://hg.libsdl.org/SDL_mixer/archive/default.tar.gz -O SDL2_mixer.tar.gz
else
    echo -e "  - ${BLUE}mixer ok${RESETCOLORS}"
fi


# Setting up build directory
#
echo -e "- ${BLUE}setting up basic directory structure${RESETCOLORS}"
set -o xtrace
cp -RL SDL2/android-project-ant ./
mkdir -p android-project-ant/jni
cp -RL SDL2 android-project-ant/jni/
set +o xtrace

echo -e "- ${BLUE}pulling SDL2 image and mixer${RESETCOLORS}"
cd android-project-ant
mkdir jni/SDL2_image
mkdir jni/SDL2_mixer
tar xzf ../SDL2_image.tar.gz -C jni/SDL2_image --strip-components=1
tar xzf ../SDL2_mixer.tar.gz -C jni/SDL2_mixer --strip-components=1


# Setting up SMW files
#
echo -e "- ${BLUE}setting up the project${RESETCOLORS}"
set -o xtrace

# top level settings
android update project --name supermariowar --path . --target android-26
cp ../custom_files/AndroidManifest.xml ./
if [ $CONFIG_DEBUG -eq 1 ]; then
    sed -i 's/<application/<application android:debuggable="true"/' AndroidManifest.xml
fi

# SDLActivity
mkdir -p src/net/smwstuff/supermariowar
cp ../custom_files/MainActivity.java ./src/net/smwstuff/supermariowar/
# dependencies
cp -R ../supermariowar/dependencies/* jni/
cp -R ../supermariowar/src/{common,common_netplay,smw} jni/src/
# unnecessary files
rm jni/src/common/savepng.cpp
rm jni/src/smw/menu/MenuTemplate.cpp
rm -rf jni/src/smw/menu/xbox
# custom makefiles
cp ../custom_files/jni/Android.mk jni/
cp ../custom_files/jni/Application.mk jni/
cp ../custom_files/jni/enet.mk jni/enet/Android.mk
cp ../custom_files/jni/yaml-cpp.mk jni/yaml-cpp-noboost/Android.mk
cp ../custom_files/jni/smw.mk jni/src/Android.mk
# custom icons and resources
rm -rf res
cp -R ../custom_files/res ./

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
