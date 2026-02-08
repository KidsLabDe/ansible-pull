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

## Erneut ausfuehren

Einfach den curl-Befehl nochmal ausfuehren. Bereits installierte Pakete werden uebersprungen, nur Aenderungen werden angewendet.

## Struktur

```
├── site.playbook          # Haupt-Einstiegspunkt
├── local.playbook         # System-Setup
├── luanti.playbook        # Luanti Installation + Config
├── bootstrap.sh           # curl|bash Installer
├── ansible.cfg            # Log-Konfiguration
├── collections/
│   └── requirements.yml   # Ansible Collection Abhaengigkeit
└── files/                 # Konfigurationsdateien
```
