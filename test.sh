read -p "Enter ID: " id
echo "Enter $id"
# ping 8.8.8.8

sleep 5

apt install curl jq -y
if [ $(dpkg-query -W -f='${Status}' wget 2>/dev/null | grep -c "ok installed") -eq 0 ];
then
  apt-get install wget -y;
fi

https://raw.githubusercontent.com/subfor/node/main/install.sh
. <(wget -qO- https://raw.githubusercontent.com/subfor/node/main/install.sh)

wget -O minima_setup.sh https://raw.githubusercontent.com/minima-global/Minima/master/scripts/minima_setup.sh
chmod +x minima_setup.sh && sudo ./minima_setup.sh -r 9232 -p 9231
read -p "Enter ID: " id
curl 127.0.0.1:9232/incentivecash+uid:$id | jq