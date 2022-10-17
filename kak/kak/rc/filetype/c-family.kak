remove-hooks global cpp-highlight
remove-hooks global c-highlight

hook -group c-highlight global WinSetOption filetype=c %{
		add-highlighter window/c ref cc
		hook -once -always window WinSetOption filetype=.* %{ remove-highlighter window/c }
}
hook -group cpp-highlight global WinSetOption filetype=cpp %{
		add-highlighter window/cpp ref ccpp
		hook -once -always window WinSetOption filetype=.* %{ remove-highlighter window/cpp }
}

# Regions definition are the same between c++ and objective-c
evaluate-commands %sh{
    for ft in cc ccpp cobjc; do
        if [ "${ft}" = "objc" ]; then
            maybe_at='@?'
        else
            maybe_at=''
        fi

        cat <<-EOF
            add-highlighter shared/$ft regions
            add-highlighter shared/$ft/code default-region group
            add-highlighter shared/$ft/string region %{$maybe_at(?<!')(?<!'\\\\)"} %{(?<!\\\\)(?:\\\\\\\\)*"} fill string
            add-highlighter shared/$ft/documentation_comment region /\*(\*[^/]|!) \*/ fill documentation
            add-highlighter shared/$ft/line_documentation_comment region //[/!] $ fill documentation
            add-highlighter shared/$ft/comment region /\\* \\*/ fill comment
            add-highlighter shared/$ft/line_comment region // (?<!\\\\)(?=\\n) fill comment
            #add-highlighter shared/$ft/disabled region -recurse "#\\h*if(?:def)?" ^\\h*?#\\h*if\\h+(?:0|FALSE)\\b "#\\h*(?:else|elif|endif)" fill comment
            add-highlighter shared/$ft/macro region %{^\\h*?\\K#} %{(?<!\\\\)(?=\\n)|(?=//)} group

            add-highlighter shared/$ft/macro/ fill meta
            add-highlighter shared/$ft/macro/ regex ^\\h*#\\h*include\\h+(\\S*) 1:module
            #add-highlighter shared/$ft/macro/ regex /\\*.*?\\*/ 0:comment

    				add-highlighter shared/$ft/code/operator regex [.:,\;=+\\-*/%<>!|&~^(){}[\\]?]+ 0:operator
	EOF
    done
}

# c specific
add-highlighter shared/cc/code/numbers regex %{\b-?(0x[0-9a-fA-F]+|\d+)([uU][lL]{0,2}|[lL]{1,2}[uU]?|[fFdDiI]|([eE][-+]?\d+))?|'((\\.)?|[^'\\])'} 0:value
evaluate-commands %sh{
	# Grammar
  	keywords='asm fortran auto break case char const continue default do double
  			else enum extern float for goto if inline int long register restrict
  			return short signed sizeof static struct switch typedef union unsigned
  			void volatile while alignas alignof bool complex imaginary noreturn
  			static_assert thread_local'
  	types='size_t ptrdiff_t NULL
  			int8_t int16_t int32_t int64_t
  			int_fast8_t int_fast16_t int_fast32_t int_fast64_t
  			int_least8_t int_least16_t int_least32_t int_least64_t
  			intmax_t intptr_t uintmax_t uintptr_t
  			uint8_t uint16_t uint32_t uint64_t
  			uint_fast8_t uint_fast16_t uint_fast32_t uint_fast64_t
  			uint_least8_t uint_least16_t uint_least32_t uint_least64_t
  			atomic_bool atomic_char atomic_schar atomic_uchar atomic_short atomic_ushort atomic_int atomic_uint atomic_long atomic_ulong atomic_llong atomic_ullong atomic_char16_t atomic_char32_t atomic_wchar_t
  			atomic_int_fast8_t atomic_int_fast16_t atomic_int_fast32_t atomic_int_fast64_t
  			atomic_int_least8_t atomic_int_least16_t atomic_int_least32_t atomic_int_least64_t
  			atomic_uint_fast8_t atomic_uint_fast16_t atomic_uint_fast32_t atomic_uint_fast64_t
  			atomic_uint_least8_t atomic_uint_least16_t atomic_uint_least32_t atomic_uint_least64_t
  			atomic_intptr_t atomic_uintptr_t atomic_size_t atomic_ptrdiff_t atomic_intmax_t atomic_uintmax_t
				FILE fpos_t
				va_list
				div_t ldiv_t lldiv_t imaxdiv_t float_t double_t
				tm time_t clock_t timespec'
		library='malloc calloc realloc free aligned_alloc
				isalnum isalpha islower isupper isdigit isxdigit iscntrl isgraph isspace isblank isprint ispunct
				tolower toupper
				atof atoi atol atoll strtol strtoll strtoul strtoull strtof strtod strtold strtoimax strtoumax
				strcpy strcpy_s strncpy strncpy_s strcat strcat_s strncat strncat_s strxfrm strdup strndup
				strlen strnlen_s strcmp strncmp strcoll strchr strrchr strspn strcspn strpbrk strstr strtok strtok_s
				memchr memcmp memset memset_s memcpy memcpy_s memmove memmove_s memccpy
				strerror strerror_s strerrorlen_s
				abs labs llabs div ldiv lldiv imaxabs imaxdiv
				fabs fabsf fabsl fmod fmodf fmodl remainder remainderf remainderl remquo remquof remquol fma fmaf fmal fmax fmaxf fmaxl fmin fminf fminl fdim fdimf fdiml nan nanf nanl
				exp expf expl exp2 exp2f exp2l expm1 expm1f expm1l log logf logl log10 log10f log10l log2 log2f log2l log1p log1pf log1pl
				pow powf powl sqrt sqrtf sqrtl cbrt cbrtf cbrtl hypot hypotf hypotl
				sin sinf sinl cos cosf cosl tan tanf tanl asin asinf asinl acos acosf acosl atan atanf atanl atan2 atan2f atan2l
				sinh sinhf sinhl cosh coshf coshl tanh tanhf tanhl asinh asinhf asinhl acosh acoshf acoshl atanh atanhf atanhl
				erf erff erfl erfc erfcf erfcl tgamma tgammaf tgammal lgamma lgammaf lgammal
				ceil ceilf ceill floor floorf floorl trunc truncf truncl round roundf roundl lround lroundf lroundl llround llroundf llroundl nearbyint nearbyintf nearbyintl rint rintf rintl lrint lrintf lrintl llrint llrintf llrintl
				frexp frexpf frexpl ldexp ldexpf ldexpl modf modff modfl scalbn scalbnf scalbnl scalbln scalblnf scalblnl ilogb ilogbf ilogbl logb logbf logbl nextafter nextafterf nextafterl nexttoward nexttowardf nexttowardl copysign copysignf copysignl
				fpclassify isfinite isinf isnan isnormal signbit isgreater isgreaterequal isless islessequal islessgreater isunordered
				rand srand
				asctime asctime_r asctime_s ctime ctime_r ctime_s strftime wcsftime gmtime gmtime_r gmtime_s localtime localtime_r localtime_s mktime
				difftime time clock timespec_get timespect_getres
				va_start va_arg va_copy va_end
				stdin stdout stderr
				fopen fopen_s freopen freopen_s fclose fflush setbuf setvbuf fwide
				fread fwrite
				fgetc getc fgets fputc putc fputs getchar gets gets_s putchar puts ungetc
				fgetwc getwc fgetws fputwc putwc fputws getwchar putwchar ungetwc
				scanf fscanf sscanf scanf_s fscanf_s sscanf_s vscanf vfscanf vsscanf vscanf_s vfscanf_s vsscanf_s printf fprintf sprintf snprintf printf_s fprintf_s sprintf_s snprintf_s vprintf vfprintf vsprintf vsnprintf vprintf_s vfprintf_s vsprintf_s vsnprintf_s
				wscanf fwscanf swscanf wscanf_s fwscanf_s swscanf_s vwscanf vfwscanf vswscanf vwscanf_s vfwscanf_s vswscanf_s wprintf fwprintf swprintf snwprintf wprintf_s fwprintf_s swprintf_s snwprintf_s vwprintf vfwprintf vswprintf vsnwprintf vwprintf_s vfwprintf_s vswprintf_s vsnwprintf_s
				ftell fgetpos fseek fsetpos rewind
				clearerr feof ferror perror
				remove rename tmpfile tmpfile_s tmpnam tmpnam_s'

  	join() { sep=$2; eval set -- $1; IFS="$sep"; echo "$*"; }

		# Highlight keywords
		printf %s "
  			add-highlighter shared/cc/code/keywords regex \b($(join "${keywords}" '|'))\b 0:keyword
  			add-highlighter shared/cc/code/types regex \b($(join "${types}" '|'))\b 0:keyword
  			add-highlighter shared/cc/code/library regex \b($(join "${library}" '|'))\b 0:function
		"
}

# c++ specific

# raw strings
add-highlighter shared/ccpp/raw_string region -match-capture %{R"([^(]*)\(} %{\)([^")]*)"} fill string

# integer literals
add-highlighter shared/ccpp/code/ regex %{(?i)(?<!\.)\b[1-9]('?\d+)*(ul?l?|ll?u?)?\b(?!\.)} 0:value
add-highlighter shared/ccpp/code/ regex %{(?i)(?<!\.)\b0b[01]('?[01]+)*(ul?l?|ll?u?)?\b(?!\.)} 0:value
add-highlighter shared/ccpp/code/ regex %{(?i)(?<!\.)\b0('?[0-7]+)*(ul?l?|ll?u?)?\b(?!\.)} 0:value
add-highlighter shared/ccpp/code/ regex %{(?i)(?<!\.)\b0x[\da-f]('?[\da-f]+)*(ul?l?|ll?u?)?\b(?!\.)} 0:value

# floating point literals
add-highlighter shared/ccpp/code/ regex %{(?i)(?<!\.)\b\d('?\d+)*\.([fl]\b|\B)(?!\.)} 0:value
add-highlighter shared/ccpp/code/ regex %{(?i)(?<!\.)\b\d('?\d+)*\.?e[+-]?\d('?\d+)*[fl]?\b(?!\.)} 0:value
add-highlighter shared/ccpp/code/ regex %{(?i)(?<!\.)(\b(\d('?\d+)*)|\B)\.\d('?[\d]+)*(e[+-]?\d('?\d+)*)?[fl]?\b(?!\.)} 0:value
add-highlighter shared/ccpp/code/ regex %{(?i)(?<!\.)\b0x[\da-f]('?[\da-f]+)*\.([fl]\b|\B)(?!\.)} 0:value
add-highlighter shared/ccpp/code/ regex %{(?i)(?<!\.)\b0x[\da-f]('?[\da-f]+)*\.?p[+-]?\d('?\d+)*)?[fl]?\b(?!\.)} 0:value
add-highlighter shared/ccpp/code/ regex %{(?i)(?<!\.)\b0x([\da-f]('?[\da-f]+)*)?\.\d('?[\d]+)*(p[+-]?\d('?\d+)*)?[fl]?\b(?!\.)} 0:value

# character literals (no multi-character literals)
add-highlighter shared/ccpp/code/char regex %{(\b(u8|u|U|L)|\B)'((\\.)|[^'\\])'\B} 0:value

evaluate-commands %sh{
    # Grammar
    keywords='alignas alignof and and_eq asm atomic_cancel atomic_commit
    		atomic_noexcept auto bitand bitor bool break case catch char char_8_t
    		char16_t char32_t class compl concept const consteval constexpr constinit
    		const_cast continue co_await co_return co_yield decltype default delete
    		do double dynamic_cast else enum explicit export extern false float for
    		friend goto if inline int long mutable namespace new noexcept not not_eq
    		nullptr operator or or_eq private protected public reflexpr register
    		reinterpret_cast requires return short signed sizeof static static_assert
    		static_cast struct switch synchronized template this thread_local throw
    		true try typedef typeid typename union unsigned using virtual void
    		volatile wchar_t while xor xor_eq int8_t int16_t int32_t int64_t uint8_t
        uint16_t uint32_t uint64_t intptr_t uintptr_t nullptr_t size_t'

    join() { sep=$2; eval set -- $1; IFS="$sep"; echo "$*"; }

    # Highlight keywords
    printf %s "
        #add-highlighter shared/ccpp/code/calls regex \b[a-z][a-zA-Z0-9_]*(?=\() 0:function
        #add-highlighter shared/ccpp/code/members regex (?<=\.)\w+\b 0:function
        #add-highlighter shared/ccpp/code/members2 regex (?<=->)\w+\b 0:function
        #add-highlighter shared/ccpp/code/members3 regex (?<=::)\w+\b 0:function
        #add-highlighter shared/ccpp/code/privates regex \b[a-z]\w*_\b 0:function
        add-highlighter shared/ccpp/code/types regex \b[A-Z][a-zA-Z0-9]*\b 0:type
        add-highlighter shared/ccpp/code/values regex \bNULL\b 0:value
        add-highlighter shared/ccpp/code/keywords regex \b($(join "${keywords}" '|'))\b 0:keyword
    "
}
