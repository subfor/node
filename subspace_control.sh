#!/bin/bash

while true
do

PS3='Select an action: '
options=(
"Restart Farmer and Node"
"Log Node"
"Log Farmer"
"Search in node logs"
"Search in farmer logs"
"Wipe Farmer and Purge-chain"
"Delete Node"
"Exit")
select opt in "${options[@]}"
do
case $opt in

"Restart Farmer and Node")
sudo systemctl restart subspacefarm subspace
break
;;

"Log Node")
sudo journalctl -n 100 -f -u subspace
break
;;

"Log Farmer")
sudo journalctl -n 100 -f -u subspacefarm
break
;;

"Search in node logs")
echo "============================================================"
echo "Enter a keyword or phrase to search"
echo "============================================================"
read KEYWORD
echo -e "\n\033[32m =========================SEARCH RESULTS========================= \033[0m"
sudo journalctl -u subspace -o cat | grep "$KEYWORD"
echo -e "\n\033[32m ================================================================ \033[0m"
break
;;

"Search in farmer logs")
echo "============================================================"
echo "Enter a keyword or phrase to search"
echo "============================================================"
read KEYWORD
echo -e "\n\033[32m =========================SEARCH RESULTS========================= \033[0m"
sudo journalctl -u subspacefarm -o cat | grep "$KEYWORD"
echo -e "\n\033[32m ================================================================ \033[0m"
break
;;

"Wipe Farmer and Purge-chain")
systemctl stop subspace subspacefarm
farmer wipe
subspace purge-chain --chain gemini-2a -y
sudo systemctl restart subspacefarm subspace
break
;;

"Delete Node")
systemctl stop subspace subspacefarm
systemctl disable subspace subspacefarm
rm /etc/systemd/system/subspace.service
rm /etc/systemd/system/subspacefarm.service
rm -r /usr/local/bin/subspace
rm -r /usr/local/bin/farmer
rm -r /root/.local/share/subspace-farmer
rm -r /root/.local/share/subspace-node
break
;;

"Exit")
exit
;;
*) echo "invalid option $REPLY";;
esac
done
done