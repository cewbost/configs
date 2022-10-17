hook global BufCreate .*\.jarl %{
    set-option buffer filetype jarl
}

# Initialization
# ‾‾‾‾‾‾‾‾‾‾‾‾‾‾

hook global WinSetOption filetype=jarl %{
    require-module jarl

    # cleanup trailing whitespaces when exiting insert mode
    hook window ModeChange pop:insert:.* -group jarl-trim-indent %{ try %{ execute-keys -draft <a-x>s^\h+$<ret>d } }
    hook window InsertChar \n -group jarl-insert jarl-insert-on-new-line
    hook window InsertChar \n -group jarl-indent jarl-indent-on-new-line
    hook window InsertChar \{ -group jarl-indent jarl-indent-on-opening-curly-brace
    hook window InsertChar \} -group jarl-indent jarl-indent-on-closing-curly-brace

    hook -once -always window WinSetOption filetype=.* %{ remove-hooks window jarl-.+ }
}

hook -group jarl-highlight global WinSetOption filetype=jarl %{
    add-highlighter window/jarl ref jarl
    hook -once -always window WinSetOption filetype=.* %{ remove-highlighter window/jarl }
}

provide-module jarl %§

add-highlighter shared/jarl regions
add-highlighter shared/jarl/code default-region group
add-highlighter shared/jarl/string region %{(?<!')"} %{(?<!\\)(\\\\)*"} fill string
add-highlighter shared/jarl/character region %{'} %{(?<!\\)'} fill value
add-highlighter shared/jarl/comment region /\* \*/ fill comment
add-highlighter shared/jarl/inline_documentation region /// $ fill documentation
add-highlighter shared/jarl/line_comment region // $ fill comment

add-highlighter shared/jarl/code/ regex "(\b[0-9]+\.?[0-9]*|\.[0-9]+)([eE][+-]?[0-9]+)?" 0:value
add-highlighter shared/jarl/code/ regex "\b0[xX]([0-9a-fA-F]+\.?[0-9a-fA-F]*|\.[0-9a-fA-F]+)([pP][+-]?[0-9]+)?" 0:value
add-highlighter shared/jarl/code/ regex "\b(0[bB][0-1]+|0[oO][0-7]+)\b" 0:value
add-highlighter shared/jarl/code/ regex "[.:,;=+\-*/%%<>!|&~^(){}[\]]+" 0:operator
add-highlighter shared/jarl/code/ regex "\b(var|assert|true|false|null|and|or|not|in|if|do|else|while|for|func|return|recurse|move)\b" 0:keyword

# Commands
# ‾‾‾‾‾‾‾‾

define-command -hidden jarl-insert-on-new-line %[
        # copy // comments prefix and following white spaces
        try %{ execute-keys -draft <semicolon><c-s>k<a-x> s ^\h*\K/{2,}\h* <ret> y<c-o>P<esc> }
]

define-command -hidden jarl-indent-on-new-line %~
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

define-command -hidden jarl-indent-on-opening-curly-brace %[
    # align indent with opening paren when { is entered on a new line after the closing paren
    try %[ execute-keys -draft -itersel h<a-F>)M <a-k> \A\(.*\)\h*\n\h*\{\z <ret> s \A|.\z <ret> 1<a-&> ]
]

define-command -hidden jarl-indent-on-closing-curly-brace %[
    # align to opening curly brace when alone on a line
    try %[ execute-keys -itersel -draft <a-h><a-k>^\h+\}$<ret>hms\A|.\z<ret>1<a-&> ]
]

§
