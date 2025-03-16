# Password Strength Evaluator

This Bash script provides a comprehensive tool to evaluate the strength of a password by calculating its entropy, assigning a security score, and offering tailored improvement suggestions. It combines cryptographic principles (entropy calculation) with practical heuristics (variety bonuses and penalties) to deliver an in-depth analysis.

## Features

- **Entropy Calculation**: Measures password strength in bits using the formula `log2(pool_size^length)`.
- **Security Score**: Assigns a score out of 100 based on entropy, length, character variety, and penalties for weaknesses.
- **Strength Classification**: Categorizes the password into five levels: Very Weak, Weak, Moderate, Strong, and Very Strong.
- **Improvement Suggestions**: Provides actionable feedback to enhance password security.
- **Secure Input**: Uses `read -s` to prevent the password from being displayed on the screen.

## Algorithm Overview

### 1. Entropy Calculation (`calculate_entropy`)
- **Input**: Password string.
- **Process**:
  - Determines the character pool size based on the presence of:
    - Lowercase letters (26 characters).
    - Uppercase letters (26 characters).
    - Digits (10 characters).
    - Special characters (32 characters, based on common punctuation).
  - Calculates entropy using `log2(pool_size^length)` with `bc` for floating-point precision.
- **Output**: Entropy in bits (rounded to two decimal places).

### 2. Password Strength Evaluation (`evaluate_password_strength`)
- **Input**: Password string.
- **Scoring Components**:
  1. **Entropy Score** (max 50 points):
     - Normalized based on 80 bits as a strong baseline: `(entropy / 80) * 50`.
  2. **Length Bonus** (max 25 points):
     - Uses an exponential decay model: `25 * (1 - e^(-length/12))`.
     - Rewards longer passwords with diminishing returns.
  3. **Variety Bonus** (max 25 points):
     - Adds points for including:
       - Uppercase letters (+6).
       - Lowercase letters (+6).
       - Digits (+6).
       - Special characters (+7).
  4. **Penalties**:
     - Repetitive patterns (e.g., "aaa" or "111"): -15 points.
     - Common passwords (e.g., "password", "123456"): -20 points.
- **Score Clamping**: Ensures the final score stays between 0 and 100.
- **Output**:
  - Password length, entropy, score, strength level, and improvement suggestions.

## Dependencies

- **Bash**: Version 4.0 or higher recommended for regex support.
- **bc**: Required for floating-point arithmetic (pre-installed on most Unix-like systems).

## Installation

1. Save the script to a file (e.g., `password_strength.sh`).
2. Make it executable:
   ```bash
   chmod +x password_strength.sh
   ```
3. Ensure `bc` is installed:
  - On Arch-Linux: `sudo pacman -S bc`
  - On Debian/Ubuntu: `sudo apt install bc`
  - On RedHat/Fedora: `sudo dnf install bc`
  - On macOS: Installed by default with Xcode tools.

## Usage

Run the script from the terminal:
   ```bash
   ./password_strength.sh
   ```
- You will be prompted to enter a password (input is hidden).
- The script will output a detailed analysis.

#### Example Output
   ```plaintext
   Please enter your password:
   Password length: 14 characters
   Entropy: 83.35 bits
   Security score: 93/100
   Strength level: Very Strong
   
   Improvement suggestions:
   - All checks passed!
   ```
   or
   ```plaintext
   Please enter your password:
   Password length: 6 characters
   Entropy: 28.53 bits
   Security score: 35/100
   Strength level: Weak
   
   Improvement suggestions:
   - Increase password length (minimum 12 characters)
   - Add uppercase letters
   - Add special characters
   ```

## Notes

- **Security**: The script processes the password locally and does not store or transmit it.
- **Limitations**:
  + The entropy model assumes uniform random character selection, which may overestimate strength for human-generated passwords.
  + The list of common passwords is minimal; expand [`common_passwords`](common_passwords.txt) array for stricter checks.
- **Precision**: Floating-point calculations rely on bc, which must `be` available on the system.

## Customization

- **Adjust Scoring**: Modify weights (e.g., entropy cap, length bonus formula) to suit your security policy.
- **Expand Common Passwords**: Add more entries to the [`common_passwords`](common_passwords.txt) array.
- **Character Pool**: Adjust the `pool_size` increments in `calculate_entropy` for different character sets.

## License

This script is released under the [MIT License](LICENSE). Feel free to modify and distribute it as needed.

## Contributing

Suggestions and pull requests are welcome! Please submit feedback or improvements via GitHub (if hosted) or directly to the author.

> [!NOTE]
> This [README.md](README.md) and the code-comments have been rewritten with assistance from Grok 3.