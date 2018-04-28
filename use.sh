#!/bin/bash
#title:           use.sh
#description:
#   This script is part of toolchain utils.
#author:          rubeniskov <dev@rubeniskov.com>
#date:            2018-04-18
#version:         0.1
#bash_version:    3.2.57(1)-release
#usage:           ./use.sh <version> [options]
#ex: toolchain_use 6.3
#==============================================================================

source "./common.sh"
source "./ls.sh"

ltu_use() {
    local target=$(ltu_ls --local -q -a $@)
    local count=$(echo "${target}"|wc -l)

    if [[ -z "$target" ]];then
        ltu_log "err" "No matches for this pattern" "$1"
        return 1
    fi

    if [ "$count" -gt 1 ]; then
        ltu_log "wrn" "Multiple choices for this pattern" "$1"
        echo "$target"|awk '{printf(" -> %s\n", $0)}'
        return 1
    fi

    ltu_log "info" "Using" "$target)"

    LTU_TARGET=$(echo "${target}"|ltu_format_local_toolchain)
    LTU_CROSS_COMPILE="$(echo "${target}"|awk '{print $4}')-"

    # store original PATH and LD_LIBRARY_PATH
    if [[ -z ${PATH_ORIGIN+x} ]]; then export PATH_ORIGIN=${PATH}; fi
    if [[ -z ${LD_LIBRARY_PATH_ORIGIN+x} ]]; then export LD_LIBRARY_PATH_ORIGIN=${LD_LIBRARY_PATH}; fi

    # configure environment
    if [[ -n "${LTU_TARGET}" ]]; then
        export ARCH=arm
        export CROSS_COMPILE=${LTU_CROSS_COMPILE}
        export LTU_ROOT="${LTU_DEST_DIR}/${LTU_TARGET}"
        export PATH="${LTU_ROOT}/bin:${PATH_ORIGIN}"
        export LD_LIBRARY_PATH="${LTU_ROOT}/lib:${LD_LIBRARY_PATH_ORIGIN}"
        printenv | grep --color -E -w 'ARCH|CROSS_COMPILE|LTU_ROOT|PATH|LD_LIBRARY_PATH'
    fi
}
