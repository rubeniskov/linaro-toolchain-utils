#!/bin/bash
#title:           common.sh
#description:
#   This script is part of toolchain utils.
#author:          rubeniskov <dev@rubeniskov.com>
#date:            2018-04-18
#version:         0.1
#bash_version:    3.2.57(1)-release
#==============================================================================

source "./constants.sh"

toolchain_search(){
    curl -s "${TOOLCHAIN_RELEASES_URL}/${1}-${2}/${3}/" |\
    grep "${1}-${2}" |\
    grep "${4}_${3}" |\
    sed -n 's/.*href="\([^"]*\).*/\1/p' |\
    head -n 1 |\
    awk '
      function basename(file, a, n) {
        n = split(file, a, "/")
        return a[n]
      }
      {print basename($1)}'
}

toolchain_string_pad(){
  while [ ${#1} -ne $2 ];
  do
    x="${3:- }"$x
  done
  echo $x
}

toolchain_get_platform(){
  unameOut="$(uname -s)"
  case "${unameOut}" in
      Linux*)     platform=Linux;;
      Darwin*)    platform=Mac;;
      CYGWIN*)    platform=Cygwin;;
      MINGW*)     platform=MinGw;;
      *)          platform="UNKNOWN:${unameOut}"
  esac
  echo ${platform}
}

toolchain_get_available_revisions(){
  cat "${TOOLCHAIN_VERSIONS_FILE}"|\
      $TOOLCHAIN_CMD_SORT -n|\
      $TOOLCHAIN_CMD_GREP -w "${1}"|\
      cut -d ' ' -f 2-|tr " " "\n"
}

toolchain_get_latest_revision(){
  toolchain_get_available_revisions $1|\
      $TOOLCHAIN_CMD_TAIL -n 1
}

toolchain_get_available_versions(){
  cat "${TOOLCHAIN_VERSIONS_FILE}"|\
      $TOOLCHAIN_CMD_SORT -n|\
      $TOOLCHAIN_CMD_AWK '{print $1}'
}

toolchain_get_latest_version(){
  toolchain_get_available_versions|\
      $TOOLCHAIN_CMD_TAIL -n 1
}

toolchain_get_available_arch_types(){
  cat "${TOOLCHAIN_ARCH_TYPES_FILE}"|\
      $TOOLCHAIN_CMD_SORT -n|\
      $TOOLCHAIN_CMD_AWK '{print $1}'
}

toolchain_get_default_arch_type(){
  toolchain_get_available_arch_types|\
      $TOOLCHAIN_CMD_GREP "linux-gnu"|\
      $TOOLCHAIN_CMD_HEAD -n 1
}



#toolchain_get_available_revisions 5.1
#toolchain_get_latest_revision 5.1
#exit 1
toolchain_display_alert()
#--------------------------------------------------------------------------------------------------------------------------------
# Let's have unique way of displaying alerts
#--------------------------------------------------------------------------------------------------------------------------------
{
  # log function parameters to install.log
  [[ -n $DEST ]] && echo "Displaying message: $@" >> $DEST/debug/output.log

  local tmp=""
  [[ -n $2 ]] && tmp="[\e[0;33m $2 \x1B[0m]"

  case $3 in
  err)
  printf "[\e[0;31m error \x1B[0m] $1 $tmp\n"
  ;;

  wrn)
  printf "[\e[0;35m warn \x1B[0m] $1 $tmp\n"
  ;;

  ext)
  printf "[\e[0;32m o.k. \x1B[0m] \e[1;32m$1\x1B[0m $tmp\n"
  ;;

  info)
  printf "[\e[0;32m o.k. \x1B[0m] $1 $tmp\n"
  ;;

  *)
  printf "[\e[0;32m .... \x1B[0m] $1 $tmp\n"
  ;;
  esac
}


toolchain_exec(){
  case "$(toolchain_get_platform)" in
      Linux*)
        exec "${1}" ${@:2}
      ;;
      Mac)
        if [ $(toolchain_check_command brew) ]; then
            local cmd_prefix=$(brew --prefix "${1}" 2>/dev/null||brew --prefix "gnu-${1}" 2>/dev/null)
            exec "$cmd_prefix/bin/${1}" ${@:2}
        fi
      ;;
  esac
}

toolchain_check_command(){
  echo $1
  command -v "${1}" >/dev/null 2>&1 || {
      toolchain_display_alert "Missing command or not installed Aborting." "${1}" "wrn";
      echo >&2;
      exit 1;
  }
  return 0
}

toolchain_find_command(){
    local cmd_path
    case "$(toolchain_get_platform)" in
        Linux*)
          cmd_path=$(which $1)
        ;;
        Mac)
          if [ $(toolchain_check_command brew) ]; then
              cmd_path=$(brew --prefix "gnu-${1}" 2>/dev/null||brew --prefix "${1}" 2>/dev/null)
              if [ $cmd_path ] && [ -f "${cmd_path}/bin/${1}" ]; then
                  cmd_path="${cmd_path}/bin/${1}"
              else
                  cmd_path=$(which ${1})
              fi
          fi
        ;;
    esac
    if [ -z $cmd_path ]; then
        toolchain_display_alert "Command not found" "$1" "wrn"
        return 1
    fi
    echo $cmd_path
}

toolchain_bind_gnu_commands(){
  local cmd
  for cmd in "${TOOLCHAIN_GNU_COMMANDS[@]}"
  do
    eval "TOOLCHAIN_CMD_$(echo $cmd | awk '{print toupper($0)}')=$(toolchain_find_command $cmd)"
  done

  for cmd in "${TOOLCHAIN_THIRD_COMMANDS[@]}"
  do
    eval "TOOLCHAIN_CMD_$(echo $cmd | awk '{print toupper($0)}')=$(toolchain_find_command $cmd)"
  done

  for cmd in "${TOOLCHAIN_BASE_COMMANDS[@]}"
  do
    eval "TOOLCHAIN_CMD_$(echo $cmd | awk '{print toupper($0)}')=$(which $cmd)"
  done
}

toolchain_version(){
    printf "\nToolchain linaro utility 0.0.1\n\n"
}

toolchain_available_versions(){
    if [ "$1" = "-q" ]; then
        toolchain_get_available_versions
    else
cat <<EOF
    Versions
$(toolchain_get_available_versions|awk '{print "\t - "$0}')
EOF
    fi
}

toolchain_available_arch_types(){
    if [ "$1" = "-q" ]; then
        toolchain_get_available_arch_types
    else
cat <<EOF
    Arch Types
$(toolchain_get_available_arch_types|awk '{print "\t - "$0}')
EOF
    fi
}

toolchain_time_since_modified(){
  if [ -f "${1}" ]; then
      echo "$(($(date +%s) - $(date -r "${1}" +"%s")))"
  else
      echo "$(((2**31)-1))"
  fi
}

toolchain_ls_remote(){
  toolchain_get_remote_versions | \
  ( [[ "${1}" ]] && grep -w "${1}" || cat ) |
  awk 'BEGIN  { nores=1;
                printf "|%-10s|%s|\n", "----------", "-------------------------------"
                printf "|%8s  | %-30s|\n", "Version", "Revision"
                printf "|%-10s|%s|\n", "----------", "-------------------------------" }
      END     { if (nores) printf "| %-41s|\n", "No Results";
                printf "|%-10s|%s|\n", "----------", "-------------------------------" }
              { printf "|%9.5s |", $1; $1 = ""; printf "%-30.30s |\n", $0; nores=0}'
}

toolchain_ls_targets(){
  toolchain_get_remote_versions | awk \
  'BEGIN { printf "%-10s\n", "Target", "Revision"
           printf "%-10s\n", "----------", "--------------" }
         { printf "%-10s|", $1; $1 = ""; printf "%s\n", $0}'
}


toolchain_cache_results(){
    if [ -n "${1}" ]; then
        if [ ! $(mkdir -p "$(dirname $cache_file)") ]; then
            cat - > $cache_file
        fi
    fi
    cat $cache_file
}

toolchain_bind_gnu_commands

function toolchain_cleanup {
  rm -f "$DIR/.toolchain_cache_versions" "$DIR/.toolchain_cache_targets_*"
}
trap toolchain_cleanup EXIT
