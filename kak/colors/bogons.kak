# bogons theme

evaluate-commands %sh{
    # first we define the bogons colors as named colors
    bogons_darker_grey="rgb:222222"
    bogons_dark_grey="rgb:444444"
    bogons_grey="rgb:888888"
    bogons_light_grey="rgb:cccccc"
    bogons_lighter_grey="rgb:eeeeee"

		bogons_deep_blue="rgb:aaaaff"
		bogons_teal="rgb:bbddff"
		bogons_light_purple="rgb:ffaaff"
		bogons_deep_purple="rgb:ff88cc"
		bogons_red="rgb:ff99cc"
		bogons_light_orange="rgb:ffff99"
		bogons_pale_green="rgb:99ffff"

    bogons_dark_red="rgb:870000"
    bogons_light_red="rgb:ff8787"
    bogons_orange="rgb:d78700"
    bogons_purple="rgb:d7afd7"

    bogons_dark_green="rgb:5f875f"
    bogons_bright_green="rgb:87af00"
    bogons_green="rgb:afd787"
    bogons_light_green="rgb:d7d7af"

    bogons_dark_blue="rgb:005f87"
    bogons_blue="rgb:87afd7"
    bogons_light_blue="rgb:87d7ff"

    echo "
        # then we map them to code
        face global value ${bogons_red}
        face global type ${bogons_teal}
        face global variable ${bogons_green}
        face global module ${bogons_deep_purple}
        face global function ${bogons_light_purple}
        face global string ${bogons_light_orange}
        face global keyword ${bogons_deep_blue}
        face global operator ${bogons_pale_green}
        face global attribute ${bogons_light_blue}
        face global comment ${bogons_grey}
        face global documentation ${bogons_light_grey}
        face global meta ${bogons_red}
        face global builtin default+b

        # and markup
        face global title ${bogons_light_blue}
        face global header ${bogons_light_green}
        face global mono ${bogons_light_green}
        face global block ${bogons_light_blue}
        face global link ${bogons_light_green}
        face global bullet ${bogons_green}
        face global list ${bogons_blue}

        # and built in faces
        face global Default ${bogons_lighter_grey},default
        face global PrimarySelection ${bogons_darker_grey},${bogons_orange}+fg
        face global SecondarySelection  ${bogons_lighter_grey},${bogons_dark_blue}+fg
        face global PrimaryCursor ${bogons_darker_grey},${bogons_lighter_grey}+fg
        face global SecondaryCursor ${bogons_darker_grey},${bogons_lighter_grey}+fg
        face global PrimaryCursorEol ${bogons_darker_grey},${bogons_dark_green}+fg
        face global SecondaryCursorEol ${bogons_darker_grey},${bogons_dark_green}+fg
        face global LineNumbers ${bogons_grey},${bogons_dark_grey}
        face global LineNumberCursor ${bogons_grey},${bogons_dark_grey}+b
        face global MenuForeground ${bogons_blue},${bogons_dark_blue}
        face global MenuBackground ${bogons_darker_grey},${bogons_light_grey}
        face global MenuInfo ${bogons_grey}
        face global Information ${bogons_lighter_grey},${bogons_dark_green}
        face global Error ${bogons_light_red},${bogons_dark_red}
        face global DiagnosticError ${bogons_light_red}
        face global DiagnosticWarning ${bogons_purple}
        face global StatusLine ${bogons_lighter_grey},${bogons_dark_grey}
        face global StatusLineMode ${bogons_lighter_grey},${bogons_dark_green}+b
        face global StatusLineInfo ${bogons_dark_grey},${bogons_lighter_grey}
        face global StatusLineValue ${bogons_lighter_grey}
        face global StatusCursor default,${bogons_blue}
        face global Prompt ${bogons_lighter_grey}
        face global MatchingChar ${bogons_lighter_grey},${bogons_bright_green}
        face global BufferPadding ${bogons_green},default
        face global Whitespace ${bogons_grey}+f
    "
}
