# VOIDBOUND

Godot-4.x-Prototyp des PC-Hauptmenüs für **VOIDBOUND**, optimiert für 1920×1080 (16:9).

## Enthalten

- `MainMenu.tscn` – responsive Control- und Container-Struktur
- `MainMenu.gd` – bestehende Menüsignale, Navigation und Hover-Animationen
- `MainMenuTheme.tres` – Dark-Futuristic-Tactical-Theme
- `project.godot` – direkt startbares Godot-4-Projekt

## Hintergrundgrafik

Die finale Grafik wird unter folgendem Pfad erwartet:

`res://assets/ui/main_menu/main_menu_background.png`

Fehlt die Datei, verwendet das Menü automatisch den vorhandenen Placeholder und startet weiterhin ohne Ladefehler.

## Testen

1. Projekt in Godot 4.x importieren.
2. `project.godot` öffnen.
3. Mit **F6** die Szene oder mit **F5** das Projekt starten.

Das Repository enthält ausschließlich eigene UI-Strukturen und Placeholder; keine Assets anderer Spiele.

*** Add File: VOIDBOUND_MainMenu_Final_PC/assets/ui/main_menu/README.md
# Main-menu assets

Lege das fertige Hintergrundbild hier als `main_menu_background.png` ab.

Die Szene lädt es zur Laufzeit und fällt bei einer fehlenden Datei sicher auf den Placeholder zurück.

