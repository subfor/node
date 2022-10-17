#!/bin/sh

regex='HTTP Server started on port'
PORT='9231'

wget -O minima_setup.sh https://raw.githubusercontent.com/minima-global/Minima/master/scripts/minima_setup.sh
chmod +x minima_setup.sh
echo 'Installing node'
regex='HTTP Server started on port'
while read -r line
do
        echo $line
        if [[ $line =~ $regex ]]; then
                rpc_port=$(echo $line | cut -d' ' -f 19)
                pkill -f 'journalctl -fn 10 -u'
        fi
done < <( ./minima_setup.sh -p $PORT )
sleep 5

echo 'Node is started'

read -p "Enter ID: " id
curl 127.0.0.1:$rpc_port/incentivecash+uid:$id | jq

#. <(wget -qO- https://raw.githubusercontent.com/subfor/node/main/install2.sh)