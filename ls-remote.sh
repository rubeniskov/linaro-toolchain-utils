#!/bin/bash
#title:           ls-remote.sh
#description:
#   This script is part of toolchain utils.
#author:          rubeniskov <dev@rubeniskov.com>
#date:            2018-04-18
#version:         0.1
#bash_version:    3.2.57(1)-release
#==============================================================================

source './common.sh'

ltu_ls_remote() {
  ltu_get_remote_toolchains |\
  ltu_filter_host_arch $* |\
  ltu_filter_latest $* |\
  ltu_filter_brief $* |\
  ltu_filter_grep $*
}

ltu_get_remote_toolchains() {
  local cache_file="${LTU_CACHE_DIR}/.ltu_cache_remote"
  local time_since_modify=$(ltu_time_since_file_modified ${cache_file})
  ([[ $time_since_modify -lt $((86400 * 7)) ]] &&
      (cat "${cache_file}") ||
      (ltu_get_from_url -s "$LTU_RELEASE_LINKS_URL" | ltu_cache_results "${cache_file}")) |\
  ltu_parse_toolchain
}
