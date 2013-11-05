#!/bin/sh
set -e

cd AeroGear-iOS
pod install
xctool clean build test ONLY_ACTIVE_ARCH=NO

