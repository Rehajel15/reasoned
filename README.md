# Reasoned

Eine Flutter-App, die politische Debatten so erzwingt, wie sie eigentlich
laufen sollten: mit Klarnamen, Steelman, Cooldown, geplatzten Filterblasen und
begründeten Antworten statt Likes.

Reasoned ist ein lokaler Prototyp zur Schulaufgabe „Mangelnde
Debattenkultur? – Lösungen reflektieren" (Buch S. 228 Nr. 2). Die App setzt
fünf Regeln für eine konstruktive Debattenkultur direkt im UI durch.

## Die fünf Regeln

| # | Regel | Wo sie greift |
|---|-------|---------------|
| 1 | **Zeige dich** – Klarnamen-Pflicht, kein anonymes Posten | Onboarding mit Vor- + Nachname und simulierter Verifizierung |
| 2 | **Schätze deine Gegner** – Steelman vor Kritik | Beim Antworten mit „Ablehnung" wird das Antwortfeld erst freigeschaltet, wenn die Gegenposition (≥ 80 Zeichen) wohlwollend zusammengefasst wurde |
| 3 | **Bewahre Ruhe** – 15 Minuten Abkühlzeit für emotionale Beiträge | Erkennt aufgeladene Wörter, Großbuchstaben-Schreierei und mehrere Ausrufezeichen, hält den Beitrag in einer Warteschlange zurück |
| 4 | **Platzt deine Blase** – Gegenpositionen im Feed | Der Feed mischt Beiträge so, dass Gegenpositionen zuerst erscheinen und sich mit der eigenen Sicht abwechseln |
| 5 | **Begründe statt bewerte** – keine Likes/Dislikes | Antworten brauchen mindestens 120 Zeichen Begründung; kürzere Beiträge werden angezeigt, aber nicht gezählt |

Beim ersten Start zeigt eine eigene Regel-Seite alle fünf Regeln. Erst wenn
sie aktiv akzeptiert werden, kommt der Feed. Die Seite ist später jederzeit
über die Einstellungen wieder erreichbar.

## Funktionen

- **Profilbild (optional)**: Beim Onboarding kann ein Foto ausgewählt oder
  aufgenommen werden (`image_picker`). Wer keins hochlädt, bekommt einen
  farbigen Kreis mit dem Anfangsbuchstaben des Vornamens. Demo-Nutzer haben
  gebündelte DiceBear-Avatare.
- **Klarname + Stadt + Verifizierung**: Anonyme Konten gibt es nicht; im
  Prototyp wird die Verifizierung simuliert.
- **Themen-Farbsystem**: Tempolimit (orange), Bürgergeld (grün),
  Klima/Wirtschaft (teal), Wahlrecht ab 16 (lila). Jeder Beitrag bekommt
  einen Farbstreifen, der das Thema sofort sichtbar macht.
- **Stance-Chips**: Pro / Contra / Nachfrage / Neutral mit eigenen Farben
  und Icons.
- **Steelman-Block** auf jeder ablehnenden Antwort, klar abgesetzt vom
  eigentlichen Argument.
- **Demo-Modus** in den Einstellungen: Abkühlzeit auf 15 Sekunden statt 15
  Minuten, damit Regel 3 sofort testbar ist.
- **Perspektivwechsel**: Vier vorab angelegte verifizierte Demo-Nutzer
  können in den Einstellungen gewechselt werden – damit lässt sich der
  Filterblasen-Mix aus mehreren Sichtwinkeln erleben.

## Setup

Voraussetzungen:

- Flutter 3.41+ / Dart 3.11+
- Android-Emulator oder physisches Android-Gerät mit aktiviertem
  USB-Debugging (alternativ: iOS, Windows, Web — ungetestet, sollte aber
  laufen)

Installation und Start:

```bash
flutter pub get
flutter run
```

App-Icons regenerieren (nur nötig, wenn `assets/icon/icon.png` geändert wird):

```bash
python tool/make_icon.py
dart run flutter_launcher_icons
```

## Projektstruktur

```
lib/
  main.dart                       # App-Entry, Theme, Routing-Conditional
  app_state.dart                  # ChangeNotifier mit Demo-Daten,
                                  # Cooldown-Timer, Filterblasen-Mix
  models.dart                     # AppUser, Post, Reply, Topic, Stance
  emotion_detector.dart           # Erkennt aufgeladene Beiträge
  screens/
    onboarding_screen.dart        # Klarname + Verifizierung + optionales Profilbild
    rules_screen.dart             # Pflicht-Regelseite mit Akzeptieren-Button
    feed_screen.dart              # Mischt Gegenpositionen ein
    post_detail_screen.dart       # Beitrag + Antworten
    compose_post_screen.dart      # Neuer Beitrag, Cooldown-Trigger
    compose_reply_screen.dart     # Antwort mit Pflicht-Steelman bei Ablehnung
    pending_screen.dart           # Wartende Beiträge mit Countdown
    settings_screen.dart          # Demo-Modus, Perspektivwechsel
  widgets/
    post_card.dart
    reply_card.dart
    stance_chip.dart              # StanceChip + TopicChip
    rule_banner.dart
    user_avatar.dart              # Asset- + File-Pfad-fähiges Avatar-Widget

assets/
  avatars/                        # 4 DiceBear-Avatare (PNG) für Demo-User
  icon/                           # Quell-Icon + adaptive Foreground-Layer

tool/
  make_icon.py                    # Generiert assets/icon/*.png mit Pillow
```

## Architektur

Bewusst minimal: Ein einzelner `AppState extends ChangeNotifier` hält Nutzer,
Posts, Pending-Posts und Demo-Modus. UI hängt an `ListenableBuilder` —
keine externen State-Pakete, keine Persistenz. Das ist absichtlich, weil
Reasoned ein didaktischer Prototyp ist und die Regel-Logik im Vordergrund
steht.

Die Cooldown-Mechanik nutzt einen `Timer.periodic`, der wartende Posts nach
Ablauf in den Feed schiebt. Der Filterblasen-Mix wertet aus, welche Stance der
aktuelle User pro Thema dominiert vertritt, und sortiert Gegenpositionen nach
vorn.

## Bilder

Screenshots werden hier später ergänzt.

## Lizenz

Privates Schulprojekt, keine Lizenz vergeben.
