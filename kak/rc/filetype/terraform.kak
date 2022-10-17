# Terraform configuration language
# https://www.terraform.io/docs/configuration/

remove-hooks global terraform-highlight

hook -group terraform-highlight global WinSetOption filetype=terraform %{
    add-highlighter window/hterraform ref hterraform
    hook -once -always window WinSetOption filetype=.* %{ remove-highlighter window/hterraform }
}

# Highlighters
# ‾‾‾‾‾‾‾‾‾‾‾‾

add-highlighter shared/hterraform regions
add-highlighter shared/hterraform/code  default-region group

add-highlighter shared/hterraform/comment1 region '#'    '$'  fill comment
add-highlighter shared/hterraform/comment2 region '\\'   '$'  fill comment
add-highlighter shared/hterraform/comment3 region /\*    \*/  fill comment

# Strings can contain interpolated terraform expressions, which can contain
# strings. Currently, we cannot support nesting of the same type of delimiter,
# so instead we render the full interpolation as a value (otherwise, it
# looks bad).
# See https://github.com/mawww/kakoune/issues/1670
add-highlighter shared/hterraform/string  region '"' '(?<!\\)(?:\\\\)*"'  group
add-highlighter shared/hterraform/string/fill fill string
add-highlighter shared/hterraform/string/inter regex \$\{.+?\} 0:value

add-highlighter shared/hterraform/heredoc region -match-capture '<<-?(\w+)' '^\h*(\w+)$' regions
add-highlighter shared/hterraform/heredoc/fill default-region fill string
add-highlighter shared/hterraform/heredoc/inter region -recurse \{ (?<!\\)(\\\\)*\$\{ \} ref hterraform


add-highlighter shared/hterraform/code/valueDec regex '\b[0-9]+([kKmMgG]b?)?\b' 0:value
add-highlighter shared/hterraform/code/valueHex regex '\b0x[0-9a-f]+([kKmMgG]b?)?\b' 0:value

add-highlighter shared/hterraform/code/operators regex [\[\]\{\}=] 0:operator

add-highlighter shared/hterraform/code/field regex '^\h+(\w+)\s*(=)' 1:variable

evaluate-commands %sh{
  blocks="connection content data dynamic locals module output provider
          provisioner resource terraform variable required_providers ports log_config"
  ctrl_words="for for_each if in"
  var_subs="local module var"

  keywords="$blocks $ctrl_words $var_subs"
  constants="true false null"
  types="bool list map number object set string tuple"

  # Builtin functions
  fun_num="abs ceil floor log max min parseint pow signum"
  fun_str="chomp format formatlist indent join lower regex regexall replace
           split strrev substr title trimspace upper"
  fun_coll="chunklist coalesce coalescelist compact concat contains
            distinct element flatten index keys length lookup
            matchkeys merge range reverse setintersection setproduct
            setunion slice sort transpose values zipmap"
  fun_enc="base64decode base64encode base64gzip csvdecode jsondecode
           jsonencode urlencode yamldecode yamlencode"
  fun_file="abspath dirname pathexpand basename file fileexists fileset
            filebase64 templatefile"
  fun_dt="formatdate timeadd timestamp"
  fun_crypt="base64sha256 base64sha512 bcrypt filebase64sha256
             filebase64sha512 filemd5 filesha1 filesha256 filesha512 md5
             rsadecrypt sha1 sha256 sha512 uuid uuidv5"
  fun_net="cidrhost cidrnetmask cidrsubnet"
  fun_cast="tobool tolist tomap tonumber toset tostring"

  functions="$fun_num $fun_str $fun_coll $fun_enc $fun_file $fun_dt $fun_crypt $fun_net $fun_cast"

  join() { sep=$2; eval set -- $1; IFS="$sep"; echo "$*"; }

  # Add grammar elements to the static completion list
  printf %s\\n "declare-option str-list terraform_static_words $(join "$keywords $constants $types $functions" ' ')"

  # Highlight grammar elements
  printf %s "
    add-highlighter shared/hterraform/code/ regex '\b($(join "$keywords"  '|'))\b'     1:keyword
    add-highlighter shared/hterraform/code/ regex '\b($(join "$constants" '|'))\b'     1:value
    add-highlighter shared/hterraform/code/ regex '\b($(join "$types" '|'))\b'     1:type
    add-highlighter shared/hterraform/code/ regex '\b($(join "$functions" '|'))\s*\('  1:builtin
  "
}
