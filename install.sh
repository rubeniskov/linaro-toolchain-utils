#!/bin/bash
#title:           install.sh
#description:
#   This script is part of toolchain utils.
#author:          rubeniskov <dev@rubeniskov.com>
#date:            2018-04-18
#version:         0.1
#bash_version:    3.2.57(1)-release
#usage:           ./install.sh <version/s> [options]
#ex: ltu_install 6.3
#==============================================================================

source "./common.sh"
source "./download.sh"
source "./unpack.sh"
# $app_name install $(toolchain_ls_remote_versions|awk '{print $1}'|tail -n 3|tr "\n" " ")
# $app_name install $(toolchain_ls_remote_versions|awk '{print $1}'|head -n 1) --arch_type=$(toolchain_ls_remote_targets|head -n 1)
ltu_install_usage() {
  local app_name=$(basename $0)
cat <<EOF
Usage: $app_name install [version/s] <options>

  Example
    $app_name install 7.2 elf
    $app_name install 4.9 elf

  Options
    $app_name install --help:               Display this usage

  Versions


  Arch Types

EOF
}

ltu_install() {

    local destination="${LTU_DEST_DIR}"
    local opts=$(ltu_exec getopt \
            --options :h \
            --long help \
            --name 'toolchain install' -- "$@")

    eval set -- "$opts"
    while true; do
        case "${1}" in
            --)
                pattern="${@:2}"
                break
                ;;
            -h|--help|*)
                ltu_install_usage install
                exit 1
                ;;
        esac
    done

    ltu_download ${pattern} --latest |\
    while read -r file; do
      ltu_unpack $(echo $file | awk '{print $6}') ${destination}
    done

    return 0
}


# local versions=$(toolchain_ls_remote_versions|awk '{print $1}'|tail -n 1)
# local arch_type=$(toolchain_ls_remote_targets|awk '{print $1}'|tail -n 1)
# local host_arch="$(uname -m)"
# local destination="${TOOLCHAIN_PATH}"
# local workdir="/tmp"
# local revision

# files=$(ltu_download ${pattern})
# for (( i=0; i<${files[@]} ; i+=2 )) ; do
#     echo "${files[i]}" |awk '{print $6}'
#     #tar=$(echo "${files[i]}"|awk '{print $6}')
#     #asc=$(echo "${files[i+1]}"|awk '{print $6}')
# done
#
# | awk '{
#   printf("%s\n%s.asc\n", $0, $0)
# }'
