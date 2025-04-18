# 🎉 WSL Web‑Dev Environment Scripts 🐧⭐️

![License](https://img.shields.io/github/license/pedr0cazz/wsl-scripts?style=flat-square)
![Repo Size](https://img.shields.io/github/repo-size/pedr0cazz/wsl-scripts?style=flat-square)
![Last Commit](https://img.shields.io/github/last-commit/pedr0cazz/wsl-scripts?style=flat-square)
![Issues](https://img.shields.io/github/issues/pedr0cazz/wsl-scripts?style=flat-square)
![PRs](https://img.shields.io/github/issues-pr/pedr0cazz/wsl-scripts?style=flat-square)
![Contributors](https://img.shields.io/github/contributors/pedr0cazz/wsl-scripts?style=flat-square)
![Stars](https://img.shields.io/github/stars/pedr0cazz/wsl-scripts?style=social)
![Forks](https://img.shields.io/github/forks/pedr0cazz/wsl-scripts?style=social)

Transform your fresh WSL 2 Ubuntu into a **powerful web‑development environment** in minutes!

---

## 🚀 Table of Contents

1. 📝 [Overview](#overview)
2. 🛠️ [Installation](#installation)
   - 🖥️ [Installing WSL 2](#installing-wsl-2)
   - 🎨 [MesloLGS Nerd Font](#meslolg-nerd-font)
3. ⚡️ [Quick Start](#quick-start)
4. 🧰 [Usage](#usage)
   - ➕➖ [Add or Remove Projects](#add-or-remove-projects)
   - 🔄 [Regenerate SSL & vhosts](#regenerate-ssl--vhosts)
   - 📚 [Laravel Project Example](#laravel-project-example)
5. 🔒 [Trusting SSL Certificates](#trusting-ssl-certificates)
6. 🛠️ [Other Stuff](#other-stuff)
   - ⚙️ [Configure Git](#configure-git)
   - 🚚 [Import Laragon Projects](#import-laragon-projects)
   - 🔑 [SSH Keys](#ssh-keys)
7. 🤝 [Contributing](#contributing)
8. ⚖️ [License](#license)
9. 🙏 [Acknowledgments](#acknowledgments)

---

## 📝 Overview

**wsl‑scripts** automates setting up a complete web‑dev stack on WSL 2:

- 🛠️ **Core tooling**: Nginx, MySQL, Redis, PHP 8.x, Node LTS, Composer
- 🌈 **Fancy shell**: Zsh with Oh My Zsh, Powerlevel10k, autosuggestions, syntax highlighting
- 🔐 **Local SSL**: `*.test` certificates, Nginx vhosts, and automatic Windows hosts-file updates
- 💡 **Helpers**: PHP version selection for Composer, ssh-agent auto-start, SSL renewal

Everything runs **quietly**, shows a **progress bar**, and can **resume** if interrupted.

---

## 🛠️ Installation

### 🚧 Always Run as Administrator

> 🚨 **IMPORTANT:** Always launch **Windows Terminal** (or PowerShell) as **Administrator**.
> Create a shortcut to `wt.exe` and enable **Run as administrator** in its properties.

### 🖥️ Installing WSL 2

1. Open PowerShell as Administrator and run:

   ```powershell
   dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
   dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
   ```

2. Reboot your PC.
3. Install the Linux kernel update: https://aka.ms/wsl2kernel
4. Set WSL 2 as default:

   ```powershell
   wsl --set-default-version 2
   ```

5. Install a distro (e.g., Ubuntu 22.04 LTS) from the Microsoft Store.
6. Launch your WSL distro once via the Admin shortcut.

### 🎨 MesloLGS Nerd Font

Powerlevel10k requires special glyphs:

1. Download the four MesloLGS NF fonts (Regular, Bold, Italic, Bold Italic) from the [powerlevel10k-media repo](https://github.com/romkatv/powerlevel10k-media).
2. Install each via right-click → **Install for all users**.
3. Configure your terminal font to **MesloLGS NF**.
4. Verify inside WSL:

   ```bash
   ls /mnt/c/Windows/Fonts | grep 'MesloLGS NF'
   ```

---

## ⚡️ Quick Start

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
> 💡 The SSL & vhosts manager runs automatically on each new shell.

---

## 🧰 Usage

### ➕➖ Add or Remove Projects

- **Root:** Projects live in `$WEB_ROOT` (default `~/www`).
- **Add:**
  ```bash
  mkdir -p "$WEB_ROOT/myapp"
  ```
  On next shell launch, SSL & vhost for `myapp.test` is generated.
- **Remove:**
  ```bash
  rm -rf "$WEB_ROOT/myapp"
  ```
  Vhost and hosts entry are cleaned up automatically.

### 🔄 Regenerate SSL & vhosts

```bash
~/.wsl_scripts/ssl-manager.sh
```

### 📚 Laravel Project Example

1. Create a new Laravel app under your project root:

   ```bash
   cd "$WEB_ROOT"
   composer create-project laravel/laravel blog
   ```

2. Open a new shell to auto-generate the `blog.test` vhost and certificates.
3. Visit: https://blog.test
4. If needed, set folder permissions:

   ```bash
   chmod -R 775 blog/storage blog/bootstrap/cache
   ```

---

## 🔒 Trusting SSL Certificates

1. Copy your root CA to Windows (Desktop):

   ```bash
   cp "$SSL_DIR/ca/rootCA.pem" /mnt/c/Users/<User>/Desktop/
   ```

2. Double-click `rootCA.pem` → **Install Certificate** → Local Machine → **Trusted Root Certification Authorities** → Finish.
3. Restart your browser and access your `.test` sites securely.

---

## 🛠️ Other Stuff

### ⚙️ Configure Git

Set your global Git username and email:

```bash
git config --global user.name "Your Name"
git config --global user.email "you@example.com"
```

### 🚚 Import Laragon Projects

Copy existing Laragon projects into your WSL project root:

```bash
cp -r /mnt/c/laragon/www/* "$WEB_ROOT/"
```

### 🔑 SSH Keys

Use your Windows SSH keys in WSL:

```bash
mkdir -p ~/.ssh
cp /mnt/c/Users/<WindowsUser>/.ssh/id_rsa* ~/.ssh/
chmod 600 ~/.ssh/id_rsa
chmod 644 ~/.ssh/id_rsa.pub
ssh-add ~/.ssh/id_rsa
```

---

## 🤝 Contributing

Feel free to open issues or PRs! To update your local clone:

```bash
git -C ~/.wsl_scripts pull
```

---

## ⚖️ License

MIT © [pedr0cazz](https://github.com/pedr0cazz)

---

## 🙏 Acknowledgments

- **Powerlevel10k** theme
- **Ubuntu**, **Nginx**, **MySQL**, **Redis**, **PHP**, **Node.js**, **Composer**, **Oh My Zsh**
- Open‑source community for all the tools

Happy Coding! 🚀

