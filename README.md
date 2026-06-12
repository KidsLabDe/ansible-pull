# KidsLab ansible-pull

Automatische Client-Konfiguration fuer KidsLab-Rechner (Arch Linux / Manjaro).
Die Clients holen sich ihre Konfiguration selbst per `ansible-pull`.

## Installation

Einzeiler auf dem Client als root ausfuehren:

```bash
curl -s https://raw.githubusercontent.com/KidsLabDe/ansible-pull/main/bootstrap.sh | sudo bash
```

### Was passiert dabei?

1. `ansible` und `git` werden installiert (falls nicht vorhanden)
2. Die Ansible Collection `community.general` wird installiert
3. `ansible-pull` klont dieses Repo und fuehrt `site.playbook` aus

## Was wird konfiguriert?

### local.playbook (System-Setup)
- Benutzer `kidslab` anlegen (Gruppen: network, uucp)
- WLAN-Verbindung "Zukunftsnaechte" einrichten
- Autologin (GDM + TTY)
- Wallpaper + GNOME-Einstellungen (Bildschirmsperre aus, Akzentfarbe, etc.)
- GDM Login-Banner
- Pacoloco-Mirror (192.168.178.95:9129) wenn im Netzwerk erreichbar

### luanti.playbook (Luanti/Minetest)
- Flatpak + Flathub einrichten
- Luanti (ehemals Minetest) via Flatpak installieren
- Spielkonfiguration (`minetest.conf`) und Serverliste deployen

## Log

Alle Ausfuehrungen werden protokolliert:

```bash
cat /var/log/ansible-pull.log
```

Der Zeitpunkt der letzten Ausfuehrung wird beim Terminal-Oeffnen angezeigt.

## Vault (Passwort-Verwaltung)

Sensible Daten (z.B. der OpenRouter-API-Key fuer OpenCode) sind mit Ansible Vault verschluesselt.
Damit `ansible-pull` die Secrets entschluesseln kann, muss auf jedem Client das Vault-Passwort in `/root/.vault_pass` hinterlegt sein.

### Neuen Client einrichten

Bei der Erstinstallation fragt `bootstrap.sh` das Vault-Passwort automatisch interaktiv ab.

### Vault-Passwort auf einem bestehenden Client aendern

Das Script `setup-vault.sh` auf dem Client als root ausfuehren — es fragt das Passwort interaktiv ab und schreibt `/root/.vault_pass`:

```bash
sudo bash setup-vault.sh
```

**Wichtig:** `.vault_pass` ist im `.gitignore` und darf NICHT ins Repo committed werden.

### Vault-Variable aendern

```bash
# Neuen Wert verschluesseln (z.B. opencode_auth_token oder openrouter_api_key):
ansible-vault encrypt_string 'neuer_wert' --name 'openrouter_api_key' --vault-password-file .vault_pass --encrypt-vault-id default

# Ausgabe in vars/vault.yml einfuegen
```

## Erneut ausfuehren

Einfach den curl-Befehl nochmal ausfuehren. Bereits installierte Pakete werden uebersprungen, nur Aenderungen werden angewendet.

## Struktur

```
├── site.playbook          # Haupt-Einstiegspunkt
├── local.playbook         # System-Setup
├── luanti.playbook        # Luanti Installation + Config
├── ai-tools.playbook      # OpenCode
├── bootstrap.sh           # curl|bash Installer
├── setup-vault.sh         # Vault-Passwort auf Client einrichten
├── ansible.cfg            # Log-Konfiguration
├── collections/
│   └── requirements.yml   # Ansible Collection Abhaengigkeit
├── files/                 # Konfigurationsdateien
├── templates/
│   └── opencode.json.j2   # OpenCode Config (Jinja2 Template)
└── vars/
    └── vault.yml          # Verschluesselte Zugangsdaten
```
