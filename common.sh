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
source "./utils_filter.sh"
source "./utils_parser.sh"
source "./utils_format.sh"

ltu_get_platform(){
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

ESC_SEQ="\x1b["
COL_RESET=$ESC_SEQ"39;49;00m"
COL_RED=$ESC_SEQ"31;01m"
COL_GREEN=$ESC_SEQ"32;01m"
COL_YELLOW=$ESC_SEQ"33;01m"
COL_BLUE=$ESC_SEQ"34;01m"
COL_MAGENTA=$ESC_SEQ"35;01m"
COL_CYAN=$ESC_SEQ"36;01m"

#toolchain_get_available_revisions 5.1
#toolchain_get_latest_revision 5.1
#exit 1
ltu_log() {
  local ret
  local label=$1
  local color=$COL_GREEN
  local msg=$2
  local detail=$3
  local cols=$(tput cols)
  case $1 in
    err)
      label="error"
      color=$COL_RED
      ;;
    prg)
      ret=1
      label=$3
      detail=$4
      ;;
    wrn)
      label="warn"
      color=$COL_YELLOW
      ;;
    info)
      label="o.k."
      ;;
    *)
      label="..."
      msg="$1"
      detail="$2"
      ;;
  esac

  msg="[ $color$(printf "%5s" $label)$COL_RESET ] $msg"

  if [[ -n "$detail" ]]; then
    #msg="$msg ( $COL_BLUE${detail:0:$(($cols-${#msg}))}$COL_RESET )"
    msg="$msg ( $COL_BLUE$detail$COL_RESET )"
  fi

  # msg="$msg"
  echo -en >&2 "$(printf '%*s\n' "${COLUMNS:-$(($cols))}" '')\r"
  if [[ -n $ret ]]; then
    echo -en >&2 "$msg\r"
  else
    echo -e >&2 "$msg"
  fi


  # log function parameters to install.log
  #[[ -n $DEST ]] && echo "Displaying message: $@" >> $DEST/debug/output.log
}


ltu_exec(){
  $(ltu_find_command $1) "${@:2}"
}

ltu_check_command(){
  echo $1
  command -v "${1}" >/dev/null 2>&1 || {
      toolchain_display_alert "Missing command or not installed Aborting." "${1}" "wrn";
      echo >&2;
      exit 1;
  }
  return 0
}

ltu_find_command(){
    local cmd_path
    local cmd_name="${1}"
    local cmd_stored_path=$(echo $LTU_CMD_STORE|tr ' ' '\n'|grep "${cmd_name}:"|awk -F':' '{print $2}'|head -n 1)
    if [ -n "$cmd_stored_path" ]; then
        echo $cmd_stored_path
        return 0
    fi
    case "$(ltu_get_platform)" in
        Linux*)
          cmd_path=$(which $1)
        ;;
        Mac)
          if [ $(ltu_check_command brew) ]; then
              cmd_path=$(brew --prefix "gnu-${cmd_name}" 2>/dev/null||brew --prefix "${cmd_name}" 2>/dev/null)
              if [ $cmd_path ] && [ -f "${cmd_path}/bin/${cmd_name}" ]; then
                  cmd_path="${cmd_path}/bin/${cmd_name}"
              else
                  cmd_path=$(which ${cmd_name})
              fi
          fi
        ;;
    esac

    if [ -z $cmd_path ]; then
        toolchain_display_alert "Command not found" "${cmd_name}" "wrn"
        return 1
    fi

    LTU_CMD_STORE="$LTU_CMD_STORE $cmd_name:$cmd_path"

    echo $cmd_path
    return 0
}

ltu_time_since_file_modified(){
  if [ -f "${1}" ]; then
      echo "$(($(date +%s) - $(date -r "${1}" +"%s")))"
  else
      echo "$(((2**31)-1))"
  fi
}

ltu_cache_results(){
    if [ -n "${1}" ]; then
        if [ ! $(mkdir -p "$(dirname $cache_file)") ]; then
            cat - > $cache_file
        fi
    fi
    cat $cache_file
}

ltu_get_from_url(){
    ltu_exec curl \
      --header "User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/44.0.2403.89 Safari/537.36" \
      $*
}

ltu_each() {
  while read -r args; do
    while read -r res; do
        echo "$args"|awk -v res="$res" '{print $0" "res}'
    done <<< "$($* $args)"
  done
}
