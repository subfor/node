#!/bin/bash

apt update
exists()
{
  command -v "$1" >/dev/null 2>&1
}
if exists curl; then
	echo ''
else
  apt install curl -y < "/dev/null"
fi
bash_profile=$HOME/.bash_profile
if [ -f "$bash_profile" ]; then
    . $HOME/.bash_profile
fi
echo -e '\033[0;32mSetting up swapfile...\033[0m'

grep -q "swapfile" /etc/fstab
if [[ ! $? -ne 0 ]]; then
    echo -e '\033[0;32mSwap file exist, skip.\033[0m'
else
    cd $HOME
    sudo fallocate -l 8G $HOME/swapfile
    # sudo dd if=/dev/zero of=swapfile bs=1K count=8M
    sudo chmod 600 $HOME/swapfile
    sudo mkswap $HOME/swapfile
    sudo swapon $HOME/swapfile
    sudo swapon --show
    echo $HOME'/swapfile swap swap defaults 0 0' >> /etc/fstab
    echo -e '\033[0;32mDone \033[0m'
fi

echo -e '\033[0;32mInstalling software \033[0m' && sleep 1
apt-get update && DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC apt-get install -y --no-install-recommends tzdata git ca-certificates curl build-essential libssl-dev pkg-config libclang-dev cmake jq
echo -e '\033[0;32mInstalling Rust \033[0m' && sleep 1
sudo curl https://sh.rustup.rs -sSf | sh -s -- -y
source $HOME/.cargo/env

rm -rf /var/sui/db /var/sui/genesis.blob $HOME/sui
mkdir -p /var/sui/db
cd $HOME
git clone https://github.com/MystenLabs/sui.git
cd sui
git remote add upstream https://github.com/MystenLabs/sui
git fetch upstream
git checkout --track upstream/devnet
cp crates/sui-config/data/fullnode-template.yaml /var/sui/fullnode.yaml
#curl -fLJO https://github.com/MystenLabs/sui-genesis/raw/main/devnet/genesis.blob
wget -O /var/sui/genesis.blob https://github.com/MystenLabs/sui-genesis/raw/main/devnet/genesis.blob
sed -i.bak "s/db-path:.*/db-path: \"\/var\/sui\/db\"/ ; s/genesis-file-location:.*/genesis-file-location: \"\/var\/sui\/genesis.blob\"/" /var/sui/fullnode.yaml
cargo build --release
mv ~/sui/target/release/sui-node /usr/local/bin/
mv ~/sui/target/release/sui /usr/local/bin/
sed -i.bak 's/127.0.0.1/0.0.0.0/' /var/sui/fullnode.yaml

echo "[Unit]
Description=Sui Node
After=network.target

[Service]
User=$USER
Type=simple
ExecStart=/usr/local/bin/sui-node --config-path /var/sui/fullnode.yaml
Restart=on-failure
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target" > $HOME/suid.service

mv $HOME/suid.service /etc/systemd/system/
sudo tee <<EOF >/dev/null /etc/systemd/journald.conf
Storage=persistent
EOF
sudo systemctl restart systemd-journald
sudo systemctl daemon-reload
sudo systemctl enable suid
sudo systemctl restart suid


echo "==================================================="
echo -e '\033[0;32mCheck Sui status : \033[0m' && sleep 1
if [[ `service suid status | grep active` =~ "running" ]]; then
  echo -e "\033[0;32mYour Sui Node installed and works!\033[0m"
  echo -e "You can check node status by the command: \033[0;32mservice suid status\033[0m"
  echo -e "Press Q for exit from status menu"
  echo -e "Paste this line in Discord: \n"
  echo -e "\033[0;32mhttp://`wget -qO- eth0.me`:9000/\033[0m"
else
  echo -e "\033[0;31mYour Sui Node was not installed correctly, please reinstall.\033[0m"
fi

#. <(wget -qO- https://raw.githubusercontent.com/subfor/node/main/sui_install.sh)