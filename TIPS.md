# ランダムな文字列を１０個一気に生成する

```
// for版
for ((i=0; i < 10; i++)); do openssl rand -base64 12 | fold -w 10 | head -1; done
// seq版
seq 1 10 |xargs -I{} bash -c "openssl rand -base64 12 | fold -w 13 | head -1"
```

ちなみに出力するランダム文字列の種別も選べる

```
// base64
$ openssl rand -base64 15 | fold -w 15 |head -n 1
yWeZes91kn/pd40

// hex
$ openssl rand -hex 15 | fold -w 15 |head -n 1
80fb8b851e8461e
```

> コマンドラインでランダムな10文字を得る方法
> https://qiita.com/tt2004d/items/0212611b6eb321ee860c





# 連続する数値を一気に出力する

## seqとxargsを組み合わせる

```
seq -f "%01g" 0 23 |xargs -ISTART bash -c "expr START + 1 |xargs -IEND printf \"%02d %02d\n\" START END"
00 01
01 02
02 03
03 04
...
```

これかなり遅い。`expr START + 1`これがべらぼうに遅い

## awkで生成しちゃう（forでがりがり）
```
awk 'BEGIN{for(i=0; i<23; i++){ printf("%-2.2d\t%-2.2d\n",i,i+1); } }'
00	01
01	02
02	03
03	04
04	05
05	06
```

こっちのほうがかなり高速

数値の全組み合わせ出力とかもこれでやったほうが良い

```
awk 'BEGIN{for(i=0; i<3; i++){ for(j=0; j<3; j++){ printf("%-2.2d\t%-2.2d\n",i,j); } } }'
00	00
00	01
00	02
01	00
01	01
01	02
02	00
02	01
02	02
```

> AWKのこういう時はどう書く? - Qiita
> https://qiita.com/hirohiro77/items/713d5bcf60fef7e88dfa





# sedで「特定の文字ではじまり特定の文字で終わる」範囲を抽出する方法

... "artistId":462006, ... "artistName":"ボブ・ディラン", ... "artistViewUrl":"https://itunes.apple.com/jp/artist/...?uo=4" ...

みたいな列の場合は、

$ cat itunes_result.txt |grep artistViewUrl |sed -E 's/^.\*("artistId":)([0-9]\*).\*("artistName":")([^"]\*).\*("artistViewUrl":")([^"]\*).\*$/\2 | \4 | \6/g'

で

462006 | ボブ・ディラン | https://itunes.apple.com/jp/artist/

みたいな感じで抽出できる。便利なので覚えておこう

> 【正規表現】文字列の否定、ある文字列を含まない ： nymemo
> https://nymemo.com/phpcate/293/





# 正規表現で抽出

```
$ echo "2017-09-25 19:15:10.994 [aaa-1111] test aaabbbccc - ddd=[111 xxxx]" |sed -E 's/^.*( \[)([a-z0-9]{3}-[0-9]{4}).*$/\2/g'
aaa-1111
```

みたいに抽出できる。Macやと無理かも？

後方参照は、２桁以上は無理らしい。

> regex - Reference 10th submatch - Stack Overflow
> https://stackoverflow.com/questions/11833104/reference-10th-submatch





# 最初に◯◯にマッチするまでの文字列を削る（Macのみ？）

```
$ echo "/aaa/bbb/ccc:{aaa:bbb,ccc:ddd}" |sed 's/.*ccc:{/DEL{/1'
DEL{aaa:bbb,ccc:ddd}

$ echo "/aaa/bbb/ccc:{aaa:bbb,ccc:ddd}" |sed 's/.*ccc:{/{/1'
{aaa:bbb,ccc:ddd}
```





# rsync周りのコマンド

```
// ローカルにあるファイルをサーバーへ送信してサーバーのソースの状態をローカルのディレクトリと同期させる。ただし、権限と同期先に無いファイルは連携しない
$ rsync -ahv --no-p --existing /local/mac/dir hostname:/remote/server/dir

// サーバーにあるソースをローカルに送信してローカルのソースの状態をサーバーのアプリケーションディレクトリと同期させる。ただし、権限と同期先に無いファイルは連携しない
$ rsync -ahv --no-p --existing hostname:/remote/server/dir /local/mac/dir
```

> rsync でよく使うオプション - それマグで！
> http://takuya-1st.hatenablog.jp/entry/20110217/1297941165





# ハードリンク先のファイルを見つける

```
// inode番号を見つける
$ ls -li file.yml
3016206 -r--r--r-- 2 root wheel 15407 Jun 22 11:53 file.yml

// inode番号でリンク先ファイルをfindする
$ sudo find /path/to/dir -inum 3016206
```

> How to find all hard links in a directory on Linux - nixCraft
> https://www.cyberciti.biz/faq/how-to-find-all-hard-links-in-a-directory-on-linux/





# 指定したディレクトリにjarを解凍する

```
// spring-bootに解凍される。
echo "spring-boot" |xargs -IDIRNAME bash -c "rm -rf DIRNAME && mkdir -p DIRNAME && cd DIRNAME && jar xvf ../spring-boot.jar"
```





# ファイル内容をランダムソート

perlやけど・・・

```
perl -MList::Util=shuffle -e 'print shuffle(<>)' < data.txt
```

> 行をランダムシャッフルするワンライナー - 睡眠不足？！
> http://d.hatena.ne.jp/sleepy_yoshi/20110916/p1





# サーバーに対してローカルにあるshellを実行する方法

```
// ローカルにて
ssh hostname 'bash -s' < localscript.sh
```

みたいな感じ。





# ncとかがない環境でhostとportを指定して疎通を確認する

```
$ timeout $TIMEOUT_SECONDS bash -c "</dev/tcp/${HOST}/${PORT}"; echo $?
$ timeout 2 bash -c "</dev/tcp/canyouseeme.org/80"; echo $?
```

ってして0ならOK。という風に簡単なチェックが可能。





# 特定のディレクトリの特定のファイルのみを圧縮する

```
$ find /tmp/test
/tmp/test
/tmp/test/directory
/tmp/test/directory/test01.txt
/tmp/test/directory/test02.txt
/tmp/test/directory/test03.txt
/tmp/test/directory/test11.txt
/tmp/test/directory/test12.txt
/tmp/test/directory/test13.txt

// /tmp/test/directory にある test1*.txt ファイルを directory をrootディレクトリとして圧縮する
// パラメタ: directory
$ find /tmp/test/directory -type f -name test1*.txt |sed 's!^.*/!!' |sort |xargs -IXXX tar rvf output.tar -C /tmp/test/ directory/XXX; gzip output.tar
a directory/test11.txt
a directory/test12.txt
a directory/test13.txt

$ tar zxvf output.tar.gz
x directory/test11.txt
x directory/test12.txt
x directory/test13.txt

$ find /tmp/directory/
/tmp/directory/
/tmp/directory//test11.txt
/tmp/directory//test12.txt
/tmp/directory//test13.txt
```

## 特定の拡張子のみ圧縮する

```
find . -type f \( -name \*.jpg -or -name \*.png -or -name \*.tga \) |xargs -IXXX tar rvf /tmp/Assets.tar XXX ; gzip /tmp/Assets.tar
```

 - [更新日時でファイルを検索して圧縮する - Qiita](http://qiita.com/bezeklik/items/7e5a58f8d29d0c3a3876)
 - [Linuxコマンド集 - 【 find 】 ファイルやディレクトリを検索する：ITpro](http://itpro.nikkeibp.co.jp/article/COLUMN/20060227/230777/)
 - [findでファイル名のみ表示 - Qiita](http://qiita.com/skkzsh/items/40b661a043c9b60f8426)
 - [tarコマンドについて詳しくまとめました 【Linuxコマンド集】](https://eng-entrance.com/linux-command-tar#_-r_--append)
 - [shell script - Can I somehow update compressed archives? - Unix & Linux Stack Exchange](https://unix.stackexchange.com/questions/283139/can-i-somehow-update-compressed-archives)





# ディレクトリの合計とかファイルの容量をソートする

```
du -hs * | sort -h
```

> linux - How can I sort du -h output by size - Server Fault
> https://serverfault.com/questions/62411/how-can-i-sort-du-h-output-by-size





# grep時に各行をセパレータで区切る

linuxでのみ。macだとこのオプション使えない

```
grep -C 0 --group-separator='===========' keyword file*.txt |head -n 10
```

改行を含めたい場合は
```
grep -C 0 --group-separator=$'\n===========keyword file*.txt |head -n 10
```

> shell - How to use multiline as group-separator in grep? - Unix & Linux Stack Exchange
> https://unix.stackexchange.com/questions/209950/how-to-use-multiline-as-group-separator-in-grep





# lsでファイルが多すぎて返ってこないとき

```
$ ls -U |head -n 10
```

> lsコマンドに時間がかかりすぎて返ってこない時は-Uオプションを付けるべし ｜ Step On Board
> http://www.lesstep.jp/step_on_board/linux/157/





### ファイルを指定ファイル数で分割する

 - 10: 分割数

```
split -l $(expr $(cat input.tsv |wc -l)  / 10 + 1) input.tsv splitted_file_
```

# joinを使ってテキストをつなげる

以下のような前提で

 - 基準となるテキストファイル：ファイルA
 - ジョインされるテキストファイル：ファイルB

**ファイルAの中身**

```text
hk326838 2000031366 20141115092748 0
hl641968 2000091520 20140909211237 3
gi402989 2000020607 20140317021201 3
hm286988 2000025904 20140330084441 3
hq188898 2000000914 20141013033616 1
hq188898 2000002034 20140819012715 3
hq188898 2000023874 20140827072902 3
hk429954 2000000774 20140128021602 3
hk429954 2000000952 20140203120127 3
hk429954 2000001417 20141217114741 0
hk429954 2000001556 20141202212253 0
hk429954 2000001734 20140404010206 3
hk429954 2000001760 20140522213212 3
hk429954 2000001781 20140409171855 3
hk429954 2000002361 20140128022122 3
```

**ファイルBの中身**

```text
aa088506 2000110789
aa308730 2000022846
aa873275 2000000354
aa873275 2000003758
aa873275 2000007983
aa873275 2000008469
aa873275 2000010860
aa873275 2000022846
aa873275 2000025520
aa873275 2000026134
aa873275 2000027790
aa873275 2000028184
aa873275 2000075781
aa873275 2000076286
aa873275 2000133303
aa873275 2000164186
ab037858 2000000472
ab037858 2000000727
ab037858 2000001431
ab037858 2000005266
ab037858 2000006550
ab037858 2000011466
ab037858 2000016141
ab037858 2000021326
```

1列目と2列目を結合した文字列を使って２つのファイルをジョインし、結果を表示したいって状況はよくありそう。

そういう時は以下のコマンドで所望の結果を得られる

```linux
$ join -1 1 -2 1 -o 1.2,1.3,1.4,1.5,2.1 -t "$(printf '\011')" -a 1
<(awk '{printf("%s:%s\t%s\t%s\t%s\t%s\n", $1, $2, $1, $2, $3, $4);}'
file_a.tsv |sort ) <(awk '{printf("%s:%s\t%s\t%s\n", $1, $2, $1,
$2);}' file_b.tsv |sort )
```

パラメタの意味は以下の通り

|        パラメタ       |                             意味
          |
|-----------------------|--------------------------------------------------------------|
| -1 1                  | 1ファイル目の1フィールド目をjoinに使う（結合したフィールド） |
| -2 1                  | 2ファイル目の1フィールド目をjoinに使う（結合したフィールド） |
| -o 1.2,1.3 ...        | 出力フォーマット。1.2 -> 1ファイル目の2項目目,みたいな指定   |
| -t "$(printf '\011')" | 区切り文字を指定（'\011'はタブ）                             |
| -a 1                  | 結合されなかった行も出力。left outer join 的な。注意。       |


```text
ag271938 2000000316 20140611084605 3 ag271938:2000000316
ag271938 2000000384 20140513090838 3 ag271938:2000000384
ag271938 2000000418 20141223003847 2
ag271938 2000000592 20140620093646 3 ag271938:2000000592
ag271938 2000000595 20141201185423 1 ag271938:2000000595
ag271938 2000000599 20140925215837 2 ag271938:2000000599
ag271938 2000000628 20140817130525 3 ag271938:2000000628
ag271938 2000001094 20140116190914 3 ag271938:2000001094
ag271938 2000001376 20140925224419 2 ag271938:2000001376
ag271938 2000001430 20140116190722 3 ag271938:2000001430
ag271938 2000001820 20140925224816 2 ag271938:2000001820
ag271938 2000002152 20140119161427 3 ag271938:2000002152
ag271938 2000003420 20140912084943 3 ag271938:2000003420
ag271938 2000005086 20140226183319 3 ag271938:2000005086
ag271938 2000005729 20141219130949 1
ag271938 2000007187 20140226210027 3 ag271938:2000007187
ag271938 2000032210 20140226172717 3 ag271938:2000032210
```

なかった行だけ出力したい時は、-a 1の代わりに

| パラメタ |                       意味                      |
|----------|-------------------------------------------------|
| -v 1     | 1つ目のファイルの結合されなかった行のみ表示する |


を指定すれば、1ファイル目の結合した結果なかった行を出力できる


## -oオプションで指定した行が変な感じになる

文字コード、改行コードを疑う。

UTF-8, LFにするとうまくいった。


### 参考ページ

 - [中間ファイルを作らずにdiffを実行](http://shibainu55.blog137.fc2.com/blog-entry-22.html)
 - [joinコマンド ～複数フィールドで結合する。](http://akiniwa.hatenablog.jp/entry/2013/11/08/145238)
 - [joinコマンドが便利過ぎて生きるのが辛い](http://yut.hatenablog.com/entry/20120907/1346975281)
 - [joinコマンドでtab区切りファイルを扱う](http://qiita.com/doitnow420@github/items/88fa7878282866443803)
 - [2つのテキストファイルを joinコマンドで結合する](http://qiita.com/isseium/items/20eb6802898d9b1ba2b4)





# 共通項を出す

#### パターン１：各ファイルが１列で重複のないユニークなファイルの場合

```
sort aaa.tsv bbb.tsv | uniq -d
```





# 改行を除外する

結果、こう

```
cat test.txt |sed -e ':a' -e 'N' -e '$!ba' -e 's/\n//g'
```

> How can I replace a newline (\n) using sed? - Stack Overflow
> https://stackoverflow.com/questions/1251999/how-can-i-replace-a-newline-n-using-sed





# １行に複数回出てくる文言を改行表示する

```
$ echo "aaa,bbb=BBB,ccc,bbb=BBB,ddd,eee" |sed 's/bbb=/\nbbb=/g' |sed 's/,.*//g' |less -S
```





# grep末尾が5桁の数値である行を抽出する

```
// 普通はこれでいける
cat test.log |grep -E "[0-9]{6}$"

// いけない場合はCRLFの可能性あり。
find . -not -type d -exec file "{}" ";" // 調べられる
cat test.log |grep -E "[0-9]{6}^M$"
※^Mの部分は、Control + v -> Contrl + mで入力
```

> bash - How do you search for files containing dos line endings (CRLF) with grep on Linux? - Stack Overflow
> https://stackoverflow.com/questions/73833/how-do-you-search-for-files-containing-dos-line-endings-crlf-with-grep-on-linu





# Gitの管理対象外にする

```
git rm --cache /path/to/file
```





# 特定の文字列を含むファイルをファイル群全体から検索する

> How do I find all files containing specific text on Linux? - Stack Overflow
> https://stackoverflow.com/questions/16956810/how-do-i-find-all-files-containing-specific-text-on-linux





# xargsで変数展開されなくなった時の対応

大前提として、xargsの-Iでの変数展開は、引数のコマンドの文字列長が255バイトを超えると展開されなくなる。なので、長いコマンドでは変数展開されない。

> xargs with multiple argument substitutions - KISS
> https://egeek.me/2012/10/27/xargs-with-multiple-argument-substitutions/





# ディレクトリ配下のファイルをすべてフルパスでlsする

```
$  ls -altR -d $(find `pwd`)
```
でいける





# historyを加工して最近sshしたサーバー一覧を出す

```
history |grep ssh |tr -s ' ' |cut -d ' ' -f 6 |sort |uniq
```





# gitでコミットを取り消す

```
git reset --soft HEAD^
```

> git commit を取り消して元に戻す方法、徹底まとめ ｜ WWWクリエイターズ
> http://www-creators.com/archives/1116





# N行ごとに置換する

```
cat aiueo.txt | awk '{if(NR%10)ORS=",";else ORS="\n";print}' |sed -e "s/,/\x27,\x27/g" -e "s/^/\"\x27/" -e "s/$/\x27\"/" |xargs -I"XXX" sed "s/ZZZZ/XXX/" sqltemplate.sql
```

以下でもできた

```
cat test.txt |xargs -L10 echo |sed "s/ /,/g"
```





# sort uniqの結果の１列目と２列目を入れ替えてかつタブ区切りで出力する

```
$ echo "2018
2018
2017
2016" |sort |uniq -c |awk '{print $2"	"$1}'

2016	1
2017	1
2018	2
```

コピペするとうまくいかないので、タブ部分はctrl +v, tabで入力しなおす

macやと"\t"でもいけた





# sedで指定行だけ消す（かつ上書き）

```
sed -i -e "2d" aiueo.txt
```

で2行目だけ消せる





# ファイル名の最終更新日付をつけて圧縮する

```
ls  xxx*.log |xargs -I{} bash -c "mv {} {}-\$(date +%Y%m%d-%H:%M:%S -r {}).log; gzip {}*"
```

とかで一気にこの工程が可能

> command line - Renaming files with last modified time on file name - Ask Ubuntu
> https://askubuntu.com/questions/866738/renaming-files-with-last-modified-time-on-file-name





# Diffを見やすくする

```
diff 1016.tsv 1017.tsv -y -W 200 |less -S
```

これが一番わかり易い。

> わかりやすい差分(diff)の取り方いろいろメモ
> https://qiita.com/bitnz/items/725350b614bafedc581a

> Make diff Use Full Terminal Width in Side-by-Side Mode - Unix & Linux Stack Exchange
> https://unix.stackexchange.com/questions/9301/make-diff-use-full-terminal-width-in-side-by-side-mode

> sedコマンドで文字列を改行に置換する、しかもスマートに置換する。
> https://qiita.com/richmikan@github/items/3c74212b0d8dec9bd00f

# 複数のスペースを１つにするする

```
echo "a   b  c d" |sed 's/ \{1,\}/ /g'
```

# 連続する日付をRange指定で生成する（mac限定）

```
d="20150120"; while [ "$d" != "20150220" ]; do echo $d; d=$(date -j -f %Y%m%d -v+1d ${d} +%Y%m%d); done
```

> Bash： Looping through dates - Stack Overflow
> https://stackoverflow.com/questions/28226229/bash-looping-through-dates

# テキスト同士をcross joinする

```
// list_a, list_bをcorss joinする
cat list_a.tsv |xargs -I{} bash -c "awk '{print \"{}        \"\$0}' list_b.tsv"
```

でいける。しかも以下のxargsを重ねる方法よりかなり高速。

> 【bash】xargsを使って2つのリストをCROSS JOINする - くんすとの備忘録
> https://kunst1080.hatenablog.com/entry/2013/06/01/163439

# お手軽に時間計測する

```
SECONDS=0
sleep 3
echo "Sleep ${SECONDS} [sec]"
```

> bashのSECONDS変数で簡単に処理時間を測定する - Qiita
> https://qiita.com/mikeda/items/c6bb68dd1e4ba6434fb7

しらなかった・・・便利

# 安全な一時ファイルを作る

```
BASH_SOURCE_PATH=${BASH_SOURCE:-$0}
SCRIPT_FILE_NAME=${BASH_SOURCE_PATH##*/}
TMP_FILE_PATH=`mktemp /tmp/temp.${SCRIPT_FILE_NAME}.XXXXXXXXXXXX`
trap "{ rm -f ${TMP_FILE_PATH}; }" EXIT
```

これでスクリプト終了時に必ず削除されるファイルを作れる。

# 指定文字を指定回数繰り返す

```
$ printf '=%.0s' {1..10}; echo ""
==========
```

> shell - How can I repeat a character in bash? - Stack Overflow  
> https://stackoverflow.com/questions/5349718/how-can-i-repeat-a-character-in-bash


# if文では`[ ... ]`よりも`[[ ... ]]`を使ったほうが便利

> BashFAQ/031 - Greg's Wiki  
> http://mywiki.wooledge.org/BashFAQ/031

# ファイルを指定ファイル数で分割する

 - input.tsv: 元ファイルパス
 - 10: 分割数

```
echo "input.tsv,10" |awk -F',' '{ system("split -l $(expr $(cat "$1" |wc -l)  / "$2" + 1) "$1" "$1"_part_") }'
```

# 文字に色を付ける（sedで特定の文字だけに）

> shell script - Using sed to color the output from a command on solaris - Unix & Linux Stack Exchange  
> https://unix.stackexchange.com/questions/45924/using-sed-to-color-the-output-from-a-command-on-solaris?answertab=active#tab-top

のテクニックが使えそう

```
#!/bin/bash

function createSedPipeToColorize() {
  local ESC=$(printf '\033')
  local STRING="${1}"
  local COLOR_CODE="${2}"
  echo " |sed \"s/${STRING}/${ESC}[${COLOR_CODE}m${STRING}${ESC}[0m/g\""
}

function toRed() {
  createSedPipeToColorize ${1} 31
}

function toGreen() {
  createSedPipeToColorize ${1} 32
}

COMMAND='echo "bbb aaa ccc ddd" '`toRed aaa``toGreen ccc`
eval ${COMMAND}
```

色はこちら

> bash：tip_colors_and_formatting - FLOZz' MISC  
> https://misc.flogisoft.com/bash/tip_colors_and_formatting


# 複数行のファイルを指定文字列でjoinして1行にする

```
$ cat extlist.txt |awk '{ORS=" ";print $1}'
```

でいける。ORSで区切り文字指定。
