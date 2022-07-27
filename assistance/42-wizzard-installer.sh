cd ~
/bin/rm -rf .42-wizzard.sh .42-wizzard-loading.sh > /dev/null 2>&1
sed -n '/42-wizzard/!p' ~/.zshrc > .tmp && mv .tmp ~/.zshrc
curl -fsSL https://raw.githubusercontent.com/0xShady/42_wizzard/main/42-wizzard.sh > ~/.42-wizzard.sh
curl -fsSL https://raw.githubusercontent.com/0xShady/42_wizzard/main/assistance/42-wizzard-updater.sh > ~/.42-wizzard-updater.sh
chmod +x .42-wizzard.sh
chmod +x .42-wizzard-updater.sh
echo "source ~/.42-wizzard.sh" >> ~/.zshrc
echo "42-wizzard-update" >> ~/.zshrc
cd -
printf "\e[1;32m 42 wizzard installed\n \033[0m"
printf "run \e[1;32m 42 -help or -h \033[0m for more info \n"