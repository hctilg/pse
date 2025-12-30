#!/usr/bin/env bash
set -e

APP_NAME="pse"
SCRIPT_URL="https://raw.githubusercontent.com/hctilg/pse/main/strength.sh"

if [[ $(uname -o) == "Android" ]]; then # Termux
  INSTALL_PATH="/data/data/com.termux/files/usr/bin/$APP_NAME"

  echo -e "\n  [#] Installing sst..."
  curl -s -o "$INSTALL_PATH" "$SCRIPT_URL"

  echo -e "\n  [#] Set executable permissions..."
  chmod +x "$INSTALL_PATH"
else
  INSTALL_PATH="/usr/local/bin/$APP_NAME"

  echo -e "\n  [#] Installing sst..."
  sudo curl -s -o "$INSTALL_PATH" "$SCRIPT_URL"

  echo -e "\n  [#] Set executable permissions..."
  sudo chmod +x "$INSTALL_PATH"
fi

echo -e "\n  [#] Installation completed !"
echo -e "\n - You can now run the script with the command '$APP_NAME'.\n"
