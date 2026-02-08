#!/bin/bash
set -e

REPO_URL="https://github.com/KidsLabDe/ansible-pull.git"
PLAYBOOK="site.playbook"
LOGFILE="/var/log/ansible-pull.log"

# Alles loggen (stdout + stderr) und gleichzeitig auf der Konsole ausgeben
exec > >(tee -a "$LOGFILE") 2>&1

echo ""
echo "=== KidsLab ansible-pull Bootstrap $(date) ==="

# Ansible installieren falls nicht vorhanden
if ! command -v ansible-pull &> /dev/null; then
    echo "Ansible wird installiert..."
    apt-get update
    apt-get install -y ansible git python3-apt
fi

# community.general Collection installieren
echo "Ansible Collections installieren..."
ansible-galaxy collection install community.general

# ansible-pull ausfuehren
echo "Starte ansible-pull..."
ansible-pull -U "$REPO_URL" "$PLAYBOOK"

echo "=== Fertig! ==="
