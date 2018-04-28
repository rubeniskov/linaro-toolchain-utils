ltu_filter_version(){
  awk '/^[0-9]/{ print $0 }'
}

ltu_filter_brief(){
    [[ $* = *"--brief"* ]] && (awk '{print $1" "$4}' | sort | uniq) || cat -
}

ltu_filter_host_arch(){
    [[ $* = *"--host-arch"* ]] && grep -w "$(uname -m)" || cat -
}

ltu_filter_grep(){
  local pattern=$(echo "$*"|sed -e 's/--[0-9a-z\-]*//g'|sed -e 's/[[:space:]]*$//')
  #echo >&2 ".*${pattern// /.*\s.*}.*"
  #local pattern=$(echo ${*//-*/}|sed -e 's/^[[:space:]]*//')
  [[ -n $pattern ]] && grep ".*${pattern// /.*\s.*}.*" || cat -
}

ltu_filter_latest(){
  [[ $* = *"--latest"* ]] && (sort | awk '
    BEGIN {
        # initialize numeric cursor better than use an object
        len=0
    }
    NR>1{
        cur_ver=$1
        cur_rev=$2
        # if versions changes print the stored results
        if(prev_ver && cur_ver != prev_ver) {
            for (i = 1; i<len; i++) {
                print(arr[i]);
            }
            len=0;
        }
        # if not revision could change then reset the cursor to store the new data
        else if (prev_rev && cur_rev != prev_rev) {
            len=0;
        }
        # store result
        else
        {

            arr[len++]=$0
        }
        # save prev state
        prev_ver=cur_ver
        prev_rev=cur_rev
    }
    END {
        # print the rest of the data
        for (i = 1; i<len; i++) {
            print(arr[i]);
        }
    }') || cat -
}

#OLD VERSION
# ltu_filter_latest(){
#     [[ $* = *"--latest"* ]] && (awk '
#         NR>1 {
#           arr[$1" "$3" "$4]=$2
#         }
#         END {
#           for (a in arr) {
#             split(a, values, " ")
#             print(values[1], arr[a], values[2], values[3]);
#           }
#         }' | sort -n -k1,2) || cat -
# }
