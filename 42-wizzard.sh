#!/bin/zsh

RESET="\033[0m"
RED="\e[1;31m"
GREEN="\e[1;32m"
YELLOW="\e[1;33m"
BLUE="\e[1;34m"
MAGENTA="\e[1;35m"
CYAN="\e[1;36m"

function 42_update() {
    curl -fsSL https://raw.githubusercontent.com/0xShady/42_wizzard/main/42.sh > $HOME/.tmp_wizzard
    diff $HOME/.tmp_wizzard $HOME/.42-wizzard.sh > /dev/null 2>&1
    if [ $? == 0 ];
    then
        printf "$GREEN 42 wizzard is up to date\n $RESET"
        rm $HOME/.tmp_wizzard
    else
        mv $HOME/.tmp_wizzard $HOME/.42-wizzard.sh
        chmod +x $HOME/.42-wizzard.sh
        printf "$GREEN 42 wizzard updated\n $RESET"
    fi
    source "$HOME"/.42-wizzard.sh
    source "$HOME"/.zshrc
}

function 42_clean() {
    STORAGE_AVAILABLE=$(df -h | grep "$USER" | awk '{print($4)}' | tr 'i' 'B')
    printf "• Free storage before cleaning:$GREEN $STORAGE_AVAILABLE $RESET \n"
    printf "$BLUE Cleaning... $RESET \n"
    /bin/rm -rf $HOME/.Trash/* > /dev/null 2>&1
    /bin/rm -rf $HOME/Library/*.42* > /dev/null 2>&1
    /bin/rm -rf $HOME/*.42* > /dev/null 2>&1
    /bin/chmod -R 777 $HOME/Library/Caches/Homebrew > /dev/null 2>&1
    /bin/rm -rf $HOME/Library/Caches/* > /dev/null 2>&1
    /bin/rm -rf $HOME/Library/Application\ Support/Caches/* > /dev/null 2>&1
    /bin/rm -rf $HOME/Library/Application\ Support/Slack/Service\ Worker/CacheStorage/* > /dev/null 2>&1
    /bin/rm -rf $HOME/Library/Application\ Support/Code/User/workspaceStorage/* > /dev/null 2>&1
    /bin/rm -rf $HOME/Library/Application\ Support/discord/Cache/* > /dev/null 2>&1
    /bin/rm -rf $HOME/Library/Application\ Support/discord/Code\ Cache/js* > /dev/null 2>&1
    /bin/rm -rf $HOME/Library/Application\ Support/Google/Chrome/Default/Service\ Worker/CacheStorage/* > /dev/null 2>&1
    /bin/rm -rf $HOME/Library/Application\ Support/Google/Chrome/Default/Application\ Cache/* > /dev/null 2>&1

    STORAGE_AVAILABLE=$(df -h | grep "$USER" | awk '{print($4)}' | tr 'i' 'B')
    printf "• Free storage after cleaning:$GREEN $STORAGE_AVAILABLE $RESET \n"
}

function 42_storage() {
    printf "$BLUE• Total storage: $(df -h | grep "$USER" | awk '{print($2)}' | tr 'i' 'B') $RESET \n"
    printf "$RED• Used storage:  $(df -h | grep "$USER" | awk '{print($3)}' | tr 'i' 'B') $RESET \n"
    printf "$GREEN• Available storage:  $(df -h | grep "$USER" | awk '{print($4)}' | tr 'i' 'B') $RESET \n"
}

function 42_brew() {
    rm -rf $HOME/.brew
    printf "$BLUE Clonning repo... $RESET \n"
    git clone --depth=1 https://github.com/Homebrew/brew $HOME/.brew > /dev/null 2>&1
    printf "$BLUE Building... $RESET \n"
    cat > $HOME/.brewconfig.zsh <<EOL
    # Load Homebrew config script
    export PATH=\$HOME/.brew/bin:\$PATH
    export HOMEBREW_CACHE=/tmp/\$USER/Homebrew/Caches
    export HOMEBREW_TEMP=/tmp/\$USER/Homebrew/Temp
    mkdir -p \$HOMEBREW_CACHE
    mkdir -p \$HOMEBREW_TEMP
    if df -T autofs,nfs \$HOME 1>/dev/null
        then
        HOMEBREW_LOCKS_TARGET=/tmp/\$USER/Homebrew/Locks
        HOMEBREW_LOCKS_FOLDER=\$HOME/.brew/var/homebrew
        mkdir -p \$HOMEBREW_LOCKS_TARGET
        mkdir -p \$HOMEBREW_LOCKS_FOLDER
        if ! [[ -L \$HOMEBREW_LOCKS_FOLDER && -d \$HOMEBREW_LOCKS_FOLDER ]]
            then
            echo "Creating symlink for Locks folder"
            rm -rf \$HOMEBREW_LOCKS_FOLDER
            ln -s \$HOMEBREW_LOCKS_TARGET \$HOMEBREW_LOCKS_FOLDER
        fi
    fi
EOL
    printf "$BLUE Configure... $RESET \n"
    if ! grep -q "# Load Homebrew config script" $HOME/.zshrc
        then
        cat >> $HOME/.zshrc <<EOL
        source \$HOME/.brewconfig.zsh
EOL
    fi
    source $HOME/.brewconfig.zsh > /dev/null 2>&1
    rehash > /dev/null 2>&1
    brew update > /dev/null 2>&1
    BREW_VERSION=$(brew --version | head -n 1 | awk '{print($2)}')
    printf "Homebrew $GREEN v$BREW_VERSION $RESET installed! \n"
}

function 42_docker() {
    printf "Chose a destination folder to install docker $GREEN hit enter to use goinfre(recommended) or enter a path $RESET \n"
    read -e docker_destination
    if [ -z "$docker_destination" ]
        then
        docker_destination="/goinfre/$USER/docker"
    fi
    brew uninstall -f docker docker-compose docker-machine > /dev/null 2>&1
    if [ ! -d "/Applications/Docker.app" ] && [ ! -d "~/Applications/Docker.app" ]; then
        printf "$YELLOW Docker is not installed $RESET \n"
        printf "Please install docker trough $BLUE Managed Software Center $RESET then hit enter to continue \n"
        open -a "Managed Software Center"
        read -n 1
    fi
    pkill Docker 2> /dev/null
    unlink ~/Library/Containers/com.docker.docker > /dev/null 2>&1
    unlink ~/Library/Containers/com.docker.helper > /dev/null 2>&1
    unlink ~/.docker > /dev/null 2>&1
    unlink ~/Library/Containers/com.docker.docker > /dev/null 2>&1
    unlink ~/Library/Containers/com.docker.helper > /dev/null 2>&1
    unlink ~/.docker > /dev/null 2>&1
    /bin/rm -rf ~/Library/Containers/com.docker.{docker,helper} ~/.docker > /dev/null 2>&1
    mkdir -p "$docker_destination"/{com.docker.{docker,helper},.docker} > /dev/null 2>&1
    ln -sf "$docker_destination"/com.docker.docker ~/Library/Containers/com.docker.docker > /dev/null 2>&1
    ln -sf "$docker_destination"/com.docker.helper ~/Library/Containers/com.docker.helper > /dev/null 2>&1
    ln -sf "$docker_destination"/.docker ~/.docker > /dev/null 2>&1
    printf "Docker installed in $GREEN $docker_destination $RESET \n"
    open -g -a Docker
}

function 42_code() {
    echo 'code () { VSCODE_CWD="$PWD" open -n -b "com.microsoft.VSCode" --args $* ;}' >> $HOME/.zshrc
    source $HOME/.zshrc
    printf $GREEN "You can use the code command now!" $RESET
}

function 42_ssh() {
    /bin/rm -rf $HOME/.ssh
    ssh-keygen -C "" -f ~/.ssh/id_rsa -N "" > /dev/null 2>&1
    cat ~/.ssh/id_rsa.pub | awk '{print($2)}' | pbcopy
    printf "$GREEN SSH key copied to clipboard $RESET \n"
    printf "You can add it to your intranet account trought the following link: $BLUE (link will be oppend in 5 sec...) $RESET \n"
    printf "$BLUE https://profile.intra.42.fr/gitlab_users $RESET"
    sleep 5
    open https://profile.intra.42.fr/gitlab_users
}

function 42_nvm() {
    curl -fsSL https://raw.githubusercontent.com/creationix/nvm/v0.33.6/install.sh | zsh > /dev/null 2>&1
    source $HOME/.nvm/nvm.sh
    NVM_VERSION=$(nvm --version)
    printf "nvm $GREEN v$NVM_VERSION $RESET installed! \n"
}

function 42_node() {
    if which nvm > /dev/null
        then
        nvm install node
    else
        printf "Installing nvm first..."
        42_nvm
        nvm install node > /dev/null 2>&1
        NODE_VERSION=$(node --version)
        NPM_VERSION=$(npm --version)
        printf "node $GREEN v$NODE_VERSION $RESET installed! \n"
        printf "npm $GREEN v$NPM_VERSION $RESET installed! \n"
    fi
}

function 42_oh_my_zsh() {
    if [ ! -d "$HOME/.oh-my-zsh" ]
        then
        sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" > /dev/null 2>&1
        source $HOME/.zshrc
        printf "$GREEN Oh My Zsh $RESET installed! \n"
    fi
}

function 42_reset() {
    printf "$RED Are you sure you want to reset your session? $RESET (yes/no)\n"
    read -r answer
    if [ "$answer" = "yes" ]
        then
        touch $HOME/.reset
        osascript -e 'tell application "loginwindow" to  «event aevtrlgo»'
    else
        printf "$YELLOW Aborting \n"
    fi
}

function 42_ds_store () {
    printf "$YELLOW Are you sure you want to remove .DS_Store files? $RESET (yes/no)\n"
    read -r answer
    if [ "$answer" = "yes" ]
        then
        cd $HOME
        find . -name .DS_Store -delete > /dev/null 2>&1
    else
        printf "$YELLOW Aborting\n"
    fi
    printf "$YELLOW Are you sure you want to prevent your os from creating .DS_Store files? $RESET (yes/no)"
    read -r answer
    if [ "$answer" = "yes" ]
        then
        defaults write com.apple.desktopservices DSDontWriteNetworkStores true
    else
        printf "$YELLOW Aborting"
    fi
    cd - > /dev/null 2>&1
}

function 42_help() {
    printf "$GREEN -clean $RESET      Clean your session. \n"
    printf "$GREEN -storage $RESET    Show your storage. \n"
    printf "$GREEN -brew $RESET       Install brew. \n"
    printf "$GREEN -docker $RESET     Install docker. \n"
    printf "$GREEN -code $RESET       Add code command to your zsh. \n"
    printf "$GREEN -ssh $RESET        Generate ssh key. \n"
    printf "$GREEN -nvm $RESET        Install nvm. \n"
    printf "$GREEN -node $RESET       Install node. \n"
    printf "$GREEN -oh-my-zsh $RESET  Install oh-my-zsh. \n"
    printf "$GREEN -ds-store $RESET   Remove .DS_Store files + prevent os from creating them. \n"
    printf "$GREEN -reset $RESET      Reset your session. \n"
    printf "$GREEN -help $RESET       Show this help. \n"
}

function 42() {
    case $1 in
        "-clean") 42_clean 2> /dev/null 
        ;;
        "-storage") 42_storage
        ;;
        "-brew") 42_brew
        ;;
        "-docker") 42_docker
        ;;
        "-code") 42_code
        ;;
        "-ssh") 42_ssh
        ;;
        "-nvm") 42_nvm
        ;;
        "-node") 42_node
        ;;
        "-oh-my-zsh") 42_oh_my_zsh
        ;;
        "-ds-store") 42_ds_store
        ;;
        "-reset") 42_reset
        ;;
        "-update") 42_update
        ;;
        "-help") 42_help
        ;;
        *) echo 42: "Unknown command: $1" ; 42_help
        ;;
    esac
}