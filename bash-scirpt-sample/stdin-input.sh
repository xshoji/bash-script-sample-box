#!/bin/bash

function usage()
{
cat << _EOT_

 stdin-input
---------------- author: xshoji

Bash script input stdin sample.
usage: cat text.txt |$(basename "$0")

Usage:
  ./$(basename "$0")

Optional:
  --debug : Enable debug mode.

_EOT_
  [[ "${1+x}" != "" ]] && { exit "${1}"; }
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
    [[ "${ARG}" == "--debug" ]] && { shift 1; set -eux; SHIFT="false"; }
    { [[ "${ARG}" == "--help" ]] || [[ "${ARG}" == "-h" ]]; } && { shift 1; HELP="true"; SHIFT="false"; }
    { [[ "${SHIFT}" == "true" ]] && [[ "$#" -gt 0 ]]; } && { shift 1; }
done
[[ -n "${HELP+x}" ]] && { usage 0; }
# Check invalid state and display usage
[[ -n "${INVALID_STATE+x}" ]] && { usage; }



#------------------------------------------
# Main
#------------------------------------------
# - [How to read from a file or stdin in Bash? - Stack Overflow](https://stackoverflow.com/questions/6980090/how-to-read-from-a-file-or-stdin-in-bash)
LINE_COUNT=0
while read LINE || [ -n "${LINE}" ];
do
  LINE_COUNT=$(( LINE_COUNT + 1 ))
  echo "${LINE_COUNT} ${LINE}"
done < <(cat /dev/stdin)

echo
echo "Total lines: ${LINE_COUNT}"

# STARTER_URL=https://raw.githubusercontent.com/xshoji/bash-script-starter/develop/ScriptStarter.sh
# curl -sf ${STARTER_URL} |bash -s - \
#   -n stdin-input \
#   -a xshoji \
#   -d "Bash script input stdin sample." \
#   -d 'usage: cat text.txt |$(basename "$0")' \
#   -s > /tmp/test.sh
