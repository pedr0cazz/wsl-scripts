# 🎉 WSL Web‑Dev Environment Scripts 🐧⭐️

![GitHub](https://img.shields.io/github/license/pedr0cazz/wsl-scripts?style=flat-square) ![GitHub repo size](https://img.shields.io/github/repo-size/pedr0cazz/wsl-scripts?style=flat-square) ![GitHub last commit](https://img.shields.io/github/last-commit/pedr0cazz/wsl-scripts?style=flat-square) ![GitHub issues](https://img.shields.io/github/issues/pedr0cazz/wsl-scripts?style=flat-square) ![GitHub pull requests](https://img.shields.io/github/issues-pr/pedr0cazz/wsl-scripts?style=flat-square) ![GitHub contributors](https://img.shields.io/github/contributors/pedr0cazz/wsl-scripts?style=flat-square) ![GitHub stars](https://img.shields.io/github/stars/pedr0cazz/wsl-scripts?style=social) ![GitHub forks](https://img.shields.io/github/forks/pedr0cazz/wsl-scripts?style=social) ![GitHub watchers](https://img.shields.io/github/watchers/pedr0cazz?style=social) ![GitHub followers](https://img.shields.io/github/followers/pedr0cazz?style=social)

**Tired of manual setup?** This toolkit turns a fresh WSL 2 Ubuntu into a powerhouse web‑dev environment in one go.

---

## 🚀 Overview

WSL enables you to run Linux on Windows, but configuring PHP, Node.js, Nginx, SSL, and a fancy shell can take hours. **wsl‑scripts** automates:

- 🛠️ **Core tooling**: build-essential, Nginx, MySQL, Redis, PHP 8.x, Node LTS, Composer
- 🌈 **Fancy shell**: Zsh with Oh My Zsh, Powerlevel10k theme, autosuggestions & syntax highlighting
- 🔐 **Local SSL**: self‑signed `*.test` certificates + Nginx vhosts, with automatic Windows hosts-file editing via `wslpath` and UAC-elevated Notepad fallback
- 💡 **Smart helpers**: auto SSL-renewal, PHP version selection for Composer, ssh-agent auto‑start

Everything runs quietly with a neat loading bar and can **resume** if interrupted.

---

<p style="background-color:#ffecec; border-left: 4px solid #f00; padding: 8px;">
<strong>🚨 IMPORTANT:</strong> Please <u>always</u> launch your WSL/Windows Terminal as <strong>Administrator</strong>.<br>
Without admin rights, automatic hosts-file edits and other privileged operations will fail.
</p>

## 🖥️ Installing WSL 2

Follow these steps on **Windows 10/11** to install and configure WSL 2:

1. **Open PowerShell as Administrator**:
   - Search `PowerShell`, right-click → **Run as administrator**.
2. **Enable required Windows features**:
   ```powershell
   dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
   dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
   ```
3. **Reboot** your PC.
4. **Install the Linux kernel update** (MSI): https://aka.ms/wsl2kernel
5. **Set WSL 2 as default**:
   ```powershell
   wsl --set-default-version 2
   ```
6. **Install a distro** (e.g., Ubuntu 22.04 LTS) from the Microsoft Store.
7. **Launch Windows Terminal as Administrator** once to finalize setup.

**Tip: Always run WSL with admin privileges** (needed for hosts-file edits):
1. **Create a shortcut** on Desktop → point to `wt.exe` → name it “Windows Terminal (Admin)”.
2. Right-click shortcut → **Properties** → **Advanced** → check **Run as administrator**.

---

## ✅ Prerequisites

- **Windows 10/11 + WSL 2** (see above for installation)
- **Git** in WSL: `sudo apt install git`
- **Internet**: Needed to fetch packages and repos.
- 🔑 **Windows admin privileges**: to modify system files like `hosts`.
- **MesloLGS Nerd Font**: Required for Powerlevel10k icons—install on **Windows**, not inside WSL.

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
# 1. Clone scripts
git clone https://github.com/pedr0cazz/wsl-scripts.git ~/.wsl_scripts
chmod +x ~/.wsl_scripts/*.sh

# 2. Run installer
~/.wsl_scripts/wsl-setup.sh

# 3. Activate Zsh helpers
source ~/.zshrc

# 4. (Optional) Regenerate SSL & vhosts later without reopening terminal
~/.wsl_scripts/ssl-manager.sh
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

> **Behind the scenes**: the script uses `wslpath -w` to locate your Windows hosts file and UAC-elevates Notepad (via PowerShell `Start-Process`) to append or remove `127.0.0.1 <site>.test` entries automatically.

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

---

## 🙏 Acknowledgments

- Thanks to **Powerlevel10k** for the [Powerlevel10k Zsh theme](https://github.com/romkatv/powerlevel10k).
- Inspired by community scripts and dotfiles for making WSL a first‑class development environment.
- Major props to Ubuntu, Nginx, MySQL, Redis, PHP, Node.js, Composer, Oh My Zsh, and Nerd Fonts contributors.
- Powered by open‑source — you keep tooling awesome and free!

