#!/bin/bash

function usage()
{
cat << _EOT_

 syntax
----------- author: xshoji

This is syntax.

Usage:
  ./$(basename "$0") --paramA aaa --paramB bbb [ --paramC ccc --check ]

Required:
  -p, --paramA aaa : Parameter A.
  --paramB bbb     : Parameter B.

Optional:
  --paramC ccc : Parameter C.
  -c, --check : Flag parameter.

Helper options:
  --help, --debug

_EOT_
  [[ "${1+x}" != "" ]] && { exit "${1}"; }
  exit 1
}
function printColored() { C=""; case "${1}" in "Yellow") C="\033[0;33m";; "Green") C="\033[0;32m";; esac; printf "%b%b\033[0m" "${C}" "${2}"; }



#------------------------------------------
# Preparation
#------------------------------------------
set -eu

# Parse parameters
for ARG in "$@"
do
    SHIFT="true"
    [[ "${ARG}" == "--debug" ]] && { shift 1; set -eux; SHIFT="false"; }
    { [[ "${ARG}" == "--paramA" ]] || [[ "${ARG}" == "-p" ]]; } && { shift 1; PARAM_A="${1}"; SHIFT="false"; }
    [[ "${ARG}" == "--paramB" ]] && { shift 1; PARAM_B="${1}"; SHIFT="false"; }
    [[ "${ARG}" == "--paramC" ]] && { shift 1; PARAM_C="${1}"; SHIFT="false"; }
    { [[ "${ARG}" == "--check" ]] || [[ "${ARG}" == "-c" ]]; } && { shift 1; CHECK="true"; SHIFT="false"; }
    { [[ "${ARG}" == "--help" ]] || [[ "${ARG}" == "-h" ]]; } && { shift 1; HELP="true"; SHIFT="false"; }
    { [[ "${SHIFT}" == "true" ]] && [[ "$#" -gt 0 ]]; } && { shift 1; }
done
[[ -n "${HELP+x}" ]] && { usage 0; }
# Check required parameters
[[ -z "${PARAM_A+x}" ]] && { printColored Yellow "[!] --paramA is required.\n"; INVALID_STATE="true"; }
[[ -z "${PARAM_B+x}" ]] && { printColored Yellow "[!] --paramB is required.\n"; INVALID_STATE="true"; }
# Check invalid state and display usage
[[ -n "${INVALID_STATE+x}" ]] && { usage; }
# Initialize optional variables
[[ -z "${PARAM_C+x}" ]] && { PARAM_C=""; }
[[ -z "${CHECK+x}" ]] && { CHECK="false"; }



#------------------------------------------
# Main
#------------------------------------------



# set -e : 何らかのエラーが発生した時点で、それ以降の処理を中断する ことができます。
# set -u : 未定義の変数に対して読み込み等を行おうとした際に、きちんとエラーとして扱ってくれます。
# set -x : 実行したコマンドを、全て標準エラー出力に出してくれる
# set -eu


#-------------------------------------------------------------------------------------
# @see bash - 2>&1はどういう意味？(1285)｜teratail https://teratail.com/questions/1285
# stdout is written to file:
#   $ ./$(basename "$0") --param_a aaa --param_b bbb --param_c ccc --check 1> temp.txt
#
# stderr is written to file:
#   $ ./$(basename "$0") --param_a aaa --param_b bbb --param_c ccc --check 2> temp.txt
#
# stdout and stderr are written to separeted files:
#   $ ./$(basename "$0") --param_a aaa --param_b bbb --param_c ccc --check 1> temp_stdout.txt 2> temp_stderr.txt
#
# stdout and stderr are written to same file:
#   $ ./$(basename "$0") --param_a aaa --param_b bbb --param_c ccc --check > temp.txt 2>&1
#-------------------------------------------------------------------------------------


# If the var is not defined, you can set default value to the var.
#: ${CHECK:="false"}
#: ${PARAM_C:=}


# Get absolute directory path of this script
# @see http://qiita.com/yudoufu/items/48cb6fb71e5b498b2532 bash/zshでsourceされたスクリプト内で、ファイル自身の絶対パスをとるシンプルな記法 - Qiita
# /path/to/script_dir
SCRIPT_DIR="$(cd $(dirname "${BASH_SOURCE:-$0}") && pwd)"
# /path/to
SCRIPT_DIR_UPPER="$(cd $(dirname "${BASH_SOURCE:-$0}")/.. && pwd)"
# @see http://d.hatena.ne.jp/ozuma/20130928/1380380390 shとbashでの変数内の文字列置換など - ろば電子が詰まっている
# SCRIPT_FILE_NAME=${0/'./'/''}
# > bash - Grab the filename in Unix out of full path - Stack Overflow
# > https://stackoverflow.com/questions/10124314/grab-the-filename-in-unix-out-of-full-path
BASH_SOURCE_PATH=${BASH_SOURCE:-$0}
SCRIPT_FILE_NAME=${BASH_SOURCE_PATH##*/}

TODAY="$(date +"%Y-%m-%d %H:%M:%S")"


# @see linux bash, camel case string to separate by dash - Stack Overflow http://stackoverflow.com/questions/8502977/linux-bash-camel-case-string-to-separate-by-dash
if sed --version 2>/dev/null | grep -q GNU; then
  PARAM_A_SNAKE=$(sed -e 's/\([A-Z]\)/_\L\1/g' -e 's/^_//'  <<< "${PARAM_A}")
else
  PARAM_A_SNAKE=$(echo ${PARAM_A} | perl -ne 'print lc(join("_", split(/(?=[A-Z])/)))')
fi


# @see shell script - Convert underscore to PascalCase, ie UpperCamelCase - Unix & Linux Stack Exchange http://unix.stackexchange.com/questions/196239/convert-underscore-to-pascalcase-ie-uppercamelcase
# @see Linux（GNU）とMac（BSD）のsedの振る舞いの違いを解決 - Qiita http://qiita.com/narumi_/items/e9d4ed4dc8947d56a66f
if sed --version 2>/dev/null | grep -q GNU; then
  PARAM_A_CAMEL=$(sed -r 's/(^|_)([a-z])/\U\2/g' <<< "${PARAM_A}")
else
 # @see PerlでCamelize/DeCamelize - kawamuray's blog http://kawamuray.hatenablog.com/entry/2013/08/12/154443
  PARAM_A_CAMEL=$(echo "${PARAM_A}" | perl -pe 's/(?:^|_)(.)/\U$1/g')
  # PARAM_A_CAMEL=$(sed -E 's/(^|_)([a-z])/\U\2/g' <<< "${PARAM_A}")
fi

#  - [［awk］大文字交じりのファイル名を小文字に変換する - Qiita](https://qiita.com/_shimizu/items/db30c8889de7b911f207)
# aaa -> AAA
STRING="aaa"
STRING_UPPER=$(echo "${STRING}" |awk '{print toupper($1)}')
echo "${STRING} toupper ${STRING_UPPER}"
# AAA -> aaa
STRING_LOWER=$(echo "${STRING_UPPER}" |awk '{print tolower($1)}')
echo "${STRING_UPPER} toupper ${STRING_LOWER}"



#==========================================
# main
#==========================================

COUNT=1

echo ""
echo ${COUNT}". count(array[])"
COUNT=$(( COUNT + 1 ))
echo "Argument count: $#"
# - [How To Find BASH Shell Array Length ( number of elements ) - nixCraft](https://www.cyberciti.biz/faq/finding-bash-shell-array-length-elements/)
STRINGS=()
STRINGS+=( a )
STRINGS+=( i )
STRINGS+=( u )
echo "Array count: ${#STRINGS[@]}"


echo ""
echo ${COUNT}". here string"
COUNT=$(( COUNT + 1 ))
# - [ヒアストリングとヒアドキュメント - Qiita](https://qiita.com/ogiw/items/ac77a3bbb813351099a1)
echo "aaa,bbb" |cut -d ',' -f 1
cut -d ',' -f 1 <<< "aaa,bbb"



# if (VAR_A === "aaa") echo "test"
# @see http://qiita.com/m-yamashita/items/889c116b92dc0bf4ea7d 初心者向け、「上手い」シェルスクリプトの書き方メモ - Qiita
#
echo ""
echo ${COUNT}". if strlen(PARAM_A) === 'aaa' : echo 'PARAM_A is aaa' ? echo 'PARAM_A is not aaa'"
COUNT=$(( COUNT + 1 ))
[ "${PARAM_A}" = "aaa" ] && echo 'PARAM_A is aaa' || echo 'PARAM_A is not aaa'




# if !is_defined(VAR_A)
# if is_defined(VAR_A)
# @see http://luna2-linux.blogspot.jp/2014/05/bash.html ALL about Linux: bash でシェル変数が定義されているかを判定する方法は？
echo ""
echo ${COUNT}". if is_defined(VAR_A)"
COUNT=$(( COUNT + 1 ))
if [ -z "${VAR_A+x}" ] ; then
    echo "=> var VAR_A is not defined."
fi
if [ ! -z "${VAR_A+x}" ] ; then
    echo "=> var VAR_A is defined."
fi





# if !is_defined(VAR_A) && !is_defined(VAR_B)
echo ""
echo ${COUNT}". if is_defined(VAR_A) && is_defined(VAR_B)"
COUNT=$(( COUNT + 1 ))
if [ -z "${VAR_A+x}" ] && [ -z "${VAR_B+x}" ]; then
    echo "=> var VAR_A and VAR_B are not defined."
fi





# if !is_defined(VAR_A) || !is_defined(PARAM_A)
echo ""
echo ${COUNT}". if is_defined(VAR_A) || is_defined(PARAM_A)"
COUNT=$(( COUNT + 1 ))
if [ -z "${VAR_A+x}" ] || [ -z "${PARAM_A+x}" ]; then
    echo "=> var VAR_A or VAR_B is not defined."
fi





# if strlen(PARAM_C) === 0
echo ""
echo ${COUNT}". if strlen(PARAM_C) === 0"
COUNT=$(( COUNT + 1 ))
if [ -z "${PARAM_C}" ] ; then
# if [ -n "${PARAM_C}" ] ; then
    echo "=> strlen(PARAM_C) === 0."
else
    echo "=> strlen(PARAM_C) > 0."
fi


# - [シェルスクリプト(bash)のif文とtestコマンド(［］)自分メモ - Qiita](https://qiita.com/toshihirock/items/461da0f60f975f6acb10)
echo ""
echo ${COUNT}". if 10 > 5, 5 < 10, 10 <= 10, 10 >= 10"
COUNT=$(( COUNT + 1 ))
if [ 10 -gt 5 ] ; then
    echo "10 > 5"
fi
if [ 5 -lt 10 ] ; then
    echo "5 < 10"
fi
if [ 10 -gt 5 ] ; then
    echo "10 > 5"
fi
if [ 10 -ge 10 ] ; then
    echo "10 >= 10"
fi
if [ 10 -le 10 ] ; then
    echo "10 <= 10"
fi



# if PARAM_A == PARAM_C
echo ""
echo ${COUNT}". if PARAM_A == PARAM_C"
COUNT=$(( COUNT + 1 ))
if [ "${PARAM_A}" = "${PARAM_C}" ] ; then
# if [ "${PARAM_A}" != "${PARAM_C}" ] ; then
    echo "=> PARAM_A == PARAM_C."
else
    echo "=> PARAM_A != PARAM_C."
fi





# if file_exists(PARAM_A)
echo ""
echo ${COUNT}". if file_exists(PARAM_A)"
COUNT=$(( COUNT + 1 ))
if [ -e "${PARAM_A}" ] ; then
# if [ ! -e "${PARAM_A}" ] ; then
    echo "=> file PARAM_A exists."
else
    echo "=> file PARAM_A not exists."
fi



# a + b - c * d / e
echo ""
echo ${COUNT}". a + b - c * d / e"
COUNT=$(( COUNT + 1 ))
echo "10 + 20 = "$(( 10 + 20 ))
echo "10 + 20 - 25 = "$(( 10 + 20 - 25 ))
echo "(10 + 20 - 25) * 40 = "$(( (10 + 20 - 25) * 40 ))
echo "(10 + 20 - 25) * 40 / 50 = "$(( (10 + 20 - 25) * 40 / 50 ))
# @see http://unix.stackexchange.com/questions/40786/how-to-do-integer-float-calculations-in-bash-or-other-languages-frameworks shell - How to do integer & float calculations, in bash or other languages/frameworks? - Unix & Linux Stack Exchange
# @see http://stackoverflow.com/questions/2395284/round-a-divided-number-in-bash linux - Round a divided number in Bash - Stack Overflow
round() {
    printf "%.$2f" "$1"
}
echo "1 / 3 = "$(round $(awk "BEGIN {print 1 / 3}") 3)


# Get random integer value
# - [コンソール上でランダムな数字(乱数)を出力させる方法8個 ｜ 俺的備忘録 〜なんかいろいろ〜](https://orebibou.com/2017/02/%E3%82%B3%E3%83%B3%E3%82%BD%E3%83%BC%E3%83%AB%E4%B8%8A%E3%81%A7%E3%83%A9%E3%83%B3%E3%83%80%E3%83%A0%E3%81%AA%E6%95%B0%E5%AD%97%E4%B9%B1%E6%95%B0%E3%82%92%E5%87%BA%E5%8A%9B%E3%81%95%E3%81%9B%E3%82%8B/)
echo ""
echo ${COUNT}". getRandomNumber N ~ M"
COUNT=$(( COUNT + 1 ))
echo $RANDOM # 0～32767までの範囲で出力する
echo $((RANDOM%+101)) # 0～100までの範囲で出力する
echo $((RANDOM%100+101)) # 100～200までの範囲で出力する


# Expansion variable " in '
echo ""
echo ${COUNT}". \" in \'"
COUNT=$(( COUNT + 1 ))
STRING='{"aaa", ${COUNT}, '${COUNT}', '"'"''${COUNT}''"'"'}'
echo ${STRING}

# Define array
STRINGS=()
STRINGS+=( a )
STRINGS+=( i )
STRINGS+=( u )





cat <<_EOT_

script_dir       : ${SCRIPT_DIR}
script_dir_upper : ${SCRIPT_DIR_UPPER}
today          : ${TODAY}
script_name    : ${SCRIPT_FILE_NAME}
param_a        : ${PARAM_A}
param_a snake  : ${PARAM_A_SNAKE}
param_a camel  : ${PARAM_A_CAMEL}
param_b        : ${PARAM_B}
param_c        : ${PARAM_C}
is_check_mode? : ${CHECK}

array   : ${STRINGS[@]}
array.0 : ${STRINGS[0]}
array.1 : ${STRINGS[1]}
array.2 : ${STRINGS[2]}

_EOT_





# # Define hash array
# declare -A HASH_STRINGS
# HASH_STRINGS["a"]=a
# HASH_STRINGS["b"]=b
# HASH_STRINGS["c"]=c
# cat <<_EOT_
# hash_array   : ${HASH_STRINGS[@]}
# hash_array.a : ${HASH_STRINGS["a"]}
# hash_array.b : ${HASH_STRINGS["b"]}
# hash_array.c : ${HASH_STRINGS["c"]}
# _EOT_





# > bashのSECONDS変数で簡単に処理時間を測定する - Qiita
# > https://qiita.com/mikeda/items/c6bb68dd1e4ba6434fb7
echo ""
echo ${COUNT}". simple time measurement"
COUNT=$(( COUNT + 1 ))
SECONDS=0
sleep 3
echo "Sleep ${SECONDS} [sec]"





# for loop
echo ""
echo ${COUNT}". for loop"
COUNT=$(( COUNT + 1 ))
echo "for ..."
for STRING in "${STRINGS[@]}"; do
    echo "${STRING}"
done
IFS_OLD=$IFS
IFS=$'\n'
LINE_COUNT=0
# 空行は無視される
for LINE in $(cat "${SCRIPT_FILE_NAME}"); do
    LINE_COUNT=$(( LINE_COUNT + 1 ))
done
IFS=${IFS_OLD}
echo "${LINE_COUNT}"
echo ""





# one line for
echo ""
echo ${COUNT}". one line for"
COUNT=$(( COUNT + 1 ))
for number in $(seq 1 10); do echo "${number}"; done
echo ""





# while loop
echo ""
echo ${COUNT}". while loop"
COUNT=$(( COUNT + 1 ))
# @see http://qiita.com/kawaz/items/6fd4cd86ca98af644a05 パイプ出力を現在のシェル上のwhileに喰わせる上手いやり方 - Qiita
# @see https://stackoverflow.com/questions/35419636/syntax-error-near-expected-token-using-process-substition bash - "syntax error near expected token" using process substition - Stack Overflow
# 最後の行だけ読み込まれない
# @see bash - Shell script read missing last line - Stack Overflow https://stackoverflow.com/questions/12916352/shell-script-read-missing-last-line
LINE_COUNT=0
while read LINE || [ -n "${LINE}" ];
do
  LINE_COUNT=$(( LINE_COUNT + 1 ))
done < <(cat "${SCRIPT_FILE_NAME}")
echo "${LINE_COUNT}"
echo ""





# one line while
echo ""
echo ${COUNT}". one line while"
COUNT=$(( COUNT + 1 ))
# while sleep 1; do date '+%Y-%m-%d %H:%M:%S' |md5 |cut -c -16 ; done
echo ""





# split string
echo ""
echo ${COUNT}". split string"
COUNT=$(( COUNT + 1 ))
STRING="aaa,bbb"
VAR1=$(echo $STRING | cut -f1 -d,)
VAR2=$(echo $STRING | cut -f2 -d,)
echo "STRING: ${STRING}"
echo "VAR1: ${VAR1}, VAR: ${VAR2}"





# split tsv file
# @see sed でタブを入力するには？ - mattintosh note http://mattintosh.hatenablog.com/entry/2013/01/16/143323
echo ""
echo ${COUNT}". split tsv"
COUNT=$(( COUNT + 1 ))
DELIPITER=$(printf '\t')
while IFS=${DELIPITER} read -r C1 C2 C3; do
  echo "first=${C1} | second=${C2} | third=${C3}"
done <<EOT
a,a a	b,b b	c  c  c
ddd	eee	fff
111 222 333
EOT





# bash - How to print "$" in here-document - Unix & Linux Stack Exchange http://unix.stackexchange.com/questions/68419/how-to-print-in-here-document
cat <<_EOT_

    /**
     * Set ${PARAM_A_SNAKE}
     *
     * @param string ${PARAM_A_SNAKE}
     * @return \$this
     */
    public function set${PARAM_A_CAMEL}(\$${PARAM_A_SNAKE})
    {
        \$this->${PARAM_A_SNAKE} = \$${PARAM_A_SNAKE};
        return \$this;
    }

_EOT_


# STARTER_URL=https://raw.githubusercontent.com/xshoji/bash-script-starter/develop/ScriptStarter.sh
# curl -sf ${STARTER_URL} |bash -s - \
#   -n syntax \
#   -a xshoji \
#   -r paramA,aaa,"Parameter A." \
#   -r paramB,bbb,"Parameter B." \
#   -o paramC,ccc,"Parameter C." \
#   -f check,"Flag parameter." \
#   -s > /tmp/test.sh; open /tmp/test.sh



