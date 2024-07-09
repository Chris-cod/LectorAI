
# LectorAI Frontend

## Voraussetzungen

- **Flutter SDK**: [Installieren](https://docs.flutter.dev/get-started/install)
- **IDE (Android Studio oder Visual Studio Code)**:
  - Android Studio: [Installieren](https://developer.android.com/studio)
  - Visual Studio Code: [Installieren](https://code.visualstudio.com/)
- **Plugins**:
  - Dart und Flutter Plugins über den Plugin-Marktplatz Ihrer IDE installieren
- **Physisches Android-Gerät** mit aktiviertem USB-Debugging

### Installation überprüfen

Stellen Sie sicher, dass Flutter korrekt installiert ist:
```sh
flutter doctor
```

### Repository klonen

Klonen Sie das Repository mit folgendem Befehl:
```sh
git clone https://github.com/Chris-cod/LectorAI.git
```

### Abhängigkeiten installieren

Öffnen Sie das Projekt in Ihrer IDE und installieren Sie die Abhängigkeiten:
```sh
flutter pub get
```

### Gerät verbinden*

Verbinden Sie Ihr Android-Gerät und überprüfen Sie, ob es erkannt wird:
```sh
flutter devices
```
**Hinweis:** Eine genaue Anleitung zum Verbinden des Geräts finden Sie unter dem folgenden Link: [Einstieg in die Entwicklung von Flutter-Apps](https://drive.google.com/file/d/1m1ny3-cegguKGIi6dtfRIz3d6570gdpR/view).

### App ausführen

Um die App auf einem spezifischen Gerät zu starten:
```sh
flutter run -d <device_id>
```

### IP-Adresse anpassen

Die App starten, auf das Einstellungs-Icon auf der Login-Seite drücken, 
um auf die Einstellungsseite zu gelangen. 
Dort gibt man seine lokale IP-Adresse ein und speichert diese, damit man sich anmelden kann.

**Wichtig:** Diese App ist ausschließlich auf Android-Geräten funktionsfähig.
