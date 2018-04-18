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

toolchain_ls_remote_versions(){
  local cache_file="${TOOLCHAIN_CACHE_DIR}/.toolchain_cache_versions"
  local time_since_modify=$(toolchain_time_since_modified ${cache_file})

  ([[ $time_since_modify -lt 36000 ]] &&
      (cat "${cache_file}") ||
      (curl -s "${TOOLCHAIN_RELEASES_URL}/" |\
      # OBTAIN VERSIONS
      sed -n 's/.*href="\/components\/toolchain\/binaries\/\([^"]*\)\/.*/\1/p' |\
      # FILTER LATEST
      grep -v latest |\
      # SORT
      sort -n |\
      # SPLIT VERSION AND REVISION
      sed 's/-/ /' |\
      # GROUP BY VERSION
      awk '{arr[$1]=arr[$1]" "$2} END {for (i in arr) {print i,arr[i]}}'|\
      # CLEAN SPACES
      sed 's/  / /' |\
      # SAVE FILE AND GET OUTPUT
      toolchain_cache_results "${cache_file}")) |\
      # FILTER BY VERSION
      ( [[ "${1}" ]] && grep -w "${1}" || cat ) |\
      # FILTER BY REVISION
      ( [[ "${2}" ]] && grep -w "${2}" || cat )
}

toolchain_ls_remote_targets(){
  local version=${1:-"latest"}
  local revision=${2}
  if [[ -z $revision ]] && [[ $version != "latest" ]]; then
      echo "Error revision arguments is required" 
      return 1
  fi
  local cache_file="${TOOLCHAIN_CACHE_DIR}/.toolchain_cache_targets_${version}_${revision}"
  local time_since_modify=$(toolchain_time_since_modified ${cache_file})

  ([[ $time_since_modify -lt 36000 ]] &&
      (cat "${cache_file}") ||
      (curl -s "${TOOLCHAIN_RELEASES_URL}/$([[ -n $revision ]] && echo "${version}-${revision}" || echo "${version}")/" |\
      # OBTAIN VERSIONS
      sed -n 's/.*href="\/components\/toolchain\/binaries\/\([^"]*\)\/.*/\1/p' |\
      # PARSE SPLIT NAME
      awk 'function basename(file, a, n) {
            n = split(file, a, "/")
          return a[n]
        }
        {print basename($1)}' |\
      # SAVE FILE AND GET OUTPUT
      toolchain_cache_results "${cache_file}"))
}
