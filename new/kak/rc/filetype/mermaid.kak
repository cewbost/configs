hook global BufCreate .*\.mmd %{
    set-option buffer filetype mmd
}

# Initialization
# ‾‾‾‾‾‾‾‾‾‾‾‾‾‾

hook global WinSetOption filetype=mmd %{
    require-module mmd

    # cleanup trailing whitespaces when exiting insert mode
    hook window ModeChange pop:insert:.* -group mmd-trim-indent %{ try %{ execute-keys -draft <a-x>s^\h+$<ret>d } }
    hook window InsertChar \n -group mmd-insert mmd-insert-on-new-line
    hook window InsertChar \n -group mmd-indent mmd-indent-on-new-line
    hook window InsertChar \{ -group mmd-indent mmd-indent-on-opening-curly-brace
    hook window InsertChar \} -group mmd-indent mmd-indent-on-closing-curly-brace

    hook -once -always window WinSetOption filetype=.* %{ remove-hooks window mmd-.+ }
}

hook -group mmd-highlight global WinSetOption filetype=mmd %{
    add-highlighter window/mmd ref mmd
    hook -once -always window WinSetOption filetype=.* %{ remove-highlighter window/mmd }
}

provide-module mmd %§

add-highlighter shared/mmd regions
add-highlighter shared/mmd/code default-region group
add-highlighter shared/mmd/string region %{(?<!')"} %{(?<!\\)(\\\\)*"} fill string
add-highlighter shared/mmd/character region %{'} %{(?<!\\)'} fill value
add-highlighter shared/mmd/line_comment region : $ fill value

add-highlighter shared/mmd/code/operator regex [.:,\;=+\-*/%<>!|&~^(){}[\]?]+ 0:operator
add-highlighter shared/mmd/code/types regex \b[A-Z][a-zA-Z0-9]*\b 0:type
#add-highlighter shared/mmd/code/members regex (?<=\.)[a-zA-Z0-9_]*\b 0:function

evaluate-commands %sh{
    # Grammar
    keywords='
        graph
        sequenceDiagram loop end participant Note
        gantt
        classDiagram class direction
        gitGraph
        erDiagram
        journey
        section
    '

    join() { sep=$2; eval set -- $1; IFS="$sep"; echo "$*"; }

# Highlight keywords
    printf %s "add-highlighter shared/mmd/code/keywords regex \b($(join "${keywords}" '|'))\b 0:keyword"
}


# Commands
# ‾‾‾‾‾‾‾‾

define-command -hidden mmd-insert-on-new-line %[
        # copy // comments prefix and following white spaces
        try %{ execute-keys -draft <semicolon><c-s>k<a-x> s ^\h*\K/{2,}\h* <ret> y<c-o>P<esc> }
]

define-command -hidden mmd-indent-on-new-line %~
    evaluate-commands -draft -itersel %=
        # preserve previous line indent
        try %{ execute-keys -draft <semicolon>K<a-&> }
        # indent after lines ending with { or (
        try %[ execute-keys -draft k<a-x> <a-k> [{(]\h*$ <ret> j<a-gt> ]
        # cleanup trailing white spaces on the previous line
        try %{ execute-keys -draft k<a-x> s \h+$ <ret>d }
        # align to opening paren of previous line
        try %{ execute-keys -draft [( <a-k> \A\([^\n]+\n[^\n]*\n?\z <ret> s \A\(\h*.|.\z <ret> '<a-;>' & }
        # indent after a switch's case/default statements
        try %[ execute-keys -draft k<a-x> <a-k> ^\h*(case|default).*:$ <ret> j<a-gt> ]
        # indent after keywords
        try %[ execute-keys -draft <semicolon><a-F>)MB <a-k> \A(if|else|while|for|try|catch)\h*\(.*\)\h*\n\h*\n?\z <ret> s \A|.\z <ret> 1<a-&>1<a-space><a-gt> ]
        # deindent closing brace(s) when after cursor
        try %[ execute-keys -draft <a-x> <a-k> ^\h*[})] <ret> gh / [})] <ret> m <a-S> 1<a-&> ]
    =
~

define-command -hidden mmd-indent-on-opening-curly-brace %[
    # align indent with opening paren when { is entered on a new line after the closing paren
    try %[ execute-keys -draft -itersel h<a-F>)M <a-k> \A\(.*\)\h*\n\h*\{\z <ret> s \A|.\z <ret> 1<a-&> ]
]

define-command -hidden mmd-indent-on-closing-curly-brace %[
    # align to opening curly brace when alone on a line
    try %[ execute-keys -itersel -draft <a-h><a-k>^\h+\}$<ret>hms\A|.\z<ret>1<a-&> ]
]

§
