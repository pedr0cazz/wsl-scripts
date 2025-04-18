# 🎉 WSL Web‑Dev Environment Scripts 🐧⭐️

![License](https://img.shields.io/github/license/pedr0cazz/wsl-scripts?style=flat-square) ![Repo Size](https://img.shields.io/github/repo-size/pedr0cazz/wsl-scripts?style=flat-square) ![Last Commit](https://img.shields.io/github/last-commit/pedr0cazz/wsl-scripts?style=flat-square)
![Issues](https://img.shields.io/github/issues/pedr0cazz/wsl-scripts?style=flat-square) ![PRs](https://img.shields.io/github/issues-pr/pedr0cazz/wsl-scripts?style=flat-square)
![Contributors](https://img.shields.io/github/contributors/pedr0cazz/wsl-scripts?style=flat-square)
![Stars](https://img.shields.io/github/stars/pedr0cazz/wsl-scripts?style=social)
![Forks](https://img.shields.io/github/forks/pedr0cazz/wsl-scripts?style=social)

Transform your fresh WSL2 Ubuntu into a **powerful web‑development environment** in minutes!

---

## 🚀 Table of Contents

1. 📝 [Overview](#overview)
2. 🛠️ [Installation](#installation) ([WSL Docs](https://docs.microsoft.com/windows/wsl))
   - 🖥️ [Installing WSL 2](#installing-wsl-2) ([Install Guide](https://docs.microsoft.com/windows/wsl/install-win10))
   - 🎨 [MesloLGS Nerd Font](#meslolg-nerd-font) ([Font Repo](https://github.com/romkatv/powerlevel10k-media))
3. ⚡️ [Quick Start](#quick-start) ([GitHub Repo](https://github.com/pedr0cazz/wsl-scripts))
4. 🧰 [Usage](#usage) ([Usage Guide](https://github.com/pedr0cazz/wsl-scripts#usage))
   - ➕➖ [Add or Remove Projects](#add-or-remove-projects)
   - 🔄 [Regenerate SSL & vhosts](#regenerate-ssl--vhosts)
5. 🔒 [Trusting SSL Certificates](#trusting-ssl-certificates) ([Cert Trust](https://docs.microsoft.com/windows/security/identity-protection/certificate-trust))
6. 🤝 [Contributing](#contributing) ([Contribute Guide](https://github.com/pedr0cazz/wsl-scripts/blob/main/CONTRIBUTING.md))
7. ⚖️ [License](#license) ([MIT](https://github.com/pedr0cazz/wsl-scripts/blob/main/LICENSE))
8. 🙏 [Acknowledgments](#acknowledgments) ([Powerlevel10k](https://github.com/romkatv/powerlevel10k))
---

## 📝 Overview

**wsl‑scripts** automates the tedious parts of setting up a web‑dev stack on WSL 2, including:

- 🛠️ **Core tooling**: Nginx, MySQL, Redis, PHP 8.x, Node LTS, Composer
- 🌈 **Fancy shell**: Zsh with Oh My Zsh, Powerlevel10k, autosuggestions, syntax highlighting
- 🔐 **Local SSL**: `*.test` certificates, Nginx vhosts, and automatic Windows hosts-file updates
- 💡 **Helpers**: PHP version selection for Composer, ssh‑agent auto‑start, SSL renewal

Everything runs **quietly**, shows a **progress bar**, and can **resume** if interrupted.

---

## 🛠️ Installation

### 🚧 Always Run as Administrator

> 🚨 **IMPORTANT:** 
> Always launch **Windows Terminal** (or PowerShell) as **Administrator**. 
> A shortcut can be created by:
> 1. Right-click desktop → **New → Shortcut** → target `wt.exe`.
> 2. Name it “WSL Terminal (Admin)”.
> 3. Right-click shortcut → **Properties → Advanced** → **Run as administrator**.

### 🖥️ Installing WSL 2

1. **Open PowerShell as Administrator** and run:
   ```powershell
   dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
   dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
   ```
2. **Reboot** your PC.
3. **Install the Linux kernel update**: https://aka.ms/wsl2kernel
4. **Set WSL 2 as default**:
   ```powershell
   wsl --set-default-version 2
   ```
5. **Install a distro** (e.g., Ubuntu 22.04 LTS) from the Microsoft Store.
6. **Launch** your WSL distro once via your Admin shortcut.

### 🎨 MesloLGS Nerd Font

Powerlevel10k requires special glyphs:

1. **Download** the four MesloLGS NF fonts:
   - Regular, Bold, Italic, Bold Italic from the [Powerlevel10k repo](https://github.com/romkatv/powerlevel10k-media).
2. **Install** each via right-click → **Install for all users**.
3. **Configure** your terminal font to `MesloLGS NF`.
4. **Verify** inside WSL:
   ```bash
   ls /mnt/c/Windows/Fonts | grep 'MesloLGS NF'
   ```

---

## ⚡️🚀 Quick Start

```bash
# 1. Clone the scripts
git clone https://github.com/pedr0cazz/wsl-scripts.git ~/.wsl_scripts
chmod +x ~/.wsl_scripts/*.sh

# 2. Run the installer
~/.wsl_scripts/wsl-setup.sh

# 3. Reload your shell
source ~/.zshrc
``` 

> ✨ After installation, your Zsh theme, SSL certificates, Nginx vhosts, and helpers are all configured.

---

## 🧰 Usage

### ➕➖ Add or Remove Projects

- **Add a new project**: create a folder under `~/www/myapp`. On next terminal startup (or manual run), vhosts & SSL will be generated.
- **Remove**: delete the project folder; the script will clean up vhost files and hosts entries.

### 🔄 Regenerate SSL & vhosts

If you add new folders or pull updates, simply run:

```bash
~/.wsl_scripts/ssl-manager.sh
```

No need to restart your shell.

---

## 🔒 Trusting SSL Certificates

1. Copy your root CA to Windows:
   ```bash
   cp ~/ssl/ca/rootCA.pem /mnt/c/Users/<YourUser>/Desktop/
   ```
2. Double-click `rootCA.pem` → **Install Certificate** → Local Machine → **Trusted Root Certification Authorities** → **Finish**.
3. Restart your browser and browse `https://<your-site>.test` securely.

---

## 🤝 Contributing

Feel free to open issues or pull requests! To update your local clone:

```bash
git -C ~/.wsl_scripts pull
```

---

## ⚖️ License

MIT © [pedr0cazz](https://github.com/pedr0cazz)

---

## 🙏 Acknowledgments

- **Powerlevel10k** Zsh theme
- **Ubuntu**, **Nginx**, **MySQL**, **Redis**, **PHP**, **Node.js**, **Composer**, **Oh My Zsh**
- Open‑source community for the tools we automate

Happy Coding! 🚀

