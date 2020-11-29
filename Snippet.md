# Snippet

## Basic

```
#!/bin/bash

#------------------------
# Print by set mode
sh -x ./run.sh # Print execute commands
sh -e ./run.sh # Stop on error
sh -u ./run.sh # Stop on read undefined variable



#------------------------
# Redirect stderr and stdout
sh -x ./run.sh &> out.txt



#------------------------
# Redirect all /dev/null
command > /dev/null 2>&1



#------------------------
# Escape single quote in single quote
alias rxvt='urxvt -fg '"'"'#111111'"'"' -bg '"'"'#111111'"'"
 #                     ^^^^^       ^^^^^     ^^^^^       ^^^^
 #                     12345       12345     12345       1234



#------------------------
# Command pattern: Pararel execution
echo "aaa bbb ccc ddd eeee fff gggg hhh iii jjj" |awk -v RS=" " '{print}' |sed '$d' |xargs -P5 -IXXX echo XXX



#------------------------
# Command pattern: awk argument ( escape " => \", escape " in \"\" => \\\", variables => "$1" )
echo "1,10,arg1,arg2" |awk -F',' '{ system("seq -f \"%02g\" "$1" "$2" |xargs -I{} bash -c \"sleep 1; echo -n \\\"{} \\\"; echo \\\" "$3", "$4" \\\" \"") }

```










## Array

```
#!/bin/bash

#------------------------
# Array
STRINGS=()
STRINGS+=( a )
STRINGS+=( i )
STRINGS+=( u )
echo "Array count: ${#STRINGS[@]}"
echo "Array values: ${STRINGS[@]}"
echo "Array values[0]: ${STRINGS[0]}"



#------------------------
# Copy array to array
LIST_VAR=("$@")



#------------------------
# For (array)
for STRING in "${STRINGS[@]}"; do
    echo "${STRING}"
done



#------------------------
# While in variable
LINE_COUNT=0
while read LINE || [[ "${LINE}" != "" ]];
do
  LINE_COUNT=$(( LINE_COUNT + 1 ))
done < <(cat "/tmp/aaa.txt")
echo "${LINE_COUNT}"
```











## If

```
#!/bin/bash

#------------------------
# Exists variable
[[ "${VAR_A+x}" == "" ]] && { echo "=> var VAR_A is not defined."; }



#------------------------
# Multiple If one line
{ [[ 10 -le 10 ]] && [[ -e "/tmp/aaa.txt" ]]; } && { echo "=> file PARAM_A exists."; }



#------------------------
# X > Y
[[ 10 -gt 5 ]] && { echo "10 > 5"; }
[[ 5 -lt 10 ]] && { echo "5 < 10"; }
[[ 10 -ge 10 ]] && { echo "10 >= 10"; }
[[ 10 -le 10 ]] && { echo "10 <= 10"; }
```











## Path

```bash
#!/bin/bash

#------------------------
# Get path ( script directory )
SCRIPT_DIR="$(cd $(dirname "${BASH_SOURCE:-$0}") && pwd)"
# => /path/to/script_dir



#------------------------
# Get script file name
BASH_SOURCE_PATH=${BASH_SOURCE:-$0}
SCRIPT_FILE_NAME=${BASH_SOURCE_PATH##*/}
# => script.sh



#------------------------
# Show full path file list
ls -altR -d $(find `pwd`)
```











## File

```bash
#!/bin/bash

#------------------------
# Read lines from file
while read LINE || [[ "${LINE}" != "" ]];
do
  echo "${LINE}"
done < <(cat "/tmp/aaa.txt")



#------------------------
# Safety temp file
BASH_SOURCE_PATH=${BASH_SOURCE:-$0}
SCRIPT_FILE_NAME=${BASH_SOURCE_PATH##*/}
TMP_FILE_PATH=`mktemp /tmp/temp.${SCRIPT_FILE_NAME}.XXXXXXXXXXXX`
trap "{ rm -f ${TMP_FILE_PATH}; }" EXIT SIGINT



#------------------------
# Split file
echo "input.tsv,10" |awk -F',' '{ system("split -l $(expr $(cat "$1" |wc -l)  / "$2" + 1) "$1" "$1"_part_") }'



#------------------------
# Check if a file exists
[[ -e "/tmp/aaa.txt" ]] && { echo "=> file PARAM_A exists."; }



#------------------------
# Rename files by rules
for i in $(find * -type f -name '*.java'); do FROM=${i}; TO=`echo ${i} |sed 's/aaa/bbb/g'`; mv ${FROM} ${TO}; done
```










## String

```
#!/bin/bash

#------------------------
# CamelCase to SnakeCase
echo "aaaBbbCcc" | perl -ne 'print lc(join("_", split(/(?=[A-Z])/)))'
aaa_bbb_ccc



#------------------------
# SnakeCase to CamelCase
echo "aaa_bbb_ccc" | perl -pe 's/(?:^|_)(.)/\U$1/g'
AaaBbbCcc



#------------------------
# Lowercase to UpperCase
echo "aaa" |awk '{print toupper($1)}'
AAA



#------------------------
# Split string
STRING="aaa,bbb"
VAR1=$(echo "${STRING}" | cut -f1 -d,)



#------------------------
# Extract matched start and end strings
echo '... "artistId":462006, ... "artistName":"ボブ・ディラン", ... "artistViewUrl":"https://itunes.apple.com/jp/artist/...?uo=4" ...' |sed -E 's/^.*("artistId":)([0-9]*).*("artistName":")([^"]*).*("artistViewUrl":")([^"]*).*$/\2 | \4 | \6/g'
462006 | ボブ・ディラン | https://itunes.apple.com/jp/artist/...?uo=4



#------------------------
# Delete matched string first time only
echo "/aaa/bbb/ccc:{aaa:bbb,ccc:ddd}" |sed 's/.*ccc:{/{/1'
{aaa:bbb,ccc:ddd}



#------------------------
# Replace \n to new lines
echo "aaa\nbbb\nccc" | sed 's/\\n/\'$'\n/g'
aaa
bbb
ccc



#------------------------
# Delete empty lines
cat test |sed '/^$/d' 



#------------------------
# Match NOT xxx lines
echo -e "aaaa\n/bbbb\nccccc" |sed "/^\//! s/^/\//g"
```










## Calc

```bash
#!/bin/bash

#------------------------
# Calc
echo $(awk "BEGIN {print 10 * (20 + 10) / 12398}")
0.0241975
echo $(printf "%.3f" $(awk "BEGIN {print 10 * (20 + 10) / 12398}"))
0.024
echo $(printf "%.0f" $(awk "BEGIN {print 10 * 20 + 10}"))
210
echo "10 * (20 + 10) / 12398" |xargs -I{} bash -c 'printf "%.3f\n" $(awk "BEGIN {print {}}")'
0.024
```









## Date and Time

```
#!/bin/bash

#------------------------
# Get today
TODAY=$(date +"%Y-%m-%d %H:%M:%S")



#------------------------
# Get unix timestamp
perl -le 'print time'; 
date +%s
# => 1605979241



#------------------------
# Convert unix timestamp to date
echo "1605976367" | perl -le 'my $in=<STDIN>; chomp $in; $ts=$in; $ats=$ts*(10**(10-length($ts))); @t=localtime($ats); $,=","; printf("%d-%02d-%02d %02d:%02d:%02d\n",@t[5]+1900,@t[4]+1,@t[3],@t[2],@t[1],@t[0])'



#------------------------
# Sequential days
d="20150120"; while [[ "${d}" != "20150220" ]]; do echo $d; d=$(date -j -f %Y%m%d -v+1d ${d} +%Y%m%d); done



#------------------------
# Stopwatch
SECONDS=0
sleep 3
echo "Sleep ${SECONDS} [sec]"
```










## Utility

```
#!/bin/bash

#------------------------
# Random number
# [number]
echo $RANDOM # 0～32767までの範囲で出力する
echo $((RANDOM%100+101)) # 100～200までの範囲で出力する



#------------------------
# Random string [base64]
openssl rand -base64 15 | fold -w 15 |head -n 1
yWeZes91kn/pd40



#------------------------
# Random string [hex]
openssl rand -hex 15 | fold -w 15 |head -n 1
924aa2f665ebb1a



#------------------------
# Sequential number
awk 'BEGIN{for(i=0; i<2; i++){ printf("%-2.2d\n",i); } }'
00
01
awk 'BEGIN{ for(i=0; i<2; i++){ for(j=0; j<2; j++){ printf("%-2.2d\t%-2.2d\n",i,j); } } }'
00	00
00	01
01	00
01	01



#------------------------
# Print colored string func
function printColored() { local B="\033[0;"; local C=""; case "${1}" in "red") C="31m";; "green") C="32m";; "yellow") C="33m";; "blue") C="34m";; esac; printf "%b%b\033[0m" "${B}${C}" "${2}"; }
printColored yellow "test"

```










## Server

```
#!/bin/bash

#------------------------
# Execute local bash script to server
ssh hostname 'bash -s' < localscript.sh



#------------------------
# Check host and port
timeout 2 bash -c "</dev/tcp/canyouseeme.org/80"; echo $?
```










## Json

```bash
#------------------------
# Parse json by python
echo '{"name":"taro","age":16,"tags":["aaa","bbb","ccc"]}' | python -c "import sys, json; print json.load(sys.stdin)['tags'][0]"
```










## Yaml

```bash
#------------------------
# Parse yaml by ruby
echo -e "name: taro\nage: 16\ntags:\n  - aaa\n  - bbb\n  - ccc" |ruby -ryaml -e "puts YAML.load(STDIN.read)['tags'][0]"
```
```
