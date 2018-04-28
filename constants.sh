#!/bin/bash
#title:           constants.sh
#description:
#   This script is part of toolchain utils.
#author:          rubeniskov <dev@rubeniskov.com>
#date:            2018-04-18
#version:         0.1
#bash_version:    3.2.57(1)-release
#==============================================================================

LTU_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
LTU_PATH=${LTU_PATH:="$LTU_DIR"}
LTU_DEST_DIR=${LTU_DEST_DIR:="$LTU_PATH/toolchains"}
LTU_CACHE_DIR=${LTU_CACHE_DIR:="$LTU_PATH/cache"}
LTU_RELEASE_LINKS_URL=${LTU_RELEASE_LINKS_URL:="https://gist.githubusercontent.com/rubeniskov/d5c04095c41076c4dfe5273015c9a871/raw"}
LTU_GNU_BINARIES=( "getopt" )
LTU_BASH_BINARIES=( "sort" "awk" "cut" "grep" "cut" "head" "tail")
LTU_THIRD_PARTY_BINARIES=( "curl" )
