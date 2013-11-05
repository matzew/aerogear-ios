#!/bin/sh
set -e

xctool clean build test ONLY_ACTIVE_ARCH=NO

