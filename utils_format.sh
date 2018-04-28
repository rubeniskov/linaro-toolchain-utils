ltu_format_table(){
  awk -v argv="$*" '
  function max(a, b){
      return (a > b) ? a : b;
  }

  function draw_splitter(column_sizes){
      for(i = 1; i <= length(column_sizes); i++) {
          str_splitter=sprintf("%"column_sizes[i]"s", "");
          gsub(/ /, "-", str_splitter);
          printf("%s",("|"str_splitter));
      }
      print("|");
  }

  function draw_header(column_names, column_sizes) {
      col_len = length(column_sizes)
      for(i = 1; i <= col_len; i++) {
          for(j = col_len + 1; col_len == i && j <= length(column_names); j ++) {
              column_names[i] = column_names[i]" "column_names[j];
          }
          printf("| %"(i == 1 ? "": "-")(column_sizes[i] - 2)"s ", column_names[i]);
      }
      print("|");
  }

  function draw_row(column_values, column_sizes) {
      split(column_values, column_values, " ");
      draw_header(column_values, column_sizes);
  }

  function parse_argv(argv){
      split(argv, args, " ");
      for (i = 1; i <= length(args); i++) {
          split(args[i], column, "%");
          if (length(column[2]) == 0) {
              column[2] = length(column[1]) + 2;
          } else {
              column[2] = max(column[2], length(column[1]) + 2);
          }
          column_names[i] = column[1];
          column_sizes[i] = column[2];
      }
  }

  BEGIN  {
      nores = 1;
      parse_argv(argv);
      draw_splitter(column_sizes);
      draw_header(column_names, column_sizes);
      draw_splitter(column_sizes);
  }
  END {
      if (nores)
          draw_row("No Results", column_sizes);
      draw_splitter(column_sizes);
  }
  {
      nores=0;
      draw_row($0, column_sizes);
  }'
}

ltu_format_local_toolchain(){
  awk '{
      printf("gcc-linaro-%s-%s-%s_%s\n", $1, $2, $3, $4)
  }'
}

ltu_format_remote_toolchain(){
  awk -v url_base="$LTU_RELEASES_URL" '{
      split($1, version, ".")
      printf("%s/%s-%s/%s/gcc-linaro-%s-%s-%s_%s.tar.xz\n", url_base, version[1]"."version[2], $2, $4, $1, $2, $3, $4)
  }'
}
