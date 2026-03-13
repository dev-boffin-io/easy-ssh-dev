# easy-ssh-dev

> A lightweight, portable SSH management toolkit for Linux — CLI tools written in Go, GUI written in Python + GTK3 + VTE.

easy-ssh-dev simplifies SSH workflows by automatically managing keys, caching hosts, and providing a full suite of CLI utilities. An optional GTK3 GUI frontend provides a tabbed terminal interface with all tools accessible from a toolbar.

Designed to work on standard Linux desktops as well as ARM64/proot/Termux environments.

---

## Contents

- [Features](#features)
- [Project Structure](#project-structure)
- [Requirements](#requirements)
- [Installation](#installation)
- [CLI Tools](#cli-tools)
- [GUI](#gui)
- [Configuration](#configuration)
- [Build Reference](#build-reference)
- [License](#license)

---

## Features

### SSH Management

- **Smart connect** — on first connection, tests key-based auth, installs key via `ssh-copy-id` if needed, then caches the host
- **Raw connect** — bypass cache and key-copy entirely; connects directly via `ssh -p <port> <user@host>`
- **Host cache** — all known hosts stored in `~/.ssh/sshx.json`, no manual config needed
- **Auto key generation** — generates `ed25519` key if none exists
- **IPv4 and IPv6** — supports `user@host:port` and `user@[::1]:port` formats
- **Fuzzy host picker** — interactive `fzf`-powered menu via `sshx --menu`
- **Zero subprocess overhead** — connects via `syscall.Exec`, replacing the current process

### CLI Utilities

| Binary | Description |
|--------|-------------|
| `sshx` | Smart SSH connection manager — connect, raw, list, menu, doctor, remove |
| `sshx-key` | `ed25519` SSH key generator with SSH agent integration |
| `sshx-cpy` | Injection-safe SSH public key installer for remote hosts |
| `sshx-reset` | SSH environment cleanup — removes junk files, resets `known_hosts` |
| `git-auth` | Interactive GitHub SSH authentication wizard |
| `scpx` | Recursive SCP wrapper for push/pull file transfer |

### GUI

- GTK3 + VTE tabbed terminal interface
- Catppuccin Mocha dark theme
- Full toolbar with all CLI tools accessible as dialogs
- SSH connect dialog with Raw mode checkbox
- SCPX file transfer dialog with file/folder browser
- Integrated Doctor — checks all project binaries and system dependencies at a glance

### Build System

- Makefile with grouped targets (`deps`, `build`, `install`, `clean`)
- OS-aware dependency installer supporting 5 distro families
- CLI-only or full CLI + GUI build modes
- Dry-run simulation for all build operations
- Portable scripts — works on standard Linux and ARM64/proot/Termux

---

## Project Structure

```
easy-ssh-dev/
│
├── bin/                        # Compiled CLI binaries (build output)
│   ├── sshx                    # Main SSH manager
│   ├── sshx-key                # SSH key generator
│   ├── sshx-cpy                # SSH public key installer
│   ├── sshx-reset              # SSH environment cleanup
│   ├── git-auth                # GitHub SSH auth wizard
│   └── scpx                    # Secure file transfer
│
├── src/                        # Go source code
│   ├── main.go                 # sshx — connect, raw, list, menu, doctor, remove
│   ├── init.go                 # sshx-dev installer/uninstaller (symlinks, desktop entry)
│   ├── sshx-key.go             # ed25519 key generation + SSH agent
│   ├── sshx-cpy.go             # Injection-safe authorized_keys installer
│   ├── sshx-reset.go           # SSH dir cleanup, known_hosts reset
│   ├── git-auth.go             # GitHub auth check + interactive setup wizard
│   ├── scpx.go                 # Recursive SCP push/pull, IPv4/IPv6
│   └── go.mod
│
├── gui/                        # GTK3 GUI frontend
│   ├── easy-ssh-gui.py         # Python GTK3 + VTE tabbed terminal application
│   ├── sshx-gui                # Compiled GUI binary (PyInstaller output)
│   └── _internal/              # PyInstaller bundled runtime files
│
├── build/                      # Build scripts and assets
│   ├── build-bin               # Compiles all Go binaries → bin/
│   ├── build-init              # Compiles sshx-dev installer runner
│   ├── build-gui               # Builds GUI via PyInstaller → gui/
│   ├── build-deps              # OS-aware dependency installer
│   └── ssh-terminal.png        # GUI application icon
│
├── build-install               # Main build + install orchestrator
├── sshx-dev                    # Install/uninstall runner (symlinks to PATH)
├── Makefile                    # Build system entry point
├── sshx.toml                   # Project configuration
├── install.log                 # Auto-generated build and install log
├── LICENSE
└── README.md
```

---

## Requirements

### Core (required for CLI build)

| Tool | Version | Purpose |
|------|---------|---------|
| Go | 1.20+ | Build all CLI tools |
| OpenSSH | any | `ssh`, `scp`, `ssh-keygen`, `ssh-copy-id` |
| jq | any | JSON host cache processing |

### Optional

| Tool | Purpose |
|------|---------|
| `fzf` | Interactive host picker (`sshx --menu`) |

### GUI (optional)

| Dependency | Minimum | Purpose |
|-----------|---------|---------|
| Python | 3.8+ | Runtime for GUI and PyInstaller build |
| GTK | 3.0 | GUI toolkit |
| VTE | 2.91 | Terminal widget |
| python3-gi | any | Python GTK bindings (GObject introspection) |

---

## Installation

### Step 1 — Install Dependencies

Use the OS-aware `build-deps` script or the Makefile shortcuts:

```bash
# Core dependencies (Go, OpenSSH, jq)
bash build/build-deps

# CLI tools only (minimal — go, jq, ssh)
bash build/build-deps --cli

# Core + GTK/VTE GUI dependencies
bash build/build-deps --gui

# Core + build tools (gcc, make, binutils)
bash build/build-deps --build

# Everything at once, auto-confirm
bash build/build-deps --gui --build -y

# Preview all actions without applying
bash build/build-deps --dry-run
```

Makefile equivalents:

```bash
make deps          # core
make deps-cli      # CLI only
make deps-gui      # GUI dependencies
make deps-build    # build tools
make deps-all      # everything
```

**Supported systems:** Debian/Ubuntu · Fedora · Arch Linux · Alpine Linux · Termux (Android)

---

### Step 2 — Build

```bash
# Full build — CLI tools + GUI binary
make build

# CLI-only build — skip GUI
make cli

# Simulate build without making any changes
make dry-run
```

Or run the build script directly:

```bash
./build-install           # CLI + GUI
./build-install --cli     # CLI only
./build-install --dry-run # dry run
```

---

### Step 3 — Install / Uninstall

```bash
# Symlink all binaries to /usr/local/bin (or ~/.local/bin on proot/termux)
make install

# Remove all installed symlinks
make uninstall
```

---

### Other Maintenance Targets

```bash
make clean      # Remove all build artifacts (bin/, gui/sshx-gui, gui/_internal)
make rebuild    # clean + build
```

---

## CLI Tools

### `sshx` — SSH Manager

The primary tool. Manages SSH connections with automatic key setup and host caching.

```bash
sshx user@host:port          # Connect (auto key-copy + cache on first connect)
sshx user@[::1]:port         # Connect via IPv6

sshx --raw user@host:port    # Raw connect — skip cache and key-copy
sshx user@host:port --remove # Remove host from cache and known_hosts

sshx --list                  # List all cached hosts
sshx --menu                  # Interactive fuzzy picker (requires fzf)
sshx --doctor                # Run diagnostics (ssh, fzf, key detection)
sshx --version
sshx --help
```

**First connect flow:**

1. Checks `~/.ssh/sshx.json` for an existing entry
2. If new — tests key-based auth with a 5-second timeout
3. If key is not installed — runs `ssh-copy-id` automatically (password prompted once)
4. Saves the host to cache on success
5. Connects via `syscall.Exec` — replaces the current process with no subprocess overhead

**Raw mode** skips steps 1–4 entirely and connects directly via `ssh -p <port> <user@host>`. Useful for hosts that should not be cached or where key-copy is not desired.

---

### `scpx` — Secure File Transfer

Recursive SCP wrapper with IPv4/IPv6 support.

```bash
# Push local file or folder to remote
scpx push user@host:port /local/path /remote/dir

# Pull file or folder from remote
scpx pull user@host:port /remote/path /local/dir

# IPv6
scpx push user@[::1]:port /local/file /remote/dir
scpx pull user@[::1]:port /remote/file /local/dir
```

Wraps `scp -r`. Auto-creates the local destination directory on `pull`. Validates host format and port range (1–65535) before connecting.

---

### `sshx-key` — Key Generation

```bash
sshx-key email@example.com
```

Generates a new `ed25519` keypair, adds the private key to the SSH agent, and prints step-by-step instructions for adding the public key to GitHub or other services.

---

### `git-auth` — GitHub SSH Wizard

```bash
git-auth
```

Interactive wizard for setting up and verifying GitHub SSH authentication:

1. Tests SSH access to GitHub (`ssh -T git@github.com`)
2. Detects existing local keys (`~/.ssh/id_ed25519`, `~/.ssh/id_rsa`)
3. Checks SSH agent status
4. If auth fails — offers to generate a new key via `sshx-key`
5. Shows step-by-step instructions to add the key on GitHub
6. Optionally opens `https://github.com/settings/keys` in the browser
7. Re-verifies the connection after the key is added

---

### `sshx-cpy` — Copy Key to Remote Host

```bash
sshx-cpy user@host:port   # with port
sshx-cpy user@host        # defaults to port 22
sshx-cpy user@[::1]:port  # IPv6
```

Installs your local SSH public key on a remote host for passwordless login. More robust than `ssh-copy-id` — uses an injection-safe remote install script.

**How it works:**

1. Detects private key automatically: `id_ed25519` → `id_rsa`
2. Reads matching `.pub` file, or extracts it via `ssh-keygen -y` if missing
3. Connects via SSH and runs a remote script that:
   - Creates `~/.ssh/` with permissions `700`
   - Creates `authorized_keys` with permissions `600`
   - Appends the key only if not already present (no duplicates)
4. Verifies passwordless login with `BatchMode=yes`
5. Prints the exact `ssh` command to use on success

---

### `sshx-reset` — SSH Environment Cleanup

```bash
sshx-reset
```

Safely cleans `~/.ssh`:

- **Removes:** files matching `*.old`, `*.tmp`, `*.bak`, and `known_hosts`
- **Preserves:** `id_ed25519`, `id_ed25519.pub`, `authorized_keys`
- **Resets:** `known_hosts` to an empty file with permissions `600`
- **Reports:** a full summary of what was removed and what was preserved

---

## GUI

### Launch

```bash
sshx-gui                       # Compiled binary
python3 gui/easy-ssh-gui.py    # Run directly from source
```

### Toolbar Reference

| Button | Action |
|--------|--------|
| **Connect** | SSH connect dialog — enter `user@host:port`, optionally enable Raw mode |
| **List** | Show all cached hosts in a new terminal tab |
| **Doctor** | Open system check dialog — binary and dependency status |
| **Version** | Show version info in a new terminal tab |
| **Help** | Open command reference dialog for all tools |
| **Gen Key** | Generate SSH key — enter email in dialog |
| **Copy Fingerprint** | Show SSH public key fingerprint in a new tab |
| **Git Auth** | Run GitHub SSH authentication wizard |
| **SSHX Copy** | Copy SSH key to remote — enter host in dialog |
| **SSHX Reset** | Clean SSH environment |
| **SCPX** | File transfer dialog — push/pull with file and folder browser |

Each toolbar action opens its output in a **new terminal tab**. A pinned **Terminal** tab is always open on startup and cannot be closed.

### Connect Dialog — Raw Mode

The connect dialog includes a **Raw mode** checkbox. When enabled, the connection bypasses the host cache and key-copy entirely and connects via `ssh -p <port> <user@host>` directly.

### Doctor Dialog

Checks and reports the status of:

- **Project binaries:** `sshx`, `sshx-key`, `sshx-cpy`, `scpx`, `git-auth`, `sshx-reset`, `sshx-gui`
- **System dependencies:** `ssh`, `ssh-copy-id`, `ssh-keygen`

Each entry shows its full resolved path and a pass/fail status.

### Keyboard Shortcuts

| Shortcut | Action |
|----------|--------|
| `Ctrl+Shift+C` | Copy selection |
| `Ctrl+Shift+V` | Paste |
| `Ctrl+Shift+A` | Select all |

Right-click context menu provides the same actions.

---

## Configuration

### `~/.ssh/sshx.json` — Host Cache

Automatically created and managed by `sshx`. Stores known SSH hosts by connection string.

```json
{
  "user@192.168.1.10:22": {
    "user": "user",
    "host": "192.168.1.10",
    "port": 22
  }
}
```

Do not edit manually unless necessary. Use `sshx user@host:port --remove` to remove entries.

### `~/.ssh/` — Key Files

| File | Role |
|------|------|
| `id_ed25519` | Private key — auto-generated by `sshx` or `sshx-key` if missing |
| `id_ed25519.pub` | Public key — copied to remote hosts on first connect |
| `known_hosts` | Remote host fingerprints — reset by `sshx-reset` |
| `sshx.json` | Host cache used by `sshx` |

### `sshx.toml`

Project configuration file located at the project root. Used during build and install.

### `install.log`

Auto-generated log file. All build and install script output is appended here.  
Located at the project root.

---

## Build Reference

### Makefile Targets

| Target | Description |
|--------|-------------|
| `make deps` | Install core dependencies |
| `make deps-cli` | Install CLI-only dependencies |
| `make deps-gui` | Install GTK/VTE GUI dependencies |
| `make deps-build` | Install build tools (gcc, make, etc.) |
| `make deps-all` | Install all dependencies |
| `make build` | Full build — CLI + GUI |
| `make cli` | CLI-only build |
| `make dry-run` | Simulate build without changes |
| `make install` | Install binaries (requires prebuilt `sshx-dev`) |
| `make uninstall` | Remove installed binaries |
| `make clean` | Remove all build artifacts |
| `make rebuild` | `clean` + `build` |

### Build Scripts

| Script | Description |
|--------|-------------|
| `build-install` | Main orchestrator — runs all build steps, verifies artifacts, runs install |
| `build/build-bin` | Compiles all Go binaries with `CGO_ENABLED=0 -trimpath -ldflags="-s -w"` |
| `build/build-init` | Compiles `sshx-dev` installer runner |
| `build/build-gui` | Sets up venv, installs PyInstaller, builds `sshx-gui` binary |
| `build/build-deps` | Detects OS, installs required packages |

---

## License

See [LICENSE](LICENSE) for details.

---

## Author

**Sumit**  
[github.com/dev-boffin-io](https://github.com/dev-boffin-io)
