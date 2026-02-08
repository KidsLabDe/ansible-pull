#!/bin/bash
# KidsLab Update - fuehrt ansible-pull manuell aus
REPO_URL="https://github.com/KidsLabDe/ansible-pull.git"
PLAYBOOK="site.playbook"
LOGFILE="/var/log/ansible-pull.log"

exec > >(tee -a "$LOGFILE") 2>&1

echo ""
echo "=== KidsLab Update $(date) ==="

ansible-pull -U "$REPO_URL" "$PLAYBOOK"

echo "Letztes ansible-pull: $(date '+%d.%m.%Y %H:%M')" > /etc/ansible-pull-status
echo "=== Fertig! ==="
