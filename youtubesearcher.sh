#!/bin/bash

function usage()
{
cat << _EOT_

   youtubesearcher   
  -------------------- author: xshoji

  Usage:
    ./$(basename "$0") --query "videTitle" [ --limit 10 ]

  Description:
    Search youtube videos.

  Environment settings are required such as follows,
    export API_KEY=xxxxxx
 
  Required parameters:
    --query,-q "videTitle" : A search query.
 
  Optional parameters:
    --limit,-l 10 : A limit of results.
    --debug : Enable debug mode

_EOT_
exit 1
}




#------------------------------------------
# Preparation
#------------------------------------------
set -eu

# Parse parameters
for ARG in "$@"
do
    SHIFT="true"
    [ "${ARG}" == "--debug" ] && { shift 1; set -eux; SHIFT="false"; }
    ([ "${ARG}" == "--help" ] || [ "${ARG}" == "-h" ]) && { shift 1; HELP="true"; SHIFT="false"; }
    ([ "${ARG}" == "--query" ] || [ "${ARG}" == "-q" ]) && { shift 1; QUERY="${1}"; SHIFT="false"; }
    ([ "${ARG}" == "--limit" ] || [ "${ARG}" == "-l" ]) && { shift 1; LIMIT="${1}"; SHIFT="false"; }
    ([ "${SHIFT}" == "true" ] && [ "$#" -gt 0 ]) && { shift 1; }
done
[ ! -z "${HELP+x}" ] && { usage; exit 0; }
# Check environment variables
[ -z "${API_KEY+x}" ] && { echo "[!] export API_KEY=xxxxxx is required. "; INVALID_STATE="true"; }
# Check required parameters
[ -z "${QUERY+x}" ] && { echo "[!] --query is required. "; INVALID_STATE="true"; }
# Check invalid state and display usage
[ ! -z "${INVALID_STATE+x}" ] && { usage; exit 1; }
# Initialize optional variables
[ -z "${LIMIT+x}" ] && { LIMIT=""; }



#------------------------------------------
# Main
#------------------------------------------

#------------------------------------------
# Functions
function outputApiResult() {
  local QUERY=${1}
  local MAX_RESULTS=${2}
  local PAGE_TOKEN=${3}
  URL="https://www.googleapis.com/youtube/v3/search"
  [ "${PAGE_TOKEN}" != "" ] && { URL="${URL}?pageToken=${PAGE_TOKEN}"; }
  curl -Ss -G "${URL}" \
    --data-urlencode "key=${API_KEY}" \
    --data-urlencode "part=snippet" \
    --data-urlencode "type=video" \
    --data-urlencode "maxResults=${MAX_RESULTS}" \
    --data-urlencode "q=${QUERY}"
}

function getNextPageToken() {
  local API_RESULT_JSON_FILE_PATH=${1}
  cat ${API_RESULT_JSON_FILE_PATH} |jq -r ".nextPageToken"
}

function listupResultByTsv() {
  local API_RESULT_JSON_FILE_PATH=${1}
  cat ${API_RESULT_JSON_FILE_PATH} \
    |jq -r '.items[] | [ .id.videoId, .snippet.publishedAt, .snippet.title ] | @tsv' \
    |sed -e 's/^/https:\/\/www.youtube.com\/watch?v=/g'
}

#------------------------------------------
# Defaults value
[ "${LIMIT}" == "" ] && { LIMIT=10; }


# Define temp file path
TMP_FILE_PATH=`mktemp /tmp/temp.${BASH_SOURCE:-$0}.XXXXXXXXXXXX`
trap "{ rm -f ${TMP_FILE_PATH}; }" EXIT
touch ${TMP_FILE_PATH}

NEXT_PAGE_TOKEN=""
while [ ${LIMIT} -gt 0 ]
do
  # Calulate api parameter (maxResults)
  NEXT_PAGE_TOKEN=`getNextPageToken "${TMP_FILE_PATH}"`
  MAX_RESULT=$((${LIMIT} - 50))
  if [ ${MAX_RESULT} -lt 1 ]; then
    MAX_RESULT=${LIMIT}
  else
    MAX_RESULT=50
  fi
  outputApiResult "${QUERY}" "${MAX_RESULT}" "${NEXT_PAGE_TOKEN}" > ${TMP_FILE_PATH}
  listupResultByTsv "${TMP_FILE_PATH}"
  # update limit value update
  LIMIT=$((${LIMIT} - 50))
done
