#!/bin/sh
set -e

cd AeroGear-iOS
xctool clean build test ONLY_ACTIVE_ARCH=NO

