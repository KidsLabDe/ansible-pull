# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Automated client configuration for KidsLab computers (educational facility) using `ansible-pull` on Arch Linux / Manjaro. Clients pull their own configuration from this Git repo. The codebase is written in **German** — all task names, comments, commit messages, and documentation use German.

## Running

**Bootstrap a new client (as root):**
```bash
curl -s https://raw.githubusercontent.com/KidsLabDe/ansible-pull/main/bootstrap.sh | sudo bash
```

**Test a playbook locally:**
```bash
sudo ansible-pull -U https://github.com/KidsLabDe/ansible-pull.git site.playbook
```

**Check syntax without running:**
```bash
ansible-playbook --syntax-check site.playbook
```

**Dry run (check mode):**
```bash
ansible-playbook --check -c local site.playbook
```

Logs are written to `/var/log/ansible-pull.log` (configured in `ansible.cfg`).

## Architecture

`site.playbook` is the entry point — it imports three playbooks in order:

1. **`local.playbook`** — System setup: user creation (`kidslab`), WLAN config, GDM/TTY autologin, GNOME desktop settings (dconf), wallpaper, Pacoloco package mirror, cron + systemd service for automatic updates, shell aliases
2. **`luanti.playbook`** — Application setup: Flatpak/Flathub, Luanti (Minetest) installation and game configuration, GNOME favorites bar
3. **`ai-tools.playbook`** — AI tools: OpenCode (via pacman), Goose Desktop (Flatpak bundle from GitHub Releases with auto-version detection), OpenCode config for Kidslab Ollama server

All playbooks run against `localhost` with `connection: local` and `become: yes`. Tasks that need the unprivileged user context use `become_user: "{{ the_user }}"`.

**`bootstrap.sh`** is a curl-friendly installer that ensures ansible/git are present, installs the `community.general` collection, then runs `ansible-pull`.

**`files/`** contains static config files deployed to clients (GDM config, dconf profiles, minetest.conf, wallpaper, update script, MOTD script).

## Key Variables (local.playbook)

- `the_user: "kidslab"` — standard non-root user account
- `pacoloco_server` / `pacoloco_port` — local package cache mirror (only used when reachable)

## Conventions

- Playbook files use `.playbook` extension (not `.yml`)
- Task names are descriptive German sentences (e.g., `"Benutzer 'kidslab' erstellen"`)
- Use fully qualified module names: `ansible.builtin.copy`, `community.general.dconf`, etc.
- Cron scheduling uses `random(seed=inventory_hostname)` to stagger client updates
- Required Ansible collection: `community.general` (declared in `collections/requirements.yml`)
- Prefer pacman for packages available in Arch repos; use Flatpak bundles from GitHub Releases (with GitHub API version detection) for apps not in repos
- Config files with credentials use `force: no` so manual edits on clients are not overwritten
- Commit messages are in German
