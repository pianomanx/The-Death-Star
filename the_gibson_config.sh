#!/bin/bash
# Charles' Death Star Build Script
# This is the personal setup script used on my "Death Star" build. It installs all the essentials and tools I need from day one.

set -e

# Colors for output
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
CYAN="\033[0;36m"
NC="\033[0m" # No Color

function print_header() {
  echo -e "${CYAN}======================================"
  echo -e " The Death Star Script Starting...." 
  echo -e "     Hold on to your butts!:
  echo -e "======================================${NC}"
}

function detect_os() {
  echo -e "${YELLOW}Detecting operating system...${NC}"
  if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
    echo -e "${GREEN}Detecting your OS: $OS${NC}"
  else
    echo -e "${RED}Unable to detect OS. Dumbass...wasting my time.${NC}"
    exit 1
  fi
}

function install_common_tools() {
  echo -e "${YELLOW}Installing core packages...${NC}"
  sudo apt update && sudo apt install -y \
    curl \
    wget \
    git \
    htop \
    btop \
    unzip \
    build-essential \
    python3 \
    python3-pip \
    neofetch \
    cowsay \
    zsh \
    lolcat \
    golang \
    fail2ban \
    evince \
    firefox \
    tmux \
    rclone
  echo -e "${GREEN}Core packages installed.${NC}"
}

function install_poetry() {
  echo -e "${YELLOW}Installing Poetry (Python dependency manager)...${NC}"
  curl -sSL https://install.python-poetry.org | python3 -
  echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
  echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc
  echo -e "${GREEN}Poetry installed and available via ~/.local/bin.${NC}"
}

function install_docker() {
  echo -e "${YELLOW}Installing Docker...${NC}"
  curl -fsSL https://get.docker.com -o get-docker.sh
  sudo sh get-docker.sh
  sudo usermod -aG docker "$USER"
  rm get-docker.sh
  echo -e "${GREEN}Docker installed.${NC}"
}

function install_chrome() {
  echo -e "${YELLOW}Installing Google Chrome...${NC}"
  wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
  sudo apt install -y ./google-chrome-stable_current_amd64.deb
  rm google-chrome-stable_current_amd64.deb
  echo -e "${GREEN}Google Chrome installed.${NC}"
}

function setup_zsh() {
  echo -e "${YELLOW}Setting up Zsh with Agnoster theme and plugins...${NC}"
  sudo apt install -y fonts-powerline
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" || true
  git clone https://github.com/zsh-users/zsh-autosuggestions \
    ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git \
    ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
  echo 'export TERM="xterm-256color"' >> ~/.zshrc
  echo 'ZSH_THEME="agnoster"' >> ~/.zshrc
  echo 'plugins=(git zsh-autosuggestions zsh-syntax-highlighting)' >> ~/.zshrc
  echo -e "${GREEN}Zsh configured with Agnoster and plugins.${NC}"
}

function install_vscode() {
  echo -e "${YELLOW}Installing Visual Studio Code...${NC}"
  wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
  sudo install -o root -g root -m 644 microsoft.gpg /etc/apt/trusted.gpg.d/
  sudo sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'
  sudo apt update
  sudo apt install -y code
  rm microsoft.gpg
  echo -e "${GREEN}VS Code installed.${NC}"
}

function configure_ssh() {
  echo -e "${YELLOW}Configuring SSH...${NC}"
  mkdir -p ~/.ssh
  chmod 700 ~/.ssh
  if [[ ! -f ~/.ssh/id_rsa ]]; then
    ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa -N ""
    echo -e "${GREEN}SSH key generated.${NC}"
  else
    echo -e "${CYAN}SSH key already exists. Skipping generation.${NC}"
  fi
}

function configure_ufw() {
  echo -e "${YELLOW}Configuring UFW (Uncomplicated Firewall)...${NC}"
  sudo apt install -y ufw
  sudo ufw default deny incoming
  sudo ufw default allow outgoing
  sudo ufw allow ssh
  sudo ufw allow http
  sudo ufw allow https
  sudo ufw enable
  echo -e "${GREEN}UFW configured and enabled.${NC}"
}

function backup_dotfiles() {
  echo -e "${YELLOW}Backing up core dotfiles to ~/dotfiles_backup...${NC}"
  mkdir -p ~/dotfiles_backup
  cp -v ~/.zshrc ~/.bashrc ~/.tmux.conf ~/.gitconfig ~/.ssh/config ~/dotfiles_backup 2>/dev/null || true
  echo -e "${GREEN}Dotfiles backed up to ~/dotfiles_backup.${NC}"
}

print_header
detect_os
install_common_tools
install_poetry
install_docker
install_chrome
install_vscode

read -p "Setup Zsh and plugins? (y/n): " e && [[ $e == [Yy]* ]] && setup_zsh
read -p "Configure SSH and keys? (y/n): " g && [[ $g == [Yy]* ]] && configure_ssh
read -p "Configure UFW firewall? (y/n): " h && [[ $h == [Yy]* ]] && configure_ufw
read -p "Backup dotfiles? (y/n): " i && [[ $i == [Yy]* ]] && backup_dotfiles

echo -e "${GREEN}Bootstrap complete! Customize this script as needed.${NC}"
