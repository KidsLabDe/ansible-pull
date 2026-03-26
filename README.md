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

Sensible Daten (z.B. API-Zugangsdaten fuer OpenCode) sind mit Ansible Vault verschluesselt.
Damit `ansible-pull` die Secrets entschluesseln kann, muss auf jedem Client das Vault-Passwort hinterlegt sein.

### Neuen Client einrichten

Das Script `setup-vault.sh` auf den Client kopieren und als root ausfuehren:

```bash
sudo bash setup-vault.sh
```

Das legt `/root/.vault_pass` an. Diese Datei wird von `ansible.cfg` automatisch verwendet.

**Wichtig:** `setup-vault.sh` und `.vault_pass` sind im `.gitignore` und duerfen NICHT ins Repo committed werden.

### Vault-Variable aendern

```bash
# Neuen Wert verschluesseln:
ansible-vault encrypt_string 'neuer_wert' --name 'opencode_auth_token' --vault-password-file .vault_pass --encrypt-vault-id default

# Ausgabe in vars/vault.yml einfuegen
```

## Erneut ausfuehren

Einfach den curl-Befehl nochmal ausfuehren. Bereits installierte Pakete werden uebersprungen, nur Aenderungen werden angewendet.

## Struktur

```
├── site.playbook          # Haupt-Einstiegspunkt
├── local.playbook         # System-Setup
├── luanti.playbook        # Luanti Installation + Config
├── ai-tools.playbook      # OpenCode + Goose Desktop
├── bootstrap.sh           # curl|bash Installer
├── ansible.cfg            # Log + Vault-Konfiguration
├── collections/
│   └── requirements.yml   # Ansible Collection Abhaengigkeit
├── files/                 # Konfigurationsdateien
├── templates/
│   └── opencode.json.j2   # OpenCode Config (Jinja2 Template)
└── vars/
    └── vault.yml          # Verschluesselte Zugangsdaten
```
