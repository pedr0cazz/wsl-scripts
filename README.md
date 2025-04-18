# 🎉 WSL Web‑Dev Environment Scripts

🐧⭐️
![GitHub](https://img.shields.io/github/license/pedr0cazz/wsl-scripts?style=flat-square)
![GitHub repo size](https://img.shields.io/github/repo-size/pedr0cazz/wsl-scripts?style=flat-square)
![GitHub last commit](https://img.shields.io/github/last-commit/pedr0cazz/wsl-scripts?style=flat-square)
![GitHub issues](https://img.shields.io/github/issues/pedr0cazz/wsl-scripts?style=flat-square)
![GitHub pull requests](https://img.shields.io/github/issues-pr/pedr0cazz/wsl-scripts?style=flat-square)
![GitHub contributors](https://img.shields.io/github/contributors/pedr0cazz/wsl-scripts?style=flat-square)
![GitHub stars](https://img.shields.io/github/stars/pedr0cazz/wsl-scripts?style=social)
![GitHub forks](https://img.shields.io/github/forks/pedr0cazz/wsl-scripts?style=social)
![GitHub watchers](https://img.shields.io/github/watchers/pedr0cazz/wsl-scripts?style=social)
![GitHub followers](https://img.shields.io/github/followers/pedr0cazz?style=social)



**Tired of manual setup?** This toolkit turns a fresh WSL 2 Ubuntu into a powerhouse web‑dev environment in one go.

---

## 🚀 Overview

WSL enables you to run Linux on Windows, but configuring PHP, Node.js, Nginx, SSL, and a fancy shell can take hours. **wsl‑scripts** automates:

- 🛠️ **Core tooling**: build-essential, Nginx, MySQL, Redis, PHP 8.x, Node LTS, Composer
- 🌈 **Fancy shell**: Zsh with Oh My Zsh, Powerlevel10k theme, autosuggestions & syntax highlighting
- 🔐 **Local SSL**: self‑signed `*.test` certificates + Nginx vhosts
- 💡 **Smart helpers**: auto SSL-renewal, PHP version selection for Composer, ssh-agent auto‑start

Everything runs quietly with a neat loading bar and can **resume** if interrupted.

---

## 📦 What's Inside?

```text
~/.wsl_scripts/
├── wsl-setup.sh       # 🏗️ Installer script
├── ssl-manager.sh     # 🔐 SSL & Nginx vhost manager
└── zshrc-helpers.sh   # 🦄 Zsh helper snippets
```

---

## ✅ Prerequisites

1. **Windows 10/11 + WSL 2**: Install Ubuntu or Debian from Microsoft Store.
2. **Git** in WSL: `sudo apt install git`
3. **Internet**: Needed to fetch packages and repos.
4. **MesloLGS Nerd Font**: Required for Powerlevel10k icons—install on **Windows**, not inside WSL.

---

## 🎨 Installing the MesloLGS Nerd Font

Powerlevel10k needs special glyphs. Follow these steps on **Windows**:

1. **Download** the four patched fonts:
   - [MesloLGS NF Regular.ttf](https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf)
   - [MesloLGS NF Bold.ttf](https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold.ttf)
   - [MesloLGS NF Italic.ttf](https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Italic.ttf)
   - [MesloLGS NF Bold Italic.ttf](https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold%20Italic.ttf)
2. **Install** each by right‑click → **Install for all users**.
3. **Select** in your terminal:
   - **Windows Terminal**: Settings → Profiles → Ubuntu → Appearance → **Font face** → `MesloLGS NF`
   - **Legacy Console**: Title bar → Properties → **Font** → choose `MesloLGS NF`
4. **Restart** your terminal.

> **Tip**: Verify inside WSL:
> ```bash
> ls /mnt/c/Windows/Fonts/ | grep 'MesloLGS NF'
> ```

> ✨ _Credit: Powerlevel10k_ – the easiest, most minimal Zsh theme with instant prompt and over 200 icons. See its documentation: https://github.com/romkatv/powerlevel10k

---

## ⚡️ Quick Start

```bash
# 1. Clone scripts
git clone https://github.com/pedr0cazz/wsl-scripts.git ~/.wsl_scripts
chmod +x ~/.wsl_scripts/*.sh

# 2. Run installer
~/.wsl_scripts/wsl-setup.sh

# 3. Activate Zsh helpers
source ~/.zshrc
```

During install you’ll choose:
- State file (resume checkpoint)
- Project root (default `~/www`)
- SSL dir (default `~/ssl`)
- Repo URL & local path

---

## 🔐 Trusting `*.test` SSL in Windows

1. Copy the root CA into Windows:
   ```bash
   cp ~/ssl/ca/rootCA.pem /mnt/c/Users/<YourUser>/Desktop/
   ```
2. Double-click **rootCA.pem** → **Install Certificate** → Local Machine → **Trusted Root Certification Authorities** → Finish.
3. Restart browser & visit `https://myapp.test` safely.

---

## 🛠️ Detailed Tutorial for Beginners

1. **Create a project**:
   ```bash
   mkdir -p ~/www/myapp && cd ~/www/myapp
   composer create-project laravel/laravel .
   ```
2. **New terminal** opens Zsh → SSL manager runs → site configured.
3. **Browse**: https://myapp.test 🖥️🔒
4. **Composer**: auto-selects your PHP version.
5. **SSH**: key loaded automatically.

---

## 🤝 Contributing & Support

Questions, issues, or pull requests welcome!  
To update:
```bash
git -C ~/.wsl_scripts pull
```  
Reach out via GitHub issues.

---

## ⚖️ License

MIT License – see [LICENSE](./LICENSE).
Feel free to use, modify, and share this toolkit.
No warranty, but I hope it saves you time!
---

## 🙏 Acknowledgments

- Thank you to the **Powerlevel10k** team for creating the [Powerlevel10k Zsh theme](https://github.com/romkatv/powerlevel10k), which inspired our shell setup and UX enhancements.
- Inspired by various community scripts and dotfiles for making WSL a first‑class development environment.
- Special thanks to contributors and maintainers of open‑source projects this relies on: Ubuntu, Nginx, MySQL, Redis, PHP, Node.js, Composer, Oh My Zsh, and Nerd Fonts authors.
- Powered by the generous open‑source community — you keep tooling awesome and free!"