# Macで録画した動画を簡単にエンコードするクイックアクション

> 「キャプチャにGifを貼るのはさすがにジジイっすよ」  
> https://zenn.dev/ncdc/articles/gif-is-too-old-to-upload

**ffmpegを使う**

* `Command + Shit + 5` で録画開始
* `ffmpeg -i input.mov -c:v libx264 -crf 28 -preset veryslow output.mp4` で圧縮
    * `ffmpeg -i demo.mov -c:v libx264 -crf 25 -preset medium output.mp4` より遅いけど結構圧縮される

**gifも作りたい**

* `ffmpeg -i video.mov -vf "fps=5,scale=860:-1:flags=lanczos" out.gif`
    * `scale:860:-1` : 横幅が860, 高さはスペクト比維持
    * `flags=lanczos` : 高品質なスケーリングの指定

**HandBrakeを使う**

* `Command + Shit + 5` で録画開始
* `HandBrakeCLI --preset "Very Fast 1080p30" -i input.mov -o /tmp/out.mp4`
    * より軽くしたい場合は `Very Fast 576p25` を使う
    * `HandBrakeCLI -z`: プリセット一覧が見れる

**エンコード処理を右クリックメニューに追加する**

Automatorの「クイックアクション」を新規作成し、「シェルスクリプトを実行」から以下のスクリプトを作成し「Encode Video」などで保存する。

<img src="https://github.com/user-attachments/assets/c3ba2c9d-ad00-4ea1-9a1a-939d4eae1c2f" width="360">

* シェル: /bin/bash
* 入力の引き渡し方法: 引数として

```bash
for f in "$@"
do
  #  ${f%.*}: 変数 f の値の末尾から「最短一致」で .* にマッチする部分を削除する
  /usr/local/bin/HandBrakeCLI --preset "Fast 1080p30" -i "${f}" -o "${f%.*}_h264_1080p30.mp4"
done
```

保存先は `/Users/user/Library/Services/Encode Video.workflow` になる。 

## h.264で圧縮率を上げる（画質は落ちる）

`encode-video-h264-720p30`

```bash

for f in "$@"
do
  # --preset="Fast 720p30": ベースとなるプリセットを指定
  # --encoder-preset 8: 圧縮速度/効率 1〜13まで指定可能。数値が大きいほど速くなりますが、8〜10がサイズ節約には最適です。
  # -q 30: 画質 (RF値) 数値を上げるとサイズが減ります。AV1なら28〜32程度が「最小サイズ」の限界ラインです。
  /usr/local/bin/HandBrakeCLI --preset="Fast 720p30" --encoder-preset 2 -q 30 -i "${f}" -o "${f%.*}_h264_720p30.mp4"
done
```


## av1でエンコードする場合

av1とは: ライセンスの不透明さに嫌気がさしたテック企業たちが集まり、**「ロイヤリティフリー（無料）で、誰でも自由に使える高性能なコーデックを作ろう」**として誕生したのが 「AV1」 です。（AIより）

`encode-video-av1-720p30`

```bash
for f in "$@"
do
  # --preset="Fast 720p30": ベースとなるプリセットを指定
  # -e svt_av1: コーデックを上書き指定
  # --encoder-preset 2: 圧縮速度/効率 1〜13まで指定可能。数値が大きいほど速くなりますが、8〜10がサイズ節約には最適です。
  # -q 30: 画質 (RF値) 数値を上げるとサイズが減ります。AV1なら28〜32程度が「最小サイズ」の限界ラインです。
  # **MKV形式（.mkv）** は、AV1との相性が最も良く、HandBrakeも公式にAV1にはMKVを推奨しています。
  /usr/local/bin/HandBrakeCLI --preset="Fast 720p30" -e svt_av1 --encoder-preset 2 -q 30 -i "${f}" -o "${f%.*}_av1_720p30.mkv"
done
```

# 画像をBase64エンコードしてクリップボードにコピーするクイックアクション

**Base64 Encode Image**

```bash
for f in "$@"
do
  cat "$f" |base64 |pbcopy
  osascript -e 'display notification "Copied the base64-encoded image." with title "Base64 Encode Image"'
done
```





# 画像を2つに分割するクイックアクション

**Split Image**

```bash
for f in "$@"
do
  HEIGHT=$(sips -g pixelHeight "${f}" |grep pixelHeight |sed "s/.*: //g")
  WIDTH=$( sips -g pixelWidth  "${f}" |grep pixelWidth  |sed "s/.*: //g")
  HEIGHT_HALF=$(awk "BEGIN {printf \"%d\n\", ${HEIGHT} / 2}")
  # --cropToHeightWidth pixelsH pixelsW
  # --cropOffset offsetY offsetH
  sips --cropToHeightWidth ${HEIGHT_HALF} ${WIDTH} --cropOffset 0 1 "${f}" --out "${f%.*}_1.${f##*.}"  
  sips --cropToHeightWidth ${HEIGHT_HALF} ${WIDTH} --cropOffset ${HEIGHT_HALF} 1 "${f}" --out "${f%.*}_2.${f##*.}"  
done
```





# 画像のファイルサイズ上限を指定してjpegに圧縮するクイックアクション（二分期探索で圧縮のクオリティを最適化していく）

**Compress JPEG to 2MB**

```bash
# 設定
readonly TARGET_SIZE_MB=2.0
readonly TARGET_SIZE=$(awk "BEGIN {printf \"%d\n\", (${TARGET_SIZE_MB} * 1000000)}")
readonly MIN_QUALITY=1
readonly MAX_QUALITY=100
readonly QUALITY_THRESHOLD=2  # バイナリサーチの終了条件

getFileSize() {
  local input="${1}"
  local quality="${2}"
  local uuid=$(perl -e 'print map { (0..9)[rand 10] } 1..32; print "\n";')
  (
    local temp_file="/tmp/$(basename ${input})_${uuid}_quick_action_${quality}.jpeg"
    trap 'rm -f "$temp_file"' EXIT SIGINT SIGTERM SIGQUIT SIGKILL
    sips -s format jpeg -s formatOptions $quality "$input" --out "$temp_file" >/dev/null 2>&1
    stat -f%z "$temp_file"
  )
}

for f in "$@"
do
  input="${f}"
  statusFile="${input}_STARTED"
  touch "${statusFile}"
  trap 'rm -f "${statusFile}"' EXIT SIGINT SIGTERM SIGQUIT SIGKILL
  low=$MIN_QUALITY
  high=$MAX_QUALITY
  finallySize="OVER"
  while (( $high - $low > $QUALITY_THRESHOLD )); do
    quality=$(awk "BEGIN {printf \"%d\n\", ($low + $high) / 2 }")
    actualSize=$(getFileSize "${input}" "${quality}")
  
    if (( actualSize >= TARGET_SIZE )); then
      high="${quality}"
    else
      low="${quality}"
      finallySize="${actualSize}"
    fi
    newStatusFile="${input}_${low}_${high}"
    mv "${statusFile}" "${newStatusFile}"
    statusFile="${newStatusFile}"
  done
  quality="${low}"

  output="${input}_q${quality}_s${finallySize}.jpeg"
  rm -f "${output}"
  sips -s format jpeg -s formatOptions $quality "${input}" --out "${output}"
done
```
