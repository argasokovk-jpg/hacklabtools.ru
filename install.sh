#!/bin/bash

echo ""
echo "┌──────────────────────────────────────────┐"
echo "│   🚀 HackLab Manager Installer v2.0     │"
echo "└──────────────────────────────────────────┘"
echo ""

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

if ! command -v git &> /dev/null; then
    echo -e "${RED}❌ Git is not installed!${NC}"
    echo "Ubuntu/Debian: sudo apt install git"
    echo "macOS: brew install git"
    echo "Windows: https://git-scm.com/download/win"
    exit 1
fi

if ! command -v python3 &> /dev/null; then
    echo -e "${RED}❌ Python3 is not installed!${NC}"
    exit 1
fi

echo -e "${YELLOW}[1/4] 📥 Cloning repository...${NC}"
git clone https://github.com/argasokovk-jpg/hacklabtools.ru.git ~/.hacklab_temp

echo -e "${YELLOW}[2/4] 📂 Creating directory...${NC}"
mkdir -p ~/.hacklab
cp -r ~/.hacklab_temp/* ~/.hacklab/
rm -rf ~/.hacklab_temp

echo -e "${YELLOW}[3/4] 🔧 Setting up...${NC}"
mkdir -p ~/.hacklab/scans
chmod +x ~/.hacklab/main.py

if [[ "$SHELL" == *"zsh"* ]]; then
    CONFIG_FILE=~/.zshrc
else
    CONFIG_FILE=~/.bashrc
fi

if ! grep -q "alias hl=" "$CONFIG_FILE"; then
    echo "" >> "$CONFIG_FILE"
    echo "# HackLab Manager" >> "$CONFIG_FILE"
    echo 'alias hl="python3 ~/.hacklab/main.py"' >> "$CONFIG_FILE"
fi

echo -e "${YELLOW}[4/4] 📦 Checking dependencies...${NC}"

if command -v pip3 &> /dev/null && [ -f ~/.hacklab/requirements.txt ]; then
    echo "Installing Python packages..."
    pip3 install -r ~/.hacklab/requirements.txt --quiet
fi

echo ""
echo -e "${GREEN}✅ Installation complete!${NC}"
echo ""
echo "┌─────────────────────────────────────────────┐"
echo "│   Next steps:                               │"
echo "│   1. Restart your terminal                  │"
echo "│   2. Type 'hl' to start HackLab Manager     │"
echo "│   3. Type 'hl learn' for tutorial           │"
echo "└─────────────────────────────────────────────┘"
echo ""
echo "📚 Documentation: https://hacklabtools.ru"
echo ""
