#!/bin/bash
set -e

REPO_URL="https://github.com/KidsLabDe/ansible-pull.git"
PLAYBOOK="site.playbook"
LOGFILE="/var/log/ansible-pull.log"

# Alles loggen (stdout + stderr) und gleichzeitig auf der Konsole ausgeben
exec > >(tee -a "$LOGFILE") 2>&1

echo ""
echo "=== KidsLab ansible-pull Bootstrap $(date) ==="

# Volles System-Upgrade (Arch: nie partielles -Sy ohne -u verwenden)
pacman -Syu --noconfirm --needed ansible git

# Falls Python aktualisiert wurde, kann das ansible-Modul fehlen.
# In diesem Fall ansible neu installieren.
if ! python -c "import ansible" 2>/dev/null; then
    echo "Ansible Python-Modul nicht gefunden, reinstalliere ansible..."
    pacman -S --noconfirm ansible
fi

# community.general Collection installieren
echo "Ansible Collections installieren..."
ansible-galaxy collection install community.general

# ansible-pull ausfuehren
echo "Starte ansible-pull..."
ansible-pull -U "$REPO_URL" "$PLAYBOOK"

# Timestamp fuer MOTD schreiben
echo "Letztes ansible-pull: $(date '+%d.%m.%Y %H:%M')" > /etc/ansible-pull-status
echo "=== Fertig! ==="
