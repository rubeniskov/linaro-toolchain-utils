#!/usr/bin/env awk

BEGIN {
  ORS = "";
  print("{");
  printf("\"description\": \"%s\",", description);
  printf("\"public\": %s,", "true");
  print("\"files\": {");
  printf("\"%s\": {", filename);
  print("\"content\": \"");
} {
  gsub(/\\/, "\\\\", $0)
  gsub(/"/, "\\\"", $0)
  printf("%s\\n", $0);
} END {
  print("\"}}}");
}
