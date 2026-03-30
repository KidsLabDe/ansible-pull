#!/bin/bash
set -e

REPO_URL="git@github.com:KidsLabDe/ansible-pull.git"
PLAYBOOK="site.playbook"
LOGFILE="/var/log/ansible-pull.log"
VAULT_PASS_FILE="/root/.vault_pass"

# PLATZHALTER: Hier dein Passwort eintragen
VAULT_PASSWORD="DEIN_PASSWORT_HIER"

# Alles loggen (stdout + stderr) und gleichzeitig auf der Konsole ausgeben
exec > >(tee -a "$LOGFILE") 2>&1

echo ""
echo "=== KidsLab ansible-pull Bootstrap $(date) ==="

# PRÜFUNG: Script muss als root ausgeführt werden
if [ "$EUID" -ne 0 ]; then 
  echo "FEHLER: Dieses Script muss als root ausgeführt werden."
  exit 1
fi

# Vault Passwort einrichten
if [ "$VAULT_PASSWORD" != "DEIN_PASSWORT_HIER" ]; then
    echo "Richte Vault-Passwortdatei in $VAULT_PASS_FILE ein..."
    echo -n "$VAULT_PASSWORD" > "$VAULT_PASS_FILE"
    chmod 600 "$VAULT_PASS_FILE"
    chown root:root "$VAULT_PASS_FILE"
else
    if [ ! -f "$VAULT_PASS_FILE" ]; then
        echo "WARNUNG: $VAULT_PASS_FILE fehlt und VAULT_PASSWORD ist noch der Platzhalter!"
        echo "Bitte das Passwort in der bootstrap.sh eintragen."
    fi
fi

# Abhaengigkeiten sicherstellen
pacman -Sy --noconfirm --needed ansible git

# community.general Collection installieren
echo "Ansible Collections installieren..."
ansible-galaxy collection install community.general

# ansible-pull ausfuehren
echo "Starte ansible-pull..."
VAULT_OPT=""
if [ -f "$VAULT_PASS_FILE" ]; then
    VAULT_OPT="--vault-password-file $VAULT_PASS_FILE"
fi

ansible-pull -U "$REPO_URL" "$PLAYBOOK" $VAULT_OPT

# Timestamp fuer MOTD schreiben
echo "Letztes ansible-pull: $(date '+%d.%m.%Y %H:%M')" > /etc/ansible-pull-status
echo "=== Fertig! ==="
