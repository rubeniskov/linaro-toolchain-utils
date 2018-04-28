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

# ltu_get_remote_versions() {
#   ltu_log "prg" "Loading remote versions" "ᕙ(ಡ_ಡ)"
#   ltu_get_from_url -s "${LTU_RELEASES_URL}/" |\
#   ltu_parse_html_links |\
#   awk -F"/" '/^\/components\/toolchain\/binaries\//{ print $5 }'|\
#   ltu_filter_version
# }
#
# ltu_get_remote_targets() {
#   local version
#   cat - | while read -r args; do
#       version=${args[0]:-latest}
#       ltu_log "prg" "Loading remote targets" "ᕙ(ಠ_ಠ)ᕗ" "${version}"
#       ltu_get_from_url -s "${LTU_RELEASES_URL}/${version}/" |\
#       ltu_parse_html_links |\
#       awk -F"/" -v version=$version '/^\/components\/toolchain\/binaries\/.*\//{ print version" "$6 }'
#   done
#
# }
#
# ltu_get_remote_files() {
#   local version target
#   cat - | while read -r args; do
#       version=${args[0]:-latest}
#       target=${args[1]:-aarch64-elf}
#       ltu_log "prg" "Loading remote files" "(ಡ_ಡ)ᕗ" "${version} ${target}"
#       ltu_get_from_url -s "${LTU_RELEASES_URL}/${version}/${target}/" |\
#       ltu_parse_html_links |\
#       awk -F"/" -v url_base="${LTU_RELEASES_URL}" '/^\/components\/toolchain\/binaries\/.*\/.*\/gcc.*\.tar.xz$/{ print url_base"/"$5"/"$6"/"$7 }'
#   done
# }

ltu_get_remote_toolchains() {
  local cache_file="${LTU_CACHE_DIR}/.ltu_cache_remote"
  local time_since_modify=$(ltu_time_since_file_modified ${cache_file})
  ([[ $time_since_modify -lt $((86400 * 7)) ]] &&
      (cat "${cache_file}") ||
      (ltu_get_from_url -s "https://gist.githubusercontent.com/rubeniskov/d5c04095c41076c4dfe5273015c9a871/raw" | ltu_cache_results "${cache_file}")) |\
  ltu_parse_toolchain
}
