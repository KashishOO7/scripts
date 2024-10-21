#!/bin/bash

# Function to install a tool
install_tool() {
    echo "Installing $1..."
    sudo apt-get install -y $1
}

# Function to install Python package
install_pip_package() {
    echo "Installing Python package $1..."
    sudo pip3 install $1
}

# Function to clone a GitHub repository
clone_repo() {
    echo "Cloning $1..."
    git clone $1
}

# Function to prompt user for tool installation
prompt_install() {
    read -p "Do you want to install $1 tools? (y/n): " choice
    case "$choice" in 
        y|Y ) return 0 ;;
        n|N ) return 1 ;;
        * ) echo "Invalid input. Skipping $1 tools."; return 1 ;;
    esac
}

# Update and upgrade system
sudo apt-get update && sudo apt-get upgrade -y

# Install common dependencies
sudo apt-get install -y build-essential libssl-dev libffi-dev python3-dev python3-pip

# Define tool categories and their respective tools
declare -A tools

tools[general]="nmap wireshark tcpdump netcat"
tools[web]="burpsuite sqlmap nikto dirb gobuster wpscan"
tools[wireless]="aircrack-ng wifite kismet"
tools[forensics]="autopsy volatility binwalk foremost"
tools[exploitation]="metasploit-framework exploitdb set"
tools[password]="john hashcat hydra crunch"
tools[recon]="maltego recon-ng theharvester"
tools[stego]="steghide libimage-exiftool-perl outguess binwalk"

# Prompt user for each category
for category in "${!tools[@]}"; do
    if prompt_install "$category"; then
        echo "Installing $category tools..."
        for tool in ${tools[$category]}; do
            install_tool $tool
        done
    else
        echo "Skipping $category tools."
    fi
done

# Install additional tools and dependencies
install_pip_package scapy
install_pip_package pwntools

# Clone useful GitHub repositories
clone_repo https://github.com/danielmiessler/SecLists.git
clone_repo https://github.com/swisskyrepo/PayloadsAllTheThings.git

# Download additional wordlists
sudo mkdir -p /usr/share/wordlists
sudo wget https://github.com/praetorian-inc/Hob0Rules/raw/master/wordlists/rockyou.txt.gz -O /usr/share/wordlists/rockyou.txt.gz
sudo gzip -d /usr/share/wordlists/rockyou.txt.gz

echo "Installation complete!"

# Function to add a new tool
add_tool() {
    read -p "Enter the category for the new tool: " category
    read -p "Enter the name of the new tool: " tool
    if [[ -v tools[$category] ]]; then
        tools[$category]+=" $tool"
        echo "Added $tool to $category category."
    else
        tools[$category]="$tool"
        echo "Created new category $category and added $tool."
    fi
}

# Function to remove a tool
remove_tool() {
    read -p "Enter the category of the tool to remove: " category
    read -p "Enter the name of the tool to remove: " tool
    if [[ -v tools[$category] ]]; then
        tools[$category]=${tools[$category]/$tool/}
        tools[$category]=${tools[$category]//  / }  # Remove extra spaces
        echo "Removed $tool from $category category."
    else
        echo "Category $category not found."
    fi
}

# Function to display current tools
display_tools() {
    for category in "${!tools[@]}"; do
        echo "$category: ${tools[$category]}"
    done
}

# Main menu for tool management
while true; do
    echo "
Tool Management Menu:
1. Add a tool
2. Remove a tool
3. Display current tools
4. Exit
"
    read -p "Enter your choice: " menu_choice
    case $menu_choice in
        1) add_tool ;;
        2) remove_tool ;;
        3) display_tools ;;
        4) break ;;
        *) echo "Invalid choice. Please try again." ;;
    esac
done

echo "Script modifications complete. You may run the script again to install the updated tool set."