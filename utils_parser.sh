ltu_parse_html_links(){
    grep "<a" |\
    sed -n 's/.*href="\([^"]*\).*/\1/p'
}

ltu_parse_basename(){
  awk 'function basename(file, a, n) {
        n = split(file, a, "/")
      return a[n]
    }
    {print basename($1)}'
}

ltu_parse_toolchain(){
  awk 'function basename(file, a, n) {
      n = split(file, a, "/")
    return a[n]
  }
  {print basename($1)" "$1}' |\
  sed -n -E 's/gcc-linaro-(([0-9]+\.)+([0-9]))-([0-9]{4}(\.[0-9]{2})+(-[0-9]+)?)-([a-z0-9-]+(_64)?)_([a-z0-9-]+)(.*) /\1 \4 \7 \9 /p'
}

ltu_parse_group_by(){
  awk -F, 'NR>1{arr[$1]++}END{for (a in arr) print a, arr[a]}'
}
