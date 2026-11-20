# AGENTS.md

KidsLab client auto-configuration via `ansible-pull` (Arch Linux / Manjaro). Clients pull this repo and run `site.playbook` themselves. See `CLAUDE.md` for the full detail; this file is the condensed essentials.

## Commands

- Syntax check: `ansible-playbook --syntax-check site.playbook`
- Dry run without executing: `sudo ansible-playbook --check -c local site.playbook --vault-password-file .vault_pass`
- Full test run on a machine: `sudo ansible-pull -U https://github.com/KidsLabDe/ansible-pull.git site.playbook`
- There is no test suite, lint, or CI — verification is syntax-check plus `--check` dry runs.

## Structure & wiring

- `site.playbook` is the entry point; it imports `local.playbook` (system setup), `luanti.playbook` (Flatpak/Luanti), `ai-tools.playbook` (OpenCode + Qwen Code) in that order.
- All playbooks target `localhost` with `connection: local` and `become: yes`; user-level tasks use `become_user: "{{ the_user }}"` (`the_user: kidslab`).
- `bootstrap.sh` is the curl|bash installer; it reads the vault password from `/dev/tty` (stdin is the pipe) and writes `/root/.vault_pass`. Never hardcode the real password in scripts.
- Playbook files use the `.playbook` extension, not `.yml`.

## Vault

- `vars/vault.yml` is encrypted (`kidslab_api_key`, `openrouter_api_key`). Edit with `ansible-vault edit vars/vault.yml --vault-password-file .vault_pass`; new values via `ansible-vault encrypt_string ... --encrypt-vault-id default`.
- `.vault_pass` is gitignored — never commit it. A `.vault_pass` file may exist in the working tree locally; do not include its contents anywhere.

## Single source of truth

- `files/opencode/opencode.json` is the only OpenCode config — lab machines AND the home Hackerwerkstatt setup scripts fetch it raw from GitHub. It contains no secrets; credentials come from sibling `{file:kidslab-auth}` / `{file:learn-id}` / `{file:openrouter-key}` files. The playbook merges the lab-only `kidslab-cloud` provider on top; do not add secrets to the JSON itself.
- `files/opencode-mentor.md` is deployed to both `~/.config/opencode/AGENTS.md` and `~/.qwen/QWEN.md` — change it in one place here.

## Conventions

- Everything is in German: task names, comments, commit messages.
- Use fully qualified module names (`ansible.builtin.copy`, `community.general.dconf`). Required collection: `community.general` (`collections/requirements.yml`).
- Prefer pacman for Arch-repo packages; Flatpak bundles from GitHub Releases (with GitHub API version detection) otherwise.
- Config files containing credentials use `force: no` so manual client edits survive.
- Cron scheduling uses `random(seed=inventory_hostname)` to stagger client runs.
- README is stale on the Pacoloco mirror IP (`192.168.178.95`); `local.playbook` actually uses `192.168.88.18` — trust the playbook. The mirror is only used when reachable.
