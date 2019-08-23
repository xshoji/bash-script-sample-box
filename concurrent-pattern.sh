#!/bin/bash

function usage()
{
cat << _EOT_

 concurrent-pattern
----------------------- author: xshoji

This is concurrent-pattern.

Usage:
  ./$(basename "$0") [ --concurrency 3 --pattern file --limit 10 ]

Optional:
  -c, --concurrency 3 : Concurrency. [ default: 3 ]
  -p, --pattern file  : Pattern of implementation. ( array | file | function ) [ default: file ]
  -l, --limit 10      : Repetition limit. [ default: 10 ]

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
    { [[ "${ARG}" == "--concurrency" ]] || [[ "${ARG}" == "-c" ]]; } && { shift 1; CONCURRENCY="${1}"; SHIFT="false"; }
    { [[ "${ARG}" == "--pattern" ]] || [[ "${ARG}" == "-p" ]]; } && { shift 1; PATTERN="${1}"; SHIFT="false"; }
    { [[ "${ARG}" == "--limit" ]] || [[ "${ARG}" == "-l" ]]; } && { shift 1; LIMIT="${1}"; SHIFT="false"; }
    { [[ "${ARG}" == "--help" ]] || [[ "${ARG}" == "-h" ]]; } && { shift 1; HELP="true"; SHIFT="false"; }
    { [[ "${SHIFT}" == "true" ]] && [[ "$#" -gt 0 ]]; } && { shift 1; }
done
[[ -n "${HELP+x}" ]] && { usage 0; }
# Check invalid state and display usage
[[ -n "${INVALID_STATE+x}" ]] && { usage; }
# Initialize optional variables
[[ -z "${CONCURRENCY+x}" ]] && { CONCURRENCY="3"; }
[[ -z "${PATTERN+x}" ]] && { PATTERN="file"; }
[[ -z "${LIMIT+x}" ]] && { LIMIT="10"; }



#------------------------------------------
# Main
#------------------------------------------

cat << __EOT__

[ Optional parameters ]
concurrency: ${CONCURRENCY}
pattern: ${PATTERN}
limit: ${LIMIT}

__EOT__


SECONDS=0
if [ "${PATTERN}" == "array" ]; then

    #--------------------------
    # Simple commands

    COMMANDS=()
    # Generate commands
    for VALUE in $(seq 1 ${LIMIT}); do
        COMMANDS+=( "echo \"array:${VALUE}\"" )
    done

    # > linux - Pass all elements in existing array to xargs - Stack Overflow
    # > https://stackoverflow.com/questions/19453618/pass-all-elements-in-existing-array-to-xargs
    printf "%s\n" "${COMMANDS[@]}" |xargs -I{} -P ${CONCURRENCY} bash -c "{}"

elif [ "${PATTERN}" == "file" ]; then

    #--------------------------
    # Simple commands in file
    BASH_SOURCE_PATH=${BASH_SOURCE:-$0}
    SCRIPT_FILE_NAME=${BASH_SOURCE_PATH##*/}
    TMP_FILE_PATH=$(mktemp /tmp/temp."${SCRIPT_FILE_NAME}".XXXXXXXXXXXX)
    trap "{ rm -f ${TMP_FILE_PATH}; }" EXIT
    # Write commands to file
    for VALUE in $(seq 1 ${LIMIT}); do
        echo "echo file:\"${VALUE}\"" >> "${TMP_FILE_PATH}"
    done

    echo "${TMP_FILE_PATH}"
    cat "${TMP_FILE_PATH}" |xargs -I{} -P ${CONCURRENCY} bash -c "{}"

elif [ "${PATTERN}" == "function" ]; then

    #--------------------------
    # Multiple commands implement as function

    function executeMultipleCommands(){
        VALUE=${1}
        OUTPUT="pid:$$,"
        OUTPUT="${OUTPUT} $(date)"
        OUTPUT="${OUTPUT} function:${VALUE}/${LIMIT}"
        echo "${OUTPUT}"
    }

    export -f executeMultipleCommands
    export LIMIT
    seq 1 ${LIMIT} |xargs -I{} -P ${CONCURRENCY} bash -c "executeMultipleCommands \"{}\""

else
  printColored Yellow "ERROR: Unkown pattern. ${PATTERN}\n"
  exit 1
fi

echo ""
printColored Green "Processing time: ${SECONDS} [sec]\n"


# STARTER_URL=https://raw.githubusercontent.com/xshoji/bash-script-starter/develop/ScriptStarter.sh
# curl -sf ${STARTER_URL} |bash -s - \
#   -n concurrent-pattern \
#   -a xshoji \
#   -o concurrency,3,"Concurrency.","3" \
#   -o pattern,file,"Pattern of implementation. ( array | file | function )","file" \
#   -o limit,10,"Repetition limit.","10" \
#   -s > /tmp/test.sh; open /tmp/test.sh
