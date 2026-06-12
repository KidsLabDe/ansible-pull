#!/bin/bash
# Script zum Einrichten oder Aktualisieren des Ansible Vault Passworts auf einem Client
set -e

VAULT_PASS_FILE="/root/.vault_pass"

# PRÜFUNG: Script muss als root ausgeführt werden
if [ "$EUID" -ne 0 ]; then
  echo "Bitte als root ausführen (sudo ./setup-vault.sh)"
  exit 1
fi

# Passwort zweimal abfragen, um Tippfehler zu vermeiden
read -rs -p "Vault-Passwort eingeben: " VAULT_PASSWORD < /dev/tty
echo ""
read -rs -p "Vault-Passwort wiederholen: " VAULT_PASSWORD2 < /dev/tty
echo ""

if [ "$VAULT_PASSWORD" != "$VAULT_PASSWORD2" ]; then
  echo "FEHLER: Die Passwörter stimmen nicht überein."
  exit 1
fi

echo "Erstelle Vault-Passwortdatei in $VAULT_PASS_FILE..."

# Passwort schreiben (ohne Zeilenumbruch am Ende)
printf '%s' "$VAULT_PASSWORD" > "$VAULT_PASS_FILE"

# Berechtigungen sicher setzen (nur root darf lesen/schreiben)
chmod 600 "$VAULT_PASS_FILE"
chown root:root "$VAULT_PASS_FILE"

echo "Erfolgreich eingerichtet. Berechtigungen:"
ls -l "$VAULT_PASS_FILE"
