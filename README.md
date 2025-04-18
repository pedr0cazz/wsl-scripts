# WSL Web‑Dev Environment Scripts

Welcome to **wsl‑scripts**, a collection of helper scripts designed to streamline your web‑development setup on Windows Subsystem for Linux (WSL). With just a single installer, you can:  

- Install essential dev packages (build tools, Nginx, MySQL, Redis, PHP, Node.js, Composer, etc.)  
- Configure Zsh with Oh My Zsh, Powerlevel10k theme, and useful plugins  
- Generate and manage local SSL certificates for `*.test` domains  
- Inject shell helpers for automatic SSL-renewal, Composer versioning, and SSH agent startup

---

## Repository Contents

```text
~/.wsl_scripts/
├── wsl-setup.sh       # Main installer and orchestrator
├── ssl-manager.sh     # Generate/manage SSL certs & Nginx vhosts
└── zshrc-helpers.sh   # Zsh configuration snippets (auto-run SSL manager, composer wrapper, ssh-agent)
```

---

## Prerequisites

- **WSL 2** on Windows 10/11, running an Ubuntu (or Debian) distribution  
- **Git** installed within WSL  
- Internet connection to fetch packages and clone this repo

---

## Installation & Usage

### 1. Clone the repository

Choose a directory for your helper scripts (we recommend `~/.wsl_scripts`):

```bash
git clone git@github.com:pedr0cazz/wsl-scripts.git ~/.wsl_scripts
chmod +x ~/.wsl_scripts/*.sh
```

### 2. Run the main installer

```bash
~/.wsl_scripts/wsl-setup.sh
```

The script will prompt for:

- **State file path** (default: `~/.wsl_setup_state`) – used to resume if interrupted  
- **Project root** (default: `~/www`) – where your sites live  
- **SSL directory** (default: `~/ssl`) – certificate storage location  
- **Scripts repo URL** (default: this GitHub URL)  
- **Local clone path** (default: `~/.wsl_scripts`)

Then it will perform all setup steps *quietly*, showing a spinner and concise status for each.

### 3. Activate your Zsh helpers

After the installer finishes, either **restart your shell** or run:

```bash
source ~/.zshrc
```

This enables:

- 🛡 **Automatic SSL Manager Check**: detects new/removed project folders and regenerates certs  
- 🚀 **Smart Composer Wrapper**: auto‑selects the PHP version per project  
- 🔑 **SSH Agent Auto‑Start**: ensures your SSH key is loaded

### 4. Manual SSL Management

If you add a new project folder under your `WEB_ROOT`, the SSL manager will run on next shell launch. To force a regeneration manually:

```bash
~/.wsl_scripts/ssl-manager.sh
```

---

## Tutorial: Step‑by‑Step Example

1. **Create a new project**:  
   ```bash
   mkdir -p ~/www/myapp && cd ~/www/myapp
   composer create-project laravel/laravel .
   ```

2. **Open a new terminal** → Zsh detects change → runs `ssl-manager.sh` → creates `myapp.test` vhost and certificate.

3. **Visit** `https://myapp.test` in your browser (Windows hosts file auto‑updated).

4. **Composer commands** will automatically use the PHP version declared in your `composer.json`.

5. **SSH** commands will work immediately (agent is started and key loaded).

---

## Contributing

Feel free to open issues or pull requests. To sync updates locally:
```bash
git -C ~/.wsl_scripts pull
```  

---

## License

This project is licensed under the MIT License. See [LICENSE](./LICENSE) for details.

