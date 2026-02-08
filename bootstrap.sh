#!/bin/bash
set -e

REPO_URL="https://github.com/KidsLabDe/ansible-pull.git"
PLAYBOOK="site.playbook"
LOGFILE="/var/log/ansible-pull.log"

# Alles loggen (stdout + stderr) und gleichzeitig auf der Konsole ausgeben
exec > >(tee -a "$LOGFILE") 2>&1

echo ""
echo "=== KidsLab ansible-pull Bootstrap $(date) ==="

# Abhaengigkeiten sicherstellen
pacman -Sy --noconfirm --needed ansible git

# community.general Collection installieren
echo "Ansible Collections installieren..."
ansible-galaxy collection install community.general

# ansible-pull ausfuehren
echo "Starte ansible-pull..."
ansible-pull -U "$REPO_URL" "$PLAYBOOK"

# Timestamp fuer MOTD schreiben
echo "Letztes ansible-pull: $(date '+%d.%m.%Y %H:%M')" > /etc/ansible-pull-status
echo "=== Fertig! ==="
