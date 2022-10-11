hook global BufCreate .*\.sol %{
    set-option buffer filetype sol
}

# Initialization
# ‾‾‾‾‾‾‾‾‾‾‾‾‾‾

hook global WinSetOption filetype=sol %{
    require-module sol

    # cleanup trailing whitespaces when exiting insert mode
    hook window ModeChange pop:insert:.* -group sol-trim-indent %{ try %{ execute-keys -draft <a-x>s^\h+$<ret>d } }
    hook window InsertChar \n -group sol-insert sol-insert-on-new-line
    hook window InsertChar \n -group sol-indent sol-indent-on-new-line
    hook window InsertChar \{ -group sol-indent sol-indent-on-opening-curly-brace
    hook window InsertChar \} -group sol-indent sol-indent-on-closing-curly-brace

    hook -once -always window WinSetOption filetype=.* %{ remove-hooks window sol-.+ }
}

hook -group sol-highlight global WinSetOption filetype=sol %{
    add-highlighter window/sol ref sol
    hook -once -always window WinSetOption filetype=.* %{ remove-highlighter window/sol }
}

provide-module sol %§

add-highlighter shared/sol regions
add-highlighter shared/sol/code default-region group
add-highlighter shared/sol/string region %{(?<!')"} %{(?<!\\)(\\\\)*"} fill string
add-highlighter shared/sol/character region %{'} %{(?<!\\)'} fill value
add-highlighter shared/sol/comment region /\* \*/ fill comment
add-highlighter shared/sol/line_comment region // $ fill comment

# integer literals
add-highlighter shared/sol/code/ regex %{(?i)(?<!\.)\b[1-9]('?\d+)*(ul?l?|ll?u?)?\b(?!\.)} 0:value
add-highlighter shared/sol/code/ regex %{(?i)(?<!\.)\b0b[01]('?[01]+)*(ul?l?|ll?u?)?\b(?!\.)} 0:value
add-highlighter shared/sol/code/ regex %{(?i)(?<!\.)\b0('?[0-7]+)*(ul?l?|ll?u?)?\b(?!\.)} 0:value
add-highlighter shared/sol/code/ regex %{(?i)(?<!\.)\b0x[\da-f]('?[\da-f]+)*(ul?l?|ll?u?)?\b(?!\.)} 0:value

# floating point literals
add-highlighter shared/sol/code/ regex %{(?i)(?<!\.)\b\d('?\d+)*\.([fl]\b|\B)(?!\.)} 0:value
add-highlighter shared/sol/code/ regex %{(?i)(?<!\.)\b\d('?\d+)*\.?e[+-]?\d('?\d+)*[fl]?\b(?!\.)} 0:value
add-highlighter shared/sol/code/ regex %{(?i)(?<!\.)(\b(\d('?\d+)*)|\B)\.\d('?[\d]+)*(e[+-]?\d('?\d+)*)?[fl]?\b(?!\.)} 0:value
add-highlighter shared/sol/code/ regex %{(?i)(?<!\.)\b0x[\da-f]('?[\da-f]+)*\.([fl]\b|\B)(?!\.)} 0:value
add-highlighter shared/sol/code/ regex %{(?i)(?<!\.)\b0x[\da-f]('?[\da-f]+)*\.?p[+-]?\d('?\d+)*)?[fl]?\b(?!\.)} 0:value
add-highlighter shared/sol/code/ regex %{(?i)(?<!\.)\b0x([\da-f]('?[\da-f]+)*)?\.\d('?[\d]+)*(p[+-]?\d('?\d+)*)?[fl]?\b(?!\.)} 0:value

add-highlighter shared/sol/code/operator regex [.:,\;=+\-*/%<>!|&~^(){}[\]?]+ 0:operator
add-highlighter shared/sol/code/types regex \b[A-Z][a-zA-Z0-9]*\b 0:type
#add-highlighter shared/sol/code/members regex (?<=\.)[a-zA-Z0-9_]*\b 0:function

evaluate-commands %sh{
    # Grammar
    keywords='
        pragma import
        contract modifier function public restricted view returns constructor is abstract
        if return
        delete
        external
        address memory
        bool uint string mapping
        this msg sender require true false
    '

    join() { sep=$2; eval set -- $1; IFS="$sep"; echo "$*"; }

# Highlight keywords
    printf %s "add-highlighter shared/sol/code/keywords regex \b($(join "${keywords}" '|'))\b 0:keyword"
}


# Commands
# ‾‾‾‾‾‾‾‾

define-command -hidden sol-insert-on-new-line %[
        # copy // comments prefix and following white spaces
        try %{ execute-keys -draft <semicolon><c-s>k<a-x> s ^\h*\K/{2,}\h* <ret> y<c-o>P<esc> }
]

define-command -hidden sol-indent-on-new-line %~
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

define-command -hidden sol-indent-on-opening-curly-brace %[
    # align indent with opening paren when { is entered on a new line after the closing paren
    try %[ execute-keys -draft -itersel h<a-F>)M <a-k> \A\(.*\)\h*\n\h*\{\z <ret> s \A|.\z <ret> 1<a-&> ]
]

define-command -hidden sol-indent-on-closing-curly-brace %[
    # align to opening curly brace when alone on a line
    try %[ execute-keys -itersel -draft <a-h><a-k>^\h+\}$<ret>hms\A|.\z<ret>1<a-&> ]
]

§
