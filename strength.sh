#!/usr/bin/env bash
# -*- coding: utf-8 -*-

# Calculate password entropy based on character pool size
# Arguments: $1 - password string
# Returns: Entropy in bits, calculated as log2(pool_size ^ length)
calculate_entropy() {
  local password="$1"
  local length=${#password}
  local pool_size=0

  # Calculate character pool size based on types present
  [[ "$password" =~ [a-z] ]] && pool_size=$((pool_size + 26))  # Lowercase letters
  [[ "$password" =~ [A-Z] ]] && pool_size=$((pool_size + 26))  # Uppercase letters
  [[ "$password" =~ [0-9] ]] && pool_size=$((pool_size + 10))  # Digits
  [[ "$password" =~ [[:punct:]] ]] && pool_size=$((pool_size + 32))  # Special characters

  # Compute entropy using log2(pool_size^length) with bc for precision
  if [ "$pool_size" -gt 0 ]; then
    entropy=$(echo "l($pool_size^$length)/l(2)" | bc -l)
    printf "%.2f" "$entropy"
  else
    echo "0.00"
  fi
}

# Evaluate password strength and assign a score
# Arguments: $1 - password string
# Outputs: Detailed strength analysis and score
evaluate_password_strength() {
  local password="$1"
  local length=${#password}
  local score=0
  local entropy=$(calculate_entropy "$password")

  # Base score from entropy, normalized to 50 points max
  # Assumes 80 bits entropy as a strong baseline
  score=$(echo "($entropy / 80) * 50" | bc -l)
  [ "$(echo "$score > 50" | bc)" -eq 1 ] && score=50

  # Length bonus using an exponential decay model: 25 * (1 - e^(-length/12))
  # Rewards longer passwords with diminishing returns
  length_bonus=$(echo "25 * (1 - e(-$length / 12))" | bc -l)
  score=$(echo "$score + $length_bonus" | bc -l)

  # Character variety bonus, up to 25 points
  local variety_bonus=0
  [[ "$password" =~ [A-Z] ]] && variety_bonus=$((variety_bonus + 6))  # Uppercase bonus
  [[ "$password" =~ [a-z] ]] && variety_bonus=$((variety_bonus + 6))  # Lowercase bonus
  [[ "$password" =~ [0-9] ]] && variety_bonus=$((variety_bonus + 6))  # Digit bonus
  [[ "$password" =~ [[:punct:]] ]] && variety_bonus=$((variety_bonus + 7))  # Special char bonus
  score=$(echo "$score + $variety_bonus" | bc -l)

  # Penalty for repetitive patterns (e.g., aaa or 111)
  if [[ "$password" =~ (.).*\1.*\1 ]]; then
    score=$(echo "$score - 15" | bc -l)
  fi

  # Load common passwords from `~/common_passwords.txt` into an array
  if [ -f "$HOME/common_passwords.txt" ]; then
    mapfile -t common_passwords < "$HOME/common_passwords.txt"
  else
    echo "Error: $HOME/common_passwords.txt file not found!"
    exit 1
  fi

  # Penalty for common passwords
  for word in "${common_passwords[@]}"; do
    if [[ "$password" =~ $word ]]; then
      score=$(echo "$score - 20" | bc -l)
      break
    fi
  done

  # Clamp score between 0 and 100
  score=$(printf "%.0f" "$score")
  [ "$score" -gt 100 ] && score=100
  [ "$score" -lt 0 ] && score=0

  # Display analysis results
  echo "Password length: $length characters"
  echo "Entropy: $entropy bits"
  echo "Security score: $score/100"

  # Assign strength level based on score
  if [ "$score" -ge 90 ]; then
    echo "Strength level: Very Strong"
  elif [ "$score" -ge 70 ]; then
    echo "Strength level: Strong"
  elif [ "$score" -ge 50 ]; then
    echo "Strength level: Moderate"
  elif [ "$score" -ge 30 ]; then
    echo "Strength level: Weak"
  else
    echo "Strength level: Very Weak"
  fi

  # Provide improvement suggestions based on weaknesses
  echo -e "\nImprovement suggestions:"
  [ "$length" -lt 12 ] && echo "- Increase password length (minimum 12 characters)"
  [[ ! "$password" =~ [A-Z] ]] && echo "- Add uppercase letters"
  [[ ! "$password" =~ [a-z] ]] && echo "- Add lowercase letters"
  [[ ! "$password" =~ [0-9] ]] && echo "- Add numbers"
  [[ ! "$password" =~ [[:punct:]] ]] && echo "- Add special characters"
  [[ "$password" =~ (.).*\1.*\1 ]] && echo "- Avoid repeating characters"
}

if [[ "${1,,}" == "--uninstall" ]]; then
  read -rp "Do you want to continue? (yes/No) > " answer

  if [[ ${answer,,} != "yes" ]]; then
    exit 1
  fi

  echo -e "\n[#] Uninstaling..."
  
  if [[ $(uname -o) == "Android" ]]; then # Termux
    rm -rf "/data/data/com.termux/files/usr/bin/pse"
    rm -rf "$HOME/common_passwords.txt"
  else
    sudo rm -rf "/usr/local/bin/pse"
    sudo rm -rf "$HOME/common_passwords.txt"
  fi

  wait

  echo -e "\n[#] Done."

  exit;
fi

# Prompt user for password input securely (no echo)
read -s -p "Please enter your password: " password
echo -e "\n"

# Validate that password is not empty
if [ -z "$password" ]; then
  echo "Error: Password cannot be empty!"
  exit 1
fi

# Run the password strength evaluation
evaluate_password_strength "$password"
