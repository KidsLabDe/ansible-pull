#!/bin/bash
# KidsLab Update - fuehrt ansible-pull manuell aus
REPO_URL="https://github.com/KidsLabDe/ansible-pull.git"
PLAYBOOK="site.playbook"
LOGFILE="/var/log/ansible-pull.log"
VAULT_PASS_FILE="/root/.vault_pass"

exec > >(tee -a "$LOGFILE") 2>&1

echo ""
echo "=== KidsLab Update $(date) ==="

VAULT_OPT=""
if [ -f "$VAULT_PASS_FILE" ]; then
    VAULT_OPT="--vault-password-file $VAULT_PASS_FILE"
fi

ansible-pull -U "$REPO_URL" "$PLAYBOOK" $VAULT_OPT

echo "Letztes ansible-pull: $(date '+%d.%m.%Y %H:%M')" > /etc/ansible-pull-status
echo "=== Fertig! ==="
