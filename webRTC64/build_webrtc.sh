#!/bin/bash
# Script to build WebRTC.framework for iOS
# Copyright (C) 2015 戴维营教育  - All Rights Reserved
# Last revised 28/1/2015
#

function build_iossim_ia32() {
    echo "*** building WebRTC for the ia32 iOS simulator";
    export GYP_GENERATORS="ninja";
    export GYP_DEFINES="build_with_libjingle=1 build_with_chromium=0 libjingle_objc=1 OS=ios target_arch=ia32";
    export GYP_GENERATOR_FLAGS="$GYP_GENERATOR_FLAGS output_dir=out_ios_ia32";
    export GYP_CROSSCOMPILE=1;
    pushd src;
    gclient runhooks;
    ninja -C out_ios_ia32/Release-iphonesimulator iossim AppRTCDemo;

    echo "*** creating iOS ia32 libraries";
    pushd out_ios_ia32/Release-iphonesimulator/;
    rm -f  libapprtc_signaling.a;
    popd;
    mkdir -p out_ios_ia32/libs;
    libtool -static -o out_ios_ia32/libs/libWebRTC-ia32.a out_ios_ia32/Release-iphonesimulator/lib*.a;
    strip -S -x -o out_ios_ia32/libs/libWebRTC.a -r out_ios_ia32/libs/libWebRTC-ia32.a;
    rm -f out_ios_ia32/libs/libWebRTC-ia32.a;
    echo "*** result: $PWD/out_ios_ia32/libs/libWebRTC.a";

    popd;
}

function build_iossim_x86_64() {
    echo "*** building WebRTC for the x86_64 iOS simulator";
    export GYP_GENERATORS="ninja";
    export GYP_DEFINES="build_with_libjingle=1 build_with_chromium=0 libjingle_objc=1 OS=ios target_arch=x64 target_subarch=arm64";
    export GYP_GENERATOR_FLAGS="$GYP_GENERATOR_FLAGS output_dir=out_ios_x86_64";
    export GYP_CROSSCOMPILE=1;
    pushd src;
    gclient runhooks;
    ninja -C out_ios_x86_64/Release-iphonesimulator iossim AppRTCDemo;

    echo "*** creating iOS x86_64 libraries";
    pushd out_ios_x86_64/Release-iphonesimulator/;
    rm -f  libapprtc_signaling.a;
    popd;
    mkdir -p out_ios_x86_64/libs;
    libtool -static -o out_ios_x86_64/libs/libWebRTC-x86_64.a out_ios_x86_64/Release-iphonesimulator/lib*.a;
    strip -S -x -o out_ios_x86_64/libs/libWebRTC.a -r out_ios_x86_64/libs/libWebRTC-x86_64.a;
    echo "*** result: $PWD/out_ios_x86_64/libs/libWebRTC.a";

    popd;
}

function build_iosdevice_armv7() {
    echo "*** building WebRTC for armv7 iOS devices";
    export GYP_GENERATORS="ninja";
    export GYP_DEFINES="build_with_libjingle=1 build_with_chromium=0 libjingle_objc=1 OS=ios target_arch=armv7";
    export GYP_GENERATOR_FLAGS="$GYP_GENERATOR_FLAGS output_dir=out_ios_armv7";
    export GYP_CROSSCOMPILE=1;
    pushd src;
    gclient runhooks;
    ninja -C out_ios_armv7/Release-iphoneos AppRTCDemo;

    echo "*** creating iOS armv7 libraries";
    pushd out_ios_armv7/Release-iphoneos/;
    rm -f  libapprtc_signaling.a;
    popd;
    mkdir -p out_ios_armv7/libs;
    libtool -static -o out_ios_armv7/libs/libWebRTC-armv7.a out_ios_armv7/Release-iphoneos/lib*.a;
    strip -S -x -o out_ios_armv7/libs/libWebRTC.a -r out_ios_armv7/libs/libWebRTC-armv7.a;
    echo "*** result: $PWD/out_ios_armv7/libs/libWebRTC.a";

    popd;
}

function build_iosdevice_arm64() {
    echo "*** building WebRTC for arm64 iOS devices";
    export GYP_GENERATORS="ninja";
    export GYP_DEFINES="build_with_libjingle=1 build_with_chromium=0 libjingle_objc=1 OS=ios target_arch=arm64 target_subarch=arm64";
    export GYP_GENERATOR_FLAGS="$GYP_GENERATOR_FLAGS output_dir=out_ios_arm64";
    export GYP_CROSSCOMPILE=1;
    pushd src;
    gclient runhooks;
    ninja -C out_ios_arm64/Release-iphoneos AppRTCDemo;

    echo "*** creating iOS arm64 libraries";
    pushd out_ios_arm64/Release-iphoneos/;
    rm -f  libapprtc_signaling.a;
    popd;
    mkdir -p out_ios_arm64/libs;
    libtool -static -o out_ios_arm64/libs/libWebRTC-arm64.a out_ios_arm64/Release-iphoneos/lib*.a;
    strip -S -x -o out_ios_arm64/libs/libWebRTC.a -r out_ios_arm64/libs/libWebRTC-arm64.a;
    echo "*** result: $PWD/out_ios_arm64/libs/libWebRTC.a";

    popd;
}

function combine_libs() 
{
    echo "*** combining libraries";
    lipo  -create   src/out_ios_ia32/libs/libWebRTC.a \
            src/out_ios_x86_64/libs/libWebRTC.a \
            src/out_ios_armv7/libs/libWebRTC.a \
            src/out_ios_arm64/libs/libWebRTC.a \
            -output libWebRTC.a;
    echo "The public headers are located in $PWD/src/talk/app/webrtc/objc/public/*.h";
}

function create_framework() {
    echo "*** creating WebRTC.framework";
    rm -rf WebRTC.framework;
    mkdir -p WebRTC.framework/Versions/A/Headers;
    cp ./src/talk/app/webrtc/objc/public/*.h WebRTC.framework/Versions/A/Headers;
    cp libWebRTC.a WebRTC.framework/Versions/A/WebRTC;

    pushd WebRTC.framework/Versions;
    ln -sfh A Current;
    popd;
    pushd WebRTC.framework;
    ln -sfh Versions/Current/Headers Headers;
    ln -sfh Versions/Current/WebRTC WebRTC;
    popd;
}

function clean() 
{
    echo "*** cleaning";
    pushd src;
    rm -rf out_ios_arm64 out_ios_armv7 out_ios_ia32 out_ios_x86_64;
    popd;
    echo "*** all cleaned";
}

function update()
{
    gclient sync --force
    pushd src
    svn info | grep Revision > ../svn_rev.txt
    popd
}

function build_all() {
    build_iossim_ia32 && build_iossim_x86_64 && \
    build_iosdevice_armv7 && build_iosdevice_arm64 && \
    combine_libs && create_framework;
}

function run_simulator_ia32() {
    echo "*** running webrtc appdemo on ia32 iOS simulator";
    src/out_ios_ia32/Release-iphonesimulator/iossim src/out_ios_ia32/Release-iphonesimulator/AppRTCDemo.app;
}

function run_simulator_x86_64() {
    echo "*** running webrtc appdemo on x86_64 iOS simulator";
    src/out_ios_x86_64/Release-iphonesimulator/iossim -d 'iPhone 6' -s '8.1'  src/out_ios_x86_64/Release-iphonesimulator/AppRTCDemo.app;
}

function run_on_device_armv7() {
    echo "*** launching on armv7 iOS device";
    ideviceinstaller -i src/out_ios_armv7/Release-iphoneos/AppRTCDemo.app;
    echo "*** launch complete";
}

function run_on_device_arm64() {
    echo "*** launching on arm64 iOS device";
    ideviceinstaller -i src/out_ios_arm64/Release-iphoneos/AppRTCDemo.app;
    echo "*** launch complete";
}

#运行命令行参数中第一个参数所指定的Shell函数
$@
