# https://golang.org/
#

remove-hooks global go-highlight

define-command go-focus-test %{
  exec -draft '/\bTest\w+\(\)<ret><a-n>Z%s<ret>in<esc>z<a-;>hde'
}
define-command go-unfocus-test %{
  exec -draft '%s\bnTest\w+\(\)<ret><a-;>;d'
}

hook -group go-cmd global WinSetOption filetype=go %{
    set-option window formatcmd goimports

    hook -group go-cmd-impl buffer BufWritePre .* %{
      format
    }

    map buffer user t ':go-focus-test<ret>' -docstring 'Focus this test'
    map buffer user T ':go-unfocus-test<ret>' -docstring 'Unfocus test'
}

hook -group go-highlight global WinSetOption filetype=go %{
    add-highlighter window/go ref hgo
    hook -once -always window WinSetOption filetype=.* %{ remove-highlighter window/go }
}

# Highlighters
# ‾‾‾‾‾‾‾‾‾‾‾‾

add-highlighter shared/hgo regions
add-highlighter shared/hgo/code default-region group
add-highlighter shared/hgo/back_string region '`' '`' fill string
add-highlighter shared/hgo/double_string region '"' (?<!\\)(\\\\)*" fill string
add-highlighter shared/hgo/single_string region "'" (?<!\\)(\\\\)*' fill string
add-highlighter shared/hgo/comment region /\* \*/ fill comment
add-highlighter shared/hgo/comment_line region '//' $ fill comment

add-highlighter shared/hgo/code/ regex %{-?([0-9]*\.(?!0[xX]))?\b([0-9]+|0[xX][0-9a-fA-F]+)\.?([eE][+-]?[0-9]+)?i?\b} 0:value

add-highlighter shared/hgo/code/operator regex [.:,\;=+\-*/%<>!|&~^(){}[\]?]+ 0:operator
add-highlighter shared/hgo/code/types regex \b[A-Z][a-zA-Z0-9]*\b 0:type

evaluate-commands %sh{
    # Grammar
    keywords='break default func interface select case defer go map struct any comparable
              chan else goto package switch const fallthrough if range type
              continue for import return var
              bool byte chan complex128 complex64 error float32 float64 int int16 int32
              int64 int8 interface intptr map rune string struct uint uint16 uint32 uint64 uint8'
    constants='false true nil iota'
    functions='append cap close complex copy delete imag len make new panic print println real recover'

    join() { sep=$2; eval set -- $1; IFS="$sep"; echo "$*"; }

    # Add the language's grammar to the static completion list
    printf %s\\n "declare-option str-list go_static_words $(join "${keywords} ${constants} ${functions}" ' ')"

    # Highlight keywords
    printf %s "
        add-highlighter shared/hgo/code/ regex \b($(join "${keywords}" '|'))\b 0:keyword
        add-highlighter shared/hgo/code/ regex \b($(join "${constants}" '|'))\b 0:value
        add-highlighter shared/hgo/code/ regex \b($(join "${functions}" '|'))\b 0:builtin
    "
}
