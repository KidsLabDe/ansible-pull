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
ansible-playbook --check -c local site.playbook --vault-password-file .vault_pass
```

Logs are written to `/var/log/ansible-pull.log` (configured in `ansible.cfg`).

## Ansible Vault

`vars/vault.yml` is encrypted with Ansible Vault (contains e.g. `kidslab_api_key`, `openrouter_api_key`). The password lives in `.vault_pass` locally (gitignored) and in `/root/.vault_pass` on clients (set up via `setup-vault.sh` or `bootstrap.sh`). Edit credentials with:

```bash
ansible-vault edit vars/vault.yml --vault-password-file .vault_pass
```

## Architecture

`site.playbook` is the entry point — it imports three playbooks in order:

1. **`local.playbook`** — System setup: user creation (`kidslab`), WLAN config, GDM/TTY autologin, GNOME desktop settings (dconf), wallpaper, Pacoloco package mirror, cron + systemd service for automatic updates (PackageKit and GNOME update notifications are disabled — updates run exclusively via ansible-pull), shell aliases
2. **`luanti.playbook`** — Application setup: Flatpak/Flathub, Luanti (Minetest) installation and game configuration, GNOME favorites bar
3. **`ai-tools.playbook`** — AI tools: OpenCode and Qwen Code (both via pacman) against the KidsLab model server `ki.kidslab.de` with two endpoints — `/api-ext` ("Qwen (ohne Log)") and `/api-learn` ("Qwen (mit Log)", default, shown on `/learn`, `X-Learn-Id` = hostname) — using `kidslab_api_key` from vault; OpenCode additionally has DeepSeek V4 Flash via OpenRouter and TinyFish websearch (ohne API-Key). A German mentor system prompt (`files/opencode-mentor.md` → `~/.config/opencode/AGENTS.md` und `~/.qwen/QWEN.md`), a CLI plugin (`files/ki-logging-hint/tui.ts` → `~/.config/opencode/plugins/ki-logging-hint/tui.ts`, V2 discovery layout — a flat file would crash as server plugin) that shows a toast at TUI start about the active logging instance and the `/model` switch, Code-OSS with the OpenCode extension (`sst-dev.opencode` from Open VSX), and removal of the no-longer-used Goose Desktop

All playbooks run against `localhost` with `connection: local` and `become: yes`. Tasks that need the unprivileged user context use `become_user: "{{ the_user }}"`.

**`bootstrap.sh`** is a curl-friendly installer that ensures ansible/git are present, installs the `community.general` collection, then runs `ansible-pull`.

**`files/`** contains static config files deployed to clients (GDM config, dconf profiles, minetest.conf, wallpaper, update script, MOTD script).

**`templates/`** contains Jinja2 templates for the OpenCode config; credentials are pulled from the encrypted `vars/vault.yml`.

**OpenCode config — single source of truth: `files/opencode/opencode.json`.** Lab machines (this playbook) and the home setup scripts of the [Hackerwerkstatt repo](https://codeberg.org/KidsLab/Hackerwerkstatt) (`setup-client.sh`/`.ps1`, downloaded via `raw.githubusercontent.com/KidsLabDe/ansible-pull/main/files/opencode/opencode.json`) use this exact file — change it only here. It contains **no secrets**: OpenCode reads `{file:kidslab-auth}` (full `Authorization` header value, `Bearer <key>` here, `Basic <b64>` at home) and `{file:learn-id}` (`X-Learn-Id`) from files next to `opencode.json` (paths are relative to the config file; a trailing newline is ignored; a missing file becomes an empty string). The playbook merges the lab-only `kidslab-cloud` provider (`opencode_kursraum` var, OpenRouter key via `{file:openrouter-key}`) on top with `combine(..., list_merge='append')`. `limit.output` (16384) is load-bearing: OpenCode v2 sends it as `max_completion_tokens` on every request and NInfer reserves prompt + that value in its shared KV pool — see `ollama-extern` (`CLIENTS.md`, `hackathon-test.sh`). OpenCode v2 ignores `"reasoning": true` on models ("omitted unsupported legacy setting"), so it is not in the file.

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
- `bootstrap.sh` and `setup-vault.sh` prompt for the vault password interactively (reading from `/dev/tty`, since bootstrap runs via `curl | bash`) — never hardcode the real password in these scripts
