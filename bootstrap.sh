#!/bin/bash
set -e

REPO_URL="https://github.com/KidsLabDe/ansible-pull.git"
PLAYBOOK="site.playbook"

echo "=== KidsLab ansible-pull Bootstrap ==="

# Ansible installieren falls nicht vorhanden
if ! command -v ansible-pull &> /dev/null; then
    echo "Ansible wird installiert..."
    apt-get update
    apt-get install -y ansible git
fi

# community.general Collection installieren
echo "Ansible Collections installieren..."
ansible-galaxy collection install community.general

# ansible-pull ausfuehren
echo "Starte ansible-pull..."
ansible-pull -U "$REPO_URL" "$PLAYBOOK"

echo "=== Fertig! ==="
