#!/usr/bin/env bash

set -euo pipefail
trap "echo -e '\e[1;31mScript failed: see failed command above\e[0m'" ERR

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
