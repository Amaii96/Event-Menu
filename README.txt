# Event HUD System with Dimension Counter & Police Dispatch

Ein hochentwickeltes und minimalistisches Event-Ankündigungssystem für FiveM (kompatibel mit ESX und QBCore). Das Skript ermöglicht es der Administration, Events über ein In-Game-Dashboard zu planen. Spieler erhalten eine freischwebende visuelle Anzeige inklusive Live-Countdown, automatischer Teilnehmererfassung und integriertem Fraktions-Dispatch.

## Features

### Visuelle Integration & HUD
* **Minimalistisches Design:** Das HUD verzichtet auf blockierende Hintergründe und schwebende Boxen. Es fügt sich freischwebend in der oberen linken Bildschirmecke ein.
* **Farbgebung:** Das Design besitzt eine feste, orangefarbene Linienführung und nutzt optimierte Textschatten zur Gewährleistung der Lesbarkeit vor hellen und dunklen Hintergründen.
* **Globale Notizen:** Optionale Einblendung von Zusatzregeln oder Ausrüstungsbeschränkungen direkt unterhalb der Zeitanzeige.

### Zeitsteuerung & Audio
* **Live-Countdown:** Sekundengenaue Berechnung der verbleibenden Zeit bis zum Event-Start basierend auf Datum und Uhrzeit.
* **Laufzeiterfassung:** Nach Ablauf des Countdowns schaltet die Anzeige automatisch auf die aktive Dauer des Events um.
* **Audio-Signal:** Automatische Wiedergabe eines akustischen Signals für alle relevanten Spieler exakt zum Startzeitpunkt des Events.

### Dimensions-Schutz & Teilnehmerzähler
* **Live-Teilnehmerzähler:** Der Server prüft im Sekundentakt die Routing-Bucket-IDs und zeigt die aktuelle Spieleranzahl der Event-Dimension im HUD an.
* **Automatisches Ausblenden:** Tritt ein Spieler der konfigurierten Event-Dimension bei, blendet sich das HUD selbstständig aus, um den Bildschirm frei von Overlays zu halten. Beim Verlassen der Dimension wird das HUD wieder eingebunden.

### Interaktionen & Fraktions-Schnittstellen
* **ox_target Kompatibilität:** Optionale Registrierung globaler Spieler-Optionen zum Aufrufen des Discord-Event-Links oder zum lokalen Ausblenden des HUDs. Per Konfiguration vollständig deaktivierbar.
* **Automatisierter Polizei-Dispatch:** Optionale Übermittlung eines anonymen Leitstellenrufs an alle Einheiten des PD/MD exakt zum Startzeitpunkt des Events. Der Dispatch enthält die Ersteller-Koordinaten und den im Admin-Menü definierten Text.

---

## Administration (In-Game Dashboard)

Berechtigte Gruppen können das Steuerungsmenü über den Befehl `/eventmenu` aufrufen. Das Dashboard verfügt über eine Drei-Button-Steuerung:

1. **Ankündigung einblenden:** Validiert die Eingabefelder (inklusive HTML5-Kalenderauswahl) und schaltet das HUD serverweit aktiv. Das Admin-Menü bleibt für eventuelle Korrekturen geöffnet.
2. **Ankündigung ausblenden:** Beendet das laufende Event global und entfernt das HUD von den Bildschirmen aller Spieler sowie Nachzügler.
3. **Menü schließen:** Schließt das eigene Eingabefenster und gibt den NUI-Fokus frei, während die Ankündigung für die Spieler aktiv bleibt.

---

## Konfiguration (config.lua)

Die Steuerung des Skripts erfolgt zentral über die `config.lua`:

* `Config.Language`: Spracheinstellung für die Lokalisierung (`de` / `en`).
* `Config.ErlaubteGruppen`: Definition der administrativen Framework-Ränge für den Zugriff auf das `/eventmenu`.
* `Config.EventDimension`: Die Routing-Bucket-ID, in welcher das Event stattfindet.
* `Config.UseOxTarget`: Schalter (`true`/`false`) zur Aktivierung oder Deaktivierung der `ox_target`-Schnittstelle.
* `Config.ShowNotes`: Schalter (`true`/`false`) zur generellen Erlaubnis von globalen Notizen im Spieler-HUD.
* `Config.HUD`: Feinjustierung von Textfarben, Schriftgrößen und Bildschirmabständen.

---

## Installation

1. Kopieren Sie den Ressourcen-Ordner in Ihr `resources/`-Verzeichnis.
2. Tragen Sie Ihren Discord-Webhook in der ersten Zeile der `server.lua` ein.
3. Passen Sie die Gruppen und Einstellungen in der `config.lua` an Ihr Server-Framework an.
4. Fügen Sie `ensure [ordnername]` in Ihre `server.cfg` ein.

## Abhängigkeiten

* `es_extended` ODER `qb-core` (optional für Rechteprüfung und Dispatch)
* `ox_target` (optional für Link-Interaktionen)