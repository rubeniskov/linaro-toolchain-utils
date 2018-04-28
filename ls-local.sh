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

ltu_ls_local(){
  ltu_get_local_toolchains |\
  ltu_filter_host_arch $* |\
  ltu_filter_latest $* |\
  ltu_filter_brief $* |\
  ltu_filter_grep $*
}

ltu_get_local_files() {
  mkdir -p $LTU_DEST_DIR && ls $LTU_DEST_DIR |\
  awk -v base_uri=$LTU_DEST_DIR '{print base_uri"/"$0}'
}

ltu_get_local_toolchains(){
  ltu_get_local_files |\
  ltu_parse_toolchain
}
