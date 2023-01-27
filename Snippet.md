# Snippet

## Basic

```bash
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
echo 'test '"'"'#111111'"'"' -bg '"'"'#111111'"'"
#          ^^^^^       ^^^^^     ^^^^^       ^^^^
#          12345       12345     12345       1234
# => echo 'test ' + "'" + '#111111' + "'" + ' -bg ' + "'" + '#111111' + "'"


#------------------------
# Repeat command execution
seq 10 |xargs -I{} curl -G "https://httpbin.org/get"
# Parallel
seq 10 |xargs -I{} -P3 curl -G "https://httpbin.org/get"



#------------------------
# Command pattern: Pararel execution
echo "aaa bbb ccc ddd eeee fff gggg hhh iii jjj" |awk -v RS=" " '{print}' |sed '$d' |xargs -P5 -IXXX echo XXX



#------------------------
# Command pattern: awk argument ( escape " => \", escape " in \"\" => \\\", variables => "$1" )
echo "1,10,arg1,arg2" |awk -F',' '{ system("seq -f \"%02g\" "$1" "$2" |xargs -I{} bash -c \"sleep 1; echo -n \\\"{} \\\"; echo \\\" "$3", "$4" \\\" \"") }'

```










## Array

```bash
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

```bash
#!/bin/bash

#------------------------
# If one line
VAR_A="false"
if [[ "${VAR_A}" == "true" ]]; then echo "ok"; else echo "ng"; fi


#------------------------
# Exists variable
[[ "${VAR_A+x}" == "" ]] && { echo "=> var VAR_A is not defined."; }


#------------------------
# Multiple If one line
{ [[ 10 -le 10 ]] && [[ -e "/tmp/aaa.txt" ]]; } && { echo "A && B = true"; }


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
ls -a |xargs -I{} echo $(pwd)/{}
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
[[ -e "/tmp/aaa.txt" ]] && { echo "=> file /tmp/aaa.txt exists."; }



#------------------------
# Rename files by rules
for i in $(find * -type f -name '*.java'); do FROM=${i}; TO=`echo ${i} |sed 's/aaa/bbb/g'`; mv ${FROM} ${TO}; done
```










## String

```bash
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
# Extract matched start and end strings (Shortest match)
echo '"aaa":"bbb","ccc":"ddd ( " , "x","111":"222","eee":"fff","ggg":aaaa"' |perl -pe 's/^.*"ccc":"(.*?)",".*$/\1/g'
ddd ( " , "x


#------------------------
# Delete matched string first time only
echo "/aaa/bbb/ccc:{aaa:bbb,ccc:ddd}" |sed 's/.*ccc:{/{/1'
{aaa:bbb,ccc:ddd}



#------------------------
# Replace \n to new lines
# pattern 1 https://stackoverflow.com/questions/10748453/replace-comma-with-newline-in-sed-on-macos?rq=1
echo "aaa\nbbb\nccc" | sed -e $'s/\\\\n/\\\n/g'
aaa
bbb
ccc

# pattern 2
echo "aaa\nbbb\nccc" | sed 's/\\n/\'$'\n/g'
aaa
bbb
ccc



#------------------------
# Delete empty lines
cat test |sed '/^$/d' 



#------------------------
# Delete new lines ( Multiple lines to One line )
echo -e "aaa\nbbb\nccc" | awk '{ printf "%s", $0 } END { print "" }'
aaabbbccc



#------------------------
# Match not xxx lines then replace by regex
echo -e "aaaa\n/bbbb\nccccc" |sed "/^\//! s/^/\//g"



#------------------------
# Substr parsed colmn value
echo -e "aaa\t%bbb\tccc\naaa\t%ddd\tccc" |awk '{ print $1, substr($2, 2), $3}'
aaa bbb ccc
aaa ddd ccc

echo -e "aaa\t%bbb\tccc\naaa\t%ddd\tccc" |awk '{ print $1, substr($2, 2, 2), $3}'
aaa bb ccc
aaa dd ccc

echo -e "aaa\t%bbb\tccc\naaa\t%ddd\tccc" |awk '{ print $1, substr($2, 0, 2), $3}'
aaa %b ccc
aaa %d ccc




#------------------------
# Trim whitespace
echo "   aaaa  " |perl -pe 's/^\s+|\s+$//g'
```










## Calc

```bash
#!/bin/bash

#------------------------
# Calc
awk 'BEGIN {print 10 * (20 + 10) / 12398}'
0.0241975
awk 'BEGIN {printf "%.3f\n", 10 * (20 + 10) / 12398}'
0.024
awk 'BEGIN {printf "%.0f\n", 10 * 20 + 10}'
210

echo "10 * (20 + 10) / 12398" |xargs -I{} bash -c 'printf "%.3f\n" $(awk "BEGIN {print {}}")'
0.024



#------------------------
# Group by and sum
echo -e "aaa\t10\naaa\t20\naaa\t15\nbbb\t1.2\nbbb\t2.86\nbbb\t99.01" |awk '{map[$1]+=$2;} END { for(i in map){ print i, map[i];} }'
bbb 103.07
aaa 45

# Group by and sum and count
echo -e "aaa\t10\naaa\t20\naaa\t15\nbbb\t1.2\nbbb\t2.86\nbbb\t99.01" |awk '{map[$1]+=$2;mapCount[$1]++;} END { for(i in map){ print i, map[i], mapCount[i];} }'
bbb 103.07 3
aaa 45 3

# Group by and average
echo -e "aaa\t10\naaa\t20\naaa\t15\nbbb\t1.2\nbbb\t2.86\nbbb\t99.01" |awk '{map[$1]+=$2;mapCount[$1]++;} END { for(i in map){ print i, map[i] / mapCount[i];} }'
bbb 34.3567
aaa 15



#------------------------
# Filter by numbers
echo -e "aaa\t10\naaa\t20\naaa\t15\nbbb\t1.2\nbbb\t2.86\nbbb\t99.01" |awk '{if($2 > 10 && $2 < 50) print}'
aaa	20
aaa	15
```









## Date and Time

```bash
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

```bash
#!/bin/bash

#------------------------
# Random number
# [number]
echo $RANDOM # 0～32767までの範囲で出力する
echo $((RANDOM%100+101)) # 100～200までの範囲で出力する



#------------------------
# Random string [base64] ( length:32 )
$ openssl rand -base64 24 |cut -c -32
FJV1byUp5HISiXaVhHvnCj4J9YWTjPue



#------------------------
# Random string [hex] ( length:32 )
$ openssl rand -hex 16
310b39affede98f2c8f4ab3f331b0aac



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

```bash
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
# Parse json by perl
echo '{"name":"taro","age":16,"tags":["aaa","bbb","ccc"]}' |perl -MJSON -MData::Dumper -e 'print Dumper(decode_json(<STDIN>)->{tags}[0])'
$VAR1 = 'aaa';
echo '{"name":"taro","age":16,"tags":["aaa","bbb","ccc"]}' |perl -MJSON -e 'print decode_json(<STDIN>)->{tags}[0]'
aaa
echo '{"name":"taro","age":16,"tags":["aaa","bbb","ccc"]}' |perl -MJSON -e 'print scalar @{decode_json(<STDIN>)->{tags}}'
3

#------------------------
# Parse json by python
echo '{"name":"taro","age":16,"tags":["aaa","bbb","ccc"]}' | python -c "import sys, json; print json.load(sys.stdin)['tags'][0]"
```










## Yaml

```
# centos
# * How to install YAML.pm? | ResearchGate https://www.researchgate.net/post/How-to-install-YAMLpm
# * command-not-found.com – cpanm https://command-not-found.com/cpanm
yum -y install cpanminus
cpanm YAML
cpanm YAML::PP
```

```bash
#------------------------
# Parse yaml by perl
# Read value 
echo -e "aaa:\n  bbb:\n    - a\n    - b\n    - c" |perl -MYAML="Load" -MData::Dumper -e 'print Dumper(Load(join "", <STDIN>)->{"aaa"}->{"bbb"}[0])'
$VAR1 = 'a';

# -E: enable 'say' function that adds new line to last string.
echo -e "aaa:\n  bbb:\n    - a\n    - b\n    - c" |perl -MYAML="Load" -E 'say Load(join "", <STDIN>)->{"aaa"}->{"bbb"}[0]'
a

# Print list size
echo -e "aaa:\n  bbb:\n    - a\n    - b\n    - c" |perl -MYAML="Load" -E 'say scalar @{Load(join "", <STDIN>)->{"aaa"}->{"bbb"}}'
3

# Print keys ( YAML::PP keeps hash keys order )
echo -e "aaa:\n  bbb: null\n  ccc: null\n  ddd: null" |perl -MYAML::PP -MYAML::PP::Common=":PRESERVE" -E '$p=YAML::PP->new(preserve=>PRESERVE_ORDER);say join("\n", keys %{$p->load_string(join("",<STDIN>))->{"aaa"}});'
bbb
ccc
ddd

# Print quoted string ( YAML::PP keeps string quotes )
echo -e "aaa:\n  bbb: null\n  ccc: \"string\"\n  ddd: 'string'" |perl -MYAML::PP -MYAML::PP::Common=":PRESERVE" -e '$p=YAML::PP->new(preserve=>PRESERVE_SCALAR_STYLE);$y=$p->load_string(join("",<STDIN>));print $p->dump_string($y);'
---
aaa:
  bbb: null
  ccc: "string"
  ddd: 'string'

# Update value
echo -e "aaa:\n  bbb: null\n  ccc: \"string\"\n  ddd: 'string'" |perl -MYAML::PP="Load" -MYAML::PP="Dump" -e '$y=Load(join("",<STDIN>));$v="update";$y->{"aaa"}->{"bbb"}=$v;print Dump $y;'
---
aaa:
  bbb: update
  ccc: string
  ddd: string


#------------------------
# Parse yaml by ruby
echo -e "name: taro\nage: 16\ntags:\n  - aaa\n  - bbb\n  - ccc" |ruby -ryaml -e "puts YAML.load(STDIN.read)['tags'][0]"
```


## Perl

```perl
# Get command line arguments (-E: enable 'say' function that adds new line to last string.)
perl -E '$a=@ARGV[0]; say $a' aaaa
aaaa

# Set variable from command line parameters. (-s)
perl -sE 'say $s' -- -s="aiueo"

# use module ( use YAML::PP )
perl -MYAML::PP -e '$p=YAML::PP->new;'

# use module omitting ( use YAML::PP, use use YAML::PP::Common qa/ :PRESERVE /  )
perl -MYAML::PP -MYAML::PP::Common=":PRESERVE" -e '$p = YAML::PP->new( preserve => PRESERVE_ORDER )'

# Read all stdin as string variable
echo -e "aaa:\n  bbb:\n    - a\n    - b\n    - c" |perl -e '$s=join("", <STDIN>); print $s'
aaa:
  bbb:
    - a
    - b
    - c


```
