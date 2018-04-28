
TEST_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
TEST_MODE_RECORD=1
TEST_MODE_OUTPUT=2
# TEST_MODE=$(($TEST_MODE_RECORD|$TEST_MODE_OUTPUT))
TEST_MODE=${TEST_MODE:=0}

record_assert_file(){
    mkdir -p  "${TEST_DIR}/asserts" && $(echo $@) > "${TEST_DIR}/asserts/$(echo "$@" | sed 's/ /_/g')"
}

describe(){
    test_display_message "$1" "" "desc"
}

test(){
    test_display_message "$1" "" "test"
}

assert_file(){
    if [[ $(( $TEST_MODE & $TEST_MODE_RECORD)) -eq $TEST_MODE_RECORD ]]; then
        record_assert_file $@
    fi

    $(echo $@) | diff "${TEST_DIR}/asserts/$(echo "$@" | sed 's/ /_/g')" -
    if [ $? -eq 0 ]; then
        test_display_message "$1" "$(echo "${@:2}")" "success"
    else
        test_display_message "$1" "$(echo "${@:2}")" "failed"
    fi

    if [[ $(( $TEST_MODE & $TEST_MODE_OUTPUT)) -eq $TEST_MODE_OUTPUT ]]; then
        echo "BEGIN OUTPUT"
        echo "========================================================="
        $(echo $@)
        echo "========================================================="
        echo "END OUTPUT"
    fi
}


test_display_message() {
  #[[ -z $TEST_LOG_FLAG ]] && "" > $TEST_DIR/output.log && TEST_LOG_FLAG=true
  #[[ -n $TEST_DIR ]] && echo "$@" >> $TEST_DIR/output.log

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

  desc)
  printf "\e[1;34m==> $1 \e[m\n"
  ;;

  test)
  printf "\e[0;32m  > $1 \e[m\n"
  ;;

  success)
  printf "   [\e[1;32m ✓ \e[m] $1 $2\n"
  ;;

  failed)
  printf "   [\e[1;31m ✗ \e[m] $1 $2\n"
  ;;

  *)
  printf "[\e[0;32m .... \x1B[0m] $1 $tmp\n"
  ;;
  esac
}
