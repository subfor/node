#!/bin/bash


echo -e '\033[0;32mStoping service...\n'
systemctl stop suid
echo -e '\033[0;32mRemoving db...\n'
rm -rf /var/sui/db/* /var/sui/genesis.blob $HOME/sui
source $HOME/.cargo/env
cd $HOME
echo -e '\033[0;32mFetching new sources...\n'
git clone https://github.com/MystenLabs/sui.git
cd sui
git remote add upstream https://github.com/MystenLabs/sui
git fetch upstream
git checkout -B devnet --track upstream/devnet
echo -e '\033[0;32mCompiling SUI...\n'
cargo build -p sui-node -p sui --release
mv ~/sui/target/release/sui-node /usr/local/bin/
mv ~/sui/target/release/sui /usr/local/bin/
wget -O /var/sui/genesis.blob https://github.com/MystenLabs/sui-genesis/raw/main/devnet/genesis.blob
echo -e '\033[0;32mStarting service...\n'
systemctl start suid
if [[ `service suid status | grep active` =~ "running" ]]; then
  echo -e "\033[0;32mYour Sui Node updated and works!"
  echo -e "You can check node status by the command: \033[0;32mservice suid status"
  echo -e "Press Q for exit from status menu"
  echo -e "View logs : \033[0;32mjournalctl -u suid -f -o cat"
  echo -e "Ctrl-C to exit logs"
  echo -e "To check the version: \033[0;32msui -V"
else
  echo -e "\033[0;31mYour Sui Node was not installed correctly, please reinstall."
fi