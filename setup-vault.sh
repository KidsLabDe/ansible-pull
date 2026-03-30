#!/bin/bash
# Script zum Einrichten des Ansible Vault Passworts auf Arch Linux
set -e

# Pfad aus ansible.cfg (mit Unterstrich)
VAULT_PASS_FILE="/root/.vault_pass"

# PRÜFUNG: Script muss als root ausgeführt werden
if [ "$EUID" -ne 0 ]; then 
  echo "Bitte als root ausführen (sudo ./setup-vault.sh)"
  exit 1
fi

# PLATZHALTER: Hier dein Passwort eintragen
VAULT_PASSWORD="DEIN_PASSWORT_HIER"

if [ "$VAULT_PASSWORD" == "DEIN_PASSWORT_HIER" ]; then
  echo "FEHLER: Bitte ersetze den Platzhalter 'DEIN_PASSWORT_HIER' im Script durch dein echtes Passwort."
  exit 1
fi

echo "Erstelle Vault-Passwortdatei in $VAULT_PASS_FILE..."

# Passwort schreiben (ohne Zeilenumbruch am Ende)
echo -n "$VAULT_PASSWORD" > "$VAULT_PASS_FILE"

# Berechtigungen sicher setzen (nur root darf lesen/schreiben)
chmod 600 "$VAULT_PASS_FILE"
chown root:root "$VAULT_PASS_FILE"

echo "Erfolgreich eingerichtet. Berechtigungen:"
ls -l "$VAULT_PASS_FILE"
