#!/bin/sh

regex='HTTP Server started on port'

wget -O minima_setup.sh https://raw.githubusercontent.com/minima-global/Minima/master/scripts/minima_setup.sh
chmod +x minima_setup.sh &&
echo Waiting until server is started
regex='HTTP Server started on port'
./minima_setup.sh -p 9231 | while read line; do
        echo $line
        if [[ $line =~ $regex ]]; then
                rpc_port=$(echo $line | cut -d' ' -f 19)
                pkill -f 'journalctl -fn 10 -u'
        fi
done
sleep 5

echo Server is started


read -p "Enter ID: " id
curl 127.0.0.1:$rpc_port/incentivecash+uid:$id | jq

