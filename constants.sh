#!/bin/bash
#title:           constants.sh
#description:
#   This script is part of toolchain utils.
#author:          rubeniskov <dev@rubeniskov.com>
#date:            2018-04-18
#version:         0.1
#bash_version:    3.2.57(1)-release
#==============================================================================

TOOLCHAIN_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
TOOLCHAIN_PATH=${TOOLCHAIN_PATH:="$TOOLCHAIN_DIR"}
TOOLCHAIN_DEST_DIR=${TOOLCHAIN_DEST_DIR:="$TOOLCHAIN_PATH/toolchains"}
TOOLCHAIN_CACHE_DIR=${TOOLCHAIN_CACHE_DIR:="$TOOLCHAIN_PATH/cache"}
TOOLCHAIN_RELEASES_URL=${TOOLCHAIN_RELEASES_URL:="https://releases.linaro.org/components/toolchain/binaries"}
TOOLCHAIN_GNU_BINARIES=( "getopt" )
TOOLCHAIN_BASH_BINARIES=( "sort" "awk" "cut" "grep" "cut" "head" "tail")
TOOLCHAIN_THIRD_PARTY_BINARIES=( "curl" )
