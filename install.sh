#!/usr/bin/env bash

APP_NAME="pse"
SCRIPT_URL="https://raw.githubusercontent.com/hctilg/pse/main/strength.sh"
CPS_URL="https://raw.githubusercontent.com/hctilg/pse/main/common_passwords.txt"

if [[ $(uname -o) == "Android" ]]; then # Termux
  INSTALL_PATH="/data/data/com.termux/files/usr/bin/$APP_NAME"

  echo -e "\n  [#] Installing $APP_NAME..."
  curl -s -o "$INSTALL_PATH" "$SCRIPT_URL"

  echo -e "\n  [#] Set executable permissions..."
  chmod +x "$INSTALL_PATH"
else
  INSTALL_PATH="/usr/local/bin/$APP_NAME"

  echo -e "\n  [#] Installing $APP_NAME..."
  sudo curl -s -o "$INSTALL_PATH" "$SCRIPT_URL"

  echo -e "\n  [#] Set executable permissions..."
  sudo chmod +x "$INSTALL_PATH"
fi

echo -e "\n  [#] Downloading common passwords..."
curl -s -o "~/common_passwords.txt" "$CPS_URL" 

echo -e "\n  [#] Installation completed !"
echo -e "\n - You can now run the script with the command '$APP_NAME'.\n"
