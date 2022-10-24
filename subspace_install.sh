#!/bin/bash

apt update

echo -e "\033[0;32mWrite the name of your node: \033[0m"
read NODENAME
echo 'export NODENAME='$NODENAME >> $HOME/.bash_profile

echo -e "\033[0;32mEnter your wallet address: \033[0m"
read WALLETADDRESS
echo 'export WALLETADDRESS='$WALLETADDRESS >> $HOME/.bash_profile

echo -e "\033[0;32mEnter plot size for farmer(100G maximum): \033[0m"
read PLOTSIZE
echo 'export PLOTSIZE='$PLOTSIZE >> $HOME/.bash_profile
source ~/.bash_profile


apt install jq

mkdir $HOME/subspace; \
cd $HOME/subspace && \
wget https://github.com/subspace/subspace/releases/download/gemini-2a-2022-oct-06/subspace-farmer-ubuntu-x86_64-gemini-2a-2022-oct-06 -O farmer && \
wget https://github.com/subspace/subspace/releases/download/gemini-2a-2022-oct-06/subspace-node-ubuntu-x86_64-gemini-2a-2022-oct-06 -O subspace && \
sudo chmod +x * && \
sudo mv * /usr/local/bin/ && \
cd $HOME && \
rm -Rvf $HOME/subspace

sudo tee <<EOF >/dev/null /etc/systemd/system/subspace.service
[Unit]
Description=Subspace Node
After=network.target
[Service]
Type=simple
User=$USER
ExecStart=$(which subspace) \\
--chain="gemini-2a" \\
--execution="wasm" \\
--state-pruning="archive" \\
--validator \\
--name="$NODENAME"
Restart=on-failure
RestartSec=10
LimitNOFILE=65535
[Install]
WantedBy=multi-user.target
EOF

sudo tee <<EOF >/dev/null /etc/systemd/system/subspacefarm.service
[Unit]
Description=Subspace Farmer
After=network.target
[Service]
Type=simple
User=$USER
ExecStart=$(which farmer) farm \\
--reward-address=$WALLETADDRESS \\
--plot-size=$PLOTSIZE
Restart=always
RestartSec=10
LimitNOFILE=65535
[Install]
WantedBy=multi-user.target
EOF

sudo systemctl restart systemd-journald
sudo systemctl daemon-reload
sudo systemctl enable subspace subspacefarm
sudo systemctl restart subspacefarm subspace

wget https://raw.githubusercontent.com/subfor/node/main/subspace_control.sh  -O subspace_control.sh
chmod +x $HOME/subspace_control.sh


if [[ `service subspace status | grep active` =~ "running" ] && [ `service subspacefarm status | grep active` =~ "running" ]]; then
  echo -e "\033[0;32mYour Node and Farmer installed and works!\033[0m"
  echo -e "You can check Node logs by the command: \033[0;32mjournalctl -n 100 -f -u subspace\033[0m -  Ctrl-C to exit logs"
  echo -e "You can check Farmer logs by the command: \033[0;32msudo journalctl -n 100 -f -u subspacefarm\033[0m -  Ctrl-C to exit logs"
  echo -e "Run \033[0;32m~/subspace_control.sh\033[0m to control Node and Farmer"
else
  echo -e "\033[0;31mYour Node was not installed correctly, please reinstall.\033[0m"
fi

#. <(wget -qO- https://raw.githubusercontent.com/subfor/node/main/subspace_install.sh)