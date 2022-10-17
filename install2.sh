#!/bin/sh

wget -O minima_setup.sh https://raw.githubusercontent.com/minima-global/Minima/master/scripts/minima_setup.sh
chmod +x minima_setup.sh && 
echo Waiting until server is started
regex='HTTP Server started on port'
./minima_setup.sh -p 9231 | while read line; do
        if [[ $line =~ $regex ]]; then
                pkill -9 -P $$ minima_setup.sh
        fi
done
echo Server is started


read -p "Enter ID: " id
curl 127.0.0.1:9235/incentivecash+uid:$id | jq