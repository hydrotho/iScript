#!/usr/bin/env bash

set -o errexit
set -o errtrace
set -o pipefail
set -o nounset

COUNT=0
TEST_TARGET=www.baidu.com

while true
do
    # ping once and wait the first response for 1 second
    ping -c 1 -W 1 $TEST_TARGET > /dev/null && COUNT=0 || ((COUNT++))

    # reboot after 3 failures
    if [[ $COUNT -eq 3 ]]; then
        reboot
    fi

    # 10 seconds * 3 times = 30 seconds
    sleep 10
done
