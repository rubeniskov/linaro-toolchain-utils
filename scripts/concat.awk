#!/usr/bin/env awk

function read_file_content(file){
    while ("cat "file | getline){
        if ( $0 ~ /source/ ) {
            print parse_bash_source($0)
        # remove comments and hashbangs
        } else if ( $0 !~ /^#/ ) {
            print $0
        }
    }
}

function match_source_path(line) {
    return substr(line, 9, length(line) - 9)
}

function parse_bash_source(line){
    src = match_source_path(line)
    if (cached[src] != 1) {
        read_file_content(src)
    }
    cached[src] = 1
}

BEGIN {
    print "#!/usr/bin/env bash"
}
{
    read_file_content($0)
}
