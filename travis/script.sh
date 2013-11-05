#!/bin/sh
set -e

pod install
cd AeroGear-iOS
xctool clean build test ONLY_ACTIVE_ARCH=NO

