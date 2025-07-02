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
# Command pattern: Pararel execution by xargs
echo "aaa bbb ccc ddd eeee fff gggg hhh iii jjj" |awk -v RS=" " '{print}' |sed '$d' |xargs -P5 -IXXX echo XXX



# shell script - Parallelize a Bash FOR Loop - Unix & Linux Stack Exchange
# https://unix.stackexchange.com/questions/103920/parallelize-a-bash-for-loop
#------------------------
# Command pattern: Pararel execution by for loop
# bach -c ... : main command
MAX_PROCESS=5; (i=0; for v in $(seq 1 50); do ((i=i%MAX_PROCESS)); ((i++==0)) && wait;     bash -c "sec=$(echo $((RANDOM%10))); echo ${v} \${sec}; sleep \${sec}" &     done; wait )


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
echo "input.tsv,10" |awk -F',' '{ system("split -b $(expr $(stat -f%z "$1")  / "$2" + 1) "$1" "$1"_part_") }'



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

# Calculate rate rows regex matched from all rows.
echo -e "aaa\tOK\nbbb\tOK\nccc\tNG" |awk -F"\t" 'NR>0{all+=1}$2~/.*NG/{ng+=1}END{ printf "%.2f\n", ng/all*100 }'
33.33



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









## Line handling

```bash
# Joins multiple lines
$ echo -e "aaa\nbbb\nccc\nddd" |awk '{printf "%s%s",sep,$0; sep=","}'; echo
aaa,bbb,ccc,ddd





# Joins multiple lines and add prefix and suffix.
$ echo -e "aaa\nbbb\nccc\nddd" |awk 'NR==1{printf "{ "}{printf "%s%s",sep,$0; sep=","}END{print " }"}'
{ aaa,bbb,ccc,ddd }





# Adds new line every 2 lines.
echo -e "1111\n2222\n3333\n4444" |awk '{if(NR%2)ORS="\n";else ORS="\n\n";print}'
1111
2222

3333
4444





# Joins 2 lines every 2 lines.
echo -e "1111\n2222\n3333\n4444" |awk '{if(NR%2)ORS=",";else ORS="\n";print}'
1111,2222
3333,4444





# Random sort lines
echo -e "aaa\nbbb\nccc\nddd" |perl -e 'print sort { (-1,1)[rand(2)] } <>'
aaa
bbb
ddd
ccc
```











## Utility

```bash
#!/bin/bash

#------------------------
# Random number generated by Perl ( length:32 )
$ perl -e 'print map { (0..9)[rand 10] } 1..32; print "\n";'
94597601423601907608394880857248

#------------------------
# Random string generated by Perl ( length:32 )
$ perl -e 'print map { ("a".."z", "A".."Z", 0..9)[rand 62] } 1..32; print "\n";'
dogxgIOaXc7iUGVwjctAGowFg9er6ztw
$ perl -e 'print map { ("a".."z", 0..9)[rand 36] } 1..32; print "\n";'
9jalthxjg6ulcfogg3p5oaw5ah1070ew

#------------------------
# Multiple random strings generated by Perl
$ perl -e 'for (1..5) { print map { ("a".."z", 0..9)[rand 36] } 1..32; print "\n" }'
d2j08g7hryrtkdzl4uxm7sjsz1wsh05g
mzo18r1yx88prod1xulodprs2bvxquuf
3zohmo8khbtb43feh0n7iukdc4xgdbjh
as75ydb683pbyjkv25qx2rfyavue6xtf
qt5vm8hfy0wilddt1jlizdd9tyqmrktw








#------------------------
# Random number
# [number]
echo $RANDOM # 0～32767までの範囲で出力する
echo $((RANDOM%100+101)) # 100～200までの範囲で出力する
# How to generate random numbers in Bash | FOSS Linux
# https://www.fosslinux.com/93771/generate-random-numbers-in-bash.htm
MIN=0; MAX=10; echo $(( $(( $RANDOM % $(($MAX-$MIN+1)) )) + $MIN )) # 0～10までの範囲で出力する

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



#------------------------
# Print battery capacity
# MacBook Proのバッテリーの劣化を調べる方法【Big Sur】 | one euro https://oneuro.net/macbook-pro-battery-health
$ ioreg -c AppleSmartBattery | grep -i Capacity |awk '{printf "%s%s",sep,$0; sep=","}' |perl -pe 's/^.*(\"AppleRawMaxCapacitpacity\" = \d+).*$/\1\n\2\n/g'
"AppleRawMaxCapacity" = 4299
"DesignCapacity" = 5088






#------------------------
# Create dummy file
$ dd if=/dev/zero of=/tmp/dummyFile1GB.zip bs=1024k count=1024





#------------------------
# Send a notification to Mac based on the value received from the server.
$ curl -N -s -H "Accept: text/event-stream" https://server-sent-events-example.vercel.app/api/events-for-vercel \
|grep --line-buffered "た" \
|sed -u "s/data: /data=/g" \
| while read line; do osascript -e "display notification \"Line: ${line}\" with title \"Test title\""; done
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



#------------------------
# Exec command in background
nohup ./app -p 8080 > app.log 2>&1 &



#------------------------
# Exec command in background ( limited resource )
# -m 1048576 = 1024 * 1024 (kb) = 1G Memory 
(ulimit -m 1048576; nohup ./app -p 8080 > app.log 2>&1) &
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
# Parse json by python2.7
echo '{"name":"taro","age":16,"tags":["aaa","bbb","ccc"]}' | python -c "import sys, json; print json.load(sys.stdin)['tags'][0]"
aaa


#------------------------
# Parse json by python3.9
echo '{"name":"taro","age":16,"tags":["aaa","bbb","ccc"]}' | python -c "import sys, json; print(json.load(sys.stdin)['tags'][0])"
aaa
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
aaa


#------------------------
# Parse yaml by pytho2.7
yum install -y python-yaml
echo -e "name: taro\nage: 16\ntags:\n  - aaa\n  - bbb\n  - ccc" |python -c 'import sys, yaml; print yaml.load(sys.stdin)["tags"][0]'
aaa


#------------------------
# Parse yaml by pytho3.9
dnf install python
dnf install python3-pip
python3 -m pip install pyyaml
echo -e "name: taro\nage: 16\ntags:\n  - aaa\n  - bbb\n  - ccc" |python3 -c 'import sys, yaml; print(yaml.load(sys.stdin,Loader=yaml.Loader)["tags"][0])'
aaa
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
