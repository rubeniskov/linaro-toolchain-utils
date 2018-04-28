#!/bin/bash
#title:           ls.sh
#description:
#   This script is part of toolchain utils.
#author:          rubeniskov <dev@rubeniskov.com>
#date:            2018-04-18
#version:         0.1
#bash_version:    3.2.57(1)-release
#==============================================================================

source './common.sh'
source './ls-remote.sh'
source './ls-local.sh'

ltu_ls_usage(){
  local app_name=$(basename $0)
cat <<EOF
Usage: $app_name ls <search> <options>

  Example
    $app_name ls 7.2 elf
    $app_name ls 4.9 x86_64

  Options
    $app_name ls -q|--quiet           Supress formats and colors usefull to parse the data
    $app_name ls -a|--all             Show all data
    $app_name ls -l|--latest          Match only with the latest revision of each version
    $app_name ls --no-color           Disable output color
    $app_name ls --no-table           Disable output table format
    $app_name ls --no-host-arch       Disable host architecture filter
    $app_name ls --local              Display only the installed toolchain packages
    $app_name ls --remote             Display only the remote toolchain packages
    $app_name ls --help               Display this usage
EOF
}

ltu_ls_remote_checking_locals(){
  while read -r line; do
    if [[ $(ltu_ls_local $* | grep -w "${line}") ]]; then
      printf "%s %s\n" "☑" "${line}"
    else
      printf "%s %s\n" "☐" "${line}"
    fi
  done <<< "$(ltu_ls_remote $*)"
}

ltu_ls() {
  local flags=("--brief --color --table --host-arch")
  local pattern
  local table_headers=("I Version%5" "Target%25")
  local opts=$(ltu_exec getopt \
          --options :qal \
          --long quiet,all,latest,no-color,no-table,no-host-arch,local,remote,help \
          --name 'ltu_ls' -- "$@")


  eval set -- "$opts"
  while true; do
    case "${1}" in
      --)
          pattern="${@:2}"
          break
          ;;
      -q|--quiet)
          flags=(${flags[@]//'--table'})
          flags=(${flags[@]//'--color'})
          shift 1
          ;;
      -a|--all)
          flags=(${flags[@]//'--brief'})
          table_headers=("I Version%5" "Revision%15" "Host%15" "Target%25")
          shift 1
          ;;
      -l|--latest)
          flags+=("--latest")
          shift 1
          ;;
      --local|--remote)
          flags+=("${1}")
          shift 1
          ;;
      --no-color|--no-table|--no-host-arch)
          local flag=${1//no-}
          flags=(${flags[@]//$flag})
          shift 1
          ;;
      --help|*)
          ltu_ls_usage
          return 1
          ;;
    esac
  done

  if [[ "${flags[*]}" = *"--local"* ]] || [[ "${flags[*]}" = *"--remote"* ]]; then
      table_headers=(${table_headers[@]//'I'})
  fi

  ([[ "${flags[*]}" = *"--local"* ]] && \
      ltu_ls_local $pattern ${flags[*]}|| \
  ([[ "${flags[*]}" = *"--remote"* ]] && \
      ltu_ls_remote $pattern ${flags[*]} || \
      ltu_ls_remote_checking_locals $pattern ${flags[*]} )) |\
  ([[ "${flags[*]}" = *"--color"* ]] && awk '{ if ($1 ~ /^☑/) { printf("\033[1m\033[32m%s\033[0m\n", $0) } else { $6 = ""; print $0; } }' || cat -) |\
  ([[ "${flags[*]}" = *"--table"* ]] && ltu_format_table "${table_headers[@]}" || cat -)
}
