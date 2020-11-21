#!/bin/bash

function usage()
{
cat << _EOT_

 youtubesearcher
--------------------

Search youtube videos.

Usage:
  ./$(basename "$0") --query videTitle [ --limit 10 ]

Environment variables:
  export API_KEY=xxxxxxxx

Required:
  -q, --query videTitle : A query for searching.

Optional:
  -l, --limit 10 : Results limit.

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
    { [[ "${ARG}" == "--query" ]] || [[ "${ARG}" == "-q" ]]; } && { shift 1; QUERY="${1}"; SHIFT="false"; }
    { [[ "${ARG}" == "--limit" ]] || [[ "${ARG}" == "-l" ]]; } && { shift 1; LIMIT="${1}"; SHIFT="false"; }
    { [[ "${ARG}" == "--help" ]] || [[ "${ARG}" == "-h" ]]; } && { shift 1; HELP="true"; SHIFT="false"; }
    { [[ "${SHIFT}" == "true" ]] && [[ "$#" -gt 0 ]]; } && { shift 1; }
done
[[ -n "${HELP+x}" ]] && { usage 0; }
# Check environment variables
[[ -z "${API_KEY+x}" ]] && { printColored Yellow "[!] export API_KEY=xxxxxxxx is required.\n"; INVALID_STATE="true"; }
# Check required parameters
[[ -z "${QUERY+x}" ]] && { printColored Yellow "[!] --query is required.\n"; INVALID_STATE="true"; }
# Check invalid state and display usage
[[ -n "${INVALID_STATE+x}" ]] && { usage; }
# Initialize optional variables
[[ -z "${LIMIT+x}" ]] && { LIMIT=""; }



#------------------------------------------
# Main
#------------------------------------------

cat << __EOT__

[ Environment variables ]
API_KEY: ${API_KEY}

[ Required parameters ]
query: ${QUERY}

[ Optional parameters ]
limit: ${LIMIT}

__EOT__


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


# STARTER_URL=https://raw.githubusercontent.com/xshoji/bash-script-starter/develop/ScriptStarter.sh
# curl -sf ${STARTER_URL} |bash -s - \
#   -n youtubesearcher \
#   -d "Search youtube videos." \
#   -e API_KEY,xxxxxxxx \
#   -r query,"videTitle","A query for searching." \
#   -o limit,10,"Results limit." \
#   -s > /tmp/test.sh; open /tmp/test.sh