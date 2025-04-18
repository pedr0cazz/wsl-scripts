# 🎉 WSL Web‑Dev Environment Scripts 🐧⭐️

![License](https://img.shields.io/github/license/pedr0cazz/wsl-scripts?style=flat-square)
![Repo Size](https://img.shields.io/github/repo-size/pedr0cazz/wsl-scripts?style=flat-square)
![Last Commit](https://img.shields.io/github/last-commit/pedr0cazz/wsl-scripts?style=flat-square)
![Issues](https://img.shields.io/github/issues/pedr0cazz/wsl-scripts?style=flat-square)
![PRs](https://img.shields.io/github/issues-pr/pedr0cazz/wsl-scripts?style=flat-square)
![Contributors](https://img.shields.io/github/contributors/pedr0cazz/wsl-scripts?style=flat-square)
![Stars](https://img.shields.io/github/stars/pedr0cazz/wsl-scripts?style=social)
![Forks](https://img.shields.io/github/forks/pedr0cazz/wsl-scripts?style=social)

Transform a clean WSL 2 Ubuntu install into a **full-featured, secure web‑development environment** in just minutes. Whether you’re building PHP, Node, or static sites, these scripts handle installation, configuration, and SSL for you—so you can focus on coding.

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

This repository provides a set of Bash scripts to automate every step of provisioning a web‑development environment on Windows 10/11 via WSL 2:

- **Core services**: Nginx with HTTP/2, MySQL (MariaDB fallback), Redis for caching, and Node LTS for JavaScript workloads.
- **PHP ecosystem**: Parallel PHP 8.2, 8.3, and 8.4 installations, PHP-FPM pools, Composer installer, and an intelligent wrapper to pick the right PHP version per project.
- **Developer tooling**: Zsh with Oh My Zsh, Powerlevel10k theme, autosuggestions, and syntax highlighting for a blazing-fast shell experience.
- **HTTPS everywhere**: Locally‑trusted `*.test` SSL certificates, automated Nginx virtual host generation, and hosts file updates on Windows.
- **Resilience**: Quiet, resumable installer with progress bars and state checkpoints—won’t leave your system half‑configured.

With these scripts, setting up a fresh WSL 2 instance becomes a single-command task, saving hours of manual work.

---

## 🛠️ Installation

### 🚧 Prerequisites

1. **Windows Version**: Windows 10 (2004+) or Windows 11 with WSL 2 support.
2. **Virtualization**: Enabled in BIOS/UEFI.
3. **Admin Rights**: Required for enabling features and updating hosts file.

### 🚧 Always Run as Administrator

> **Note:** Many steps require elevated privileges. Launch **Windows Terminal** or **PowerShell** as Administrator to avoid permission errors.

### 🖥️ Installing WSL 2

1. Open an elevated PowerShell and enable required features:
   ```powershell
   dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
   dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
   ```
2. Reboot your machine.
3. Install the WSL 2 Linux kernel from Microsoft:
   - Download from: https://aka.ms/wsl2kernel
4. Set your default distro version to WSL 2:
   ```powershell
   wsl --set-default-version 2
   ```
5. Install Ubuntu 22.04 LTS (or another supported distro) from the Microsoft Store.
6. Launch the distro once (via your Admin Terminal) to finalize installation.

### 🎨 MesloLGS Nerd Font

**Why?** Powerlevel10k uses special glyphs for icons and powerline symbols.

1. Download the four MesloLGS NF font files (Regular, Bold, Italic, Bold Italic) from:
   https://github.com/romkatv/powerlevel10k-media
2. Install each font by right-click → **Install for all users**.
3. In Windows Terminal settings, set the font face to **MesloLGS NF**.
4. Verify inside WSL:
   ```bash
   ls /mnt/c/Windows/Fonts | grep 'MesloLGS NF'
   ```

---

## ⚡️ Quick Start

1. **Clone the repo and make scripts executable**
   ```bash
   git clone https://github.com/pedr0cazz/wsl-scripts.git ~/.wsl_scripts
   chmod +x ~/.wsl_scripts/*.sh
   ```
2. **Run the installer**
   ```bash
   ~/.wsl_scripts/wsl-setup.sh
   ```
   - The script will prompt for your project root (`~/www` by default), SSL directory (`~/ssl`), and helper-scripts path.
   - Progress indicators and automatic rollback on errors ensure a reliable run.
3. **Open a new shell or reload Zsh**
   ```bash
   source ~/.zshrc
   ```
4. **If you dont like the choosen settings you can rerun the p10k command**
   ```bash
   p10k configure
   ```
> **Result:** You now have Nginx, PHP-FPM, MySQL, Redis, Node, and Composer configured, plus a fancy Zsh prompt ready to go.

---

## 🧰 Usage

### ➕➖ Add or Remove Projects

- **Project root**: Defined during installation (`$WEB_ROOT`, default `~/www`).
- **Add a project**: Create a directory under your root. Example:
  ```bash
  mkdir -p "$WEB_ROOT/my-app"
  ```
  On your next new shell (or manual run of `ssl-manager.sh`), a vhost `my-app.test` and SSL cert will be generated.
- **Remove a project**: Delete the directory:
  ```bash
  rm -rf "$WEB_ROOT/my-app"
  ```
  The script will detect the missing folder and clean up its Nginx configuration and Windows hosts entry.

### 🔄 Regenerate SSL & vhosts

Run the SSL manager at any time to sync your project directories with Nginx configs and certificates:
```bash
~/.wsl_scripts/ssl-manager.sh
```
No shell restart needed.

### 📚 Laravel Project Example

1. Install and scaffold a new Laravel project using the Laravel installer:
   ```bash
   # Install the Laravel installer globally
   composer global require laravel/installer

   # Scaffold a new project named "blog"
   cd "$WEB_ROOT"
   laravel new blog

   
   ```
2. Open a new shell to auto-generate OR manually run the SSL manager:
   ```bash
   ~/.wsl_scripts/ssl-manager.sh
   ```
   - Nginx vhost `blog.test`
   - Self-signed SSL cert trusted by your Windows host
3. Access your site securely:
   ```url
   https://blog.test
   ```
4. If permissions issues arise, set correct ownership and mode:
   ```bash
   sudo chown -R "$USER":"$USER" blog
   chmod -R 775 blog/storage blog/bootstrap/cache
   ```

---

## 🔒 Trusting SSL Certificates


By default the installer generates a **custom CA** and issues all `*.test` certs.

1. Copy the root CA to Windows and rename to `.crt`:
   ```bash
   cp ~/ssl/ca/rootCA.pem /mnt/c/Users/<YourUser>/Desktop/rootCA.crt
   ```
2. On Windows **double-click** `rootCA.crt` → **Install Certificate**.
3. In the **Certificate Import Wizard**:
   - Choose **Local Machine**
   - Select **Place all certificates in the following store** → **Browse** → **Trusted Root Certification Authorities**
   - Click **Next** → **Finish**.
4. Restart your browser.

Now **any** `*.test` site issued by your CA will load without warnings.

---

## 🛠️ Other Stuff

### ⚙️ Configure Git

Set your name and email for commits:
```bash
# Replace with your identity
git config --global user.name "Your Name"
git config --global user.email "you@example.com"
```

### 🚚 Import Laragon Projects

Already have projects in Laragon? Copy them into WSL:
```bash
cp -r /mnt/c/laragon/www/* "$WEB_ROOT/"
``` 
Then run `ssl-manager.sh` to auto-generate vhosts and certs.

### 🔑 SSH Keys

Reuse existing Windows SSH keys:
```bash
mkdir -p ~/.ssh
cp /mnt/c/Users/<YourWindowsUser>/.ssh/id_rsa* ~/.ssh/
chmod 600 ~/.ssh/id_rsa
chmod 644 ~/.ssh/id_rsa.pub
ssh-add ~/.ssh/id_rsa
```
This enables passwordless Git over SSH inside WSL.


### PHP Install another versions command

Replace `8.4` with the desired version:
```bash
sudo apt install php8.4 php8.4-fpm php8.4-mysql php8.4-redis php8.4-curl php8.4-zip php8.4-gd php8.4-mbstring php8.4-bcmath php8.4-xml php8.4-soap php8.4-intl
```
---

## 🤝 Contributing

Contributions, issues, and feature requests are welcome!

1. Fork the repo.
2. Create a feature branch (`git checkout -b feature-name`).
3. Commit your changes (`git commit -m 'Add new feature'`).
4. Push to the branch (`git push origin feature-name`).
5. Open a Pull Request.

Please follow the [Contributor Covenant](https://www.contributor-covenant.org/) guidelines.

---

## ⚖️ License

This project is licensed under the **MIT License**. See [LICENSE](https://github.com/pedr0cazz/wsl-scripts/blob/main/LICENSE) for details.

---

## 🙏 Acknowledgments

- **Powerlevel10k** for the Zsh theme
- **Ubuntu**, **Nginx**, **MySQL**, **Redis**, **PHP**, **Node.js**, **Composer**, **Oh My Zsh** for the underlying technologies
- Open‑source community contributors and maintainers

Happy coding—and enjoy your new WSL 2 web‑dev environment! 🚀

