#!/bin/bash
#title:           ls-local.sh
#description:
#   This script is part of toolchain utils.
#author:          rubeniskov <dev@rubeniskov.com>
#date:            2018-04-18
#version:         0.1
#bash_version:    3.2.57(1)-release
#==============================================================================

source './common.sh'

#output:
# 6.1.1 2016.08 x86_64 aarch64-linux-gnu
# 6.2.1 2016.11 x86_64 aarch64-linux-gnu
toolchain_ls_local(){
  ls $TOOLCHAIN_DEST_DIR|\
    sed s/gcc-linaro-// |\
    awk -F- '{split($3"-"$4"-"$5,a,"_"); printf "%s %s %s_%s %s\n",$1,$2,a[1],a[2],a[3]}'
}


toolchain_ls_local_versions(){
  toolchain_ls_local |\
    awk '{printf "%s %s\n",$1,$2}' |\
    # SORT
    sort -n |\
    # GROUP BY VERSION
    awk '{arr[$1]=arr[$1]" "$2} END {for (i in arr) {print i,arr[i]}}' |\
    # CLEAN SPACES
    sed 's/  / /' |\
    # FILTER BY VERSION
    ( [[ "${1}" ]] && grep -w "${1}" || cat ) |\
    # FILTER BY REVISION
    ( [[ "${2}" ]] && grep -w "${2}" || cat )
}

toolchain_ls_local_targets(){
  if [[ -z $1 ]]; then
      echo "Error version arguments is required"
      return 1
  fi
  toolchain_ls_local |\
    # FILTER BY VERSION
    grep -w "${1}" |\
    # FILTER BY REVISION
    ( [[ "${2}" ]] && grep -w "${2}" || cat ) |\
    awk '{print $4}'
}
