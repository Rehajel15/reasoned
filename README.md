# Reasoned

> 🇩🇪 **Hinweis:** Die App-Oberfläche ist komplett auf Deutsch. Diese README
> enthält unten eine englische Fassung — die App selbst bleibt deutsch.
>
> 🇬🇧 **Note:** The app UI is in German only. An English version of this README
> is provided below — but the app itself is not translated.

<p align="center">
  <a href="https://rehajel15.github.io/reasoned/">
    <img src="https://img.shields.io/badge/%E2%96%B6%20Live--Demo%20%C3%B6ffnen-6750A4?style=for-the-badge&logo=googlechrome&logoColor=white" alt="Live-Demo öffnen">
  </a>
</p>

> ▶ **Live-Demo:** https://rehajel15.github.io/reasoned/ – eine vereinfachte
> Web-Variante der Flutter-App, die alle fünf Regeln durchspielbar macht
> (Onboarding, Rules-Screen, Feed, Steelman-Pflicht, 15-Sek-Cooldown im
> Demo-Modus). Voll bedienbar im Browser, ohne Installation.

---

## Deutsch

Eine Flutter-App, die politische Debatten so erzwingt, wie sie eigentlich
laufen sollten: mit Klarnamen, Steelman, Cooldown, geplatzten Filterblasen und
begründeten Antworten statt Likes.

Reasoned ist ein lokaler Prototyp zur Schulaufgabe „Mangelnde
Debattenkultur? – Lösungen reflektieren" (Buch S. 228 Nr. 2). Die App setzt
fünf Regeln für eine konstruktive Debattenkultur direkt im UI durch.

**Sprache:** Die gesamte Benutzeroberfläche der App ist auf Deutsch und wird
nicht übersetzt. Diese README beschreibt das Projekt selbst und ist daher
auch auf Englisch verfügbar.

### Die fünf Regeln

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

### Funktionen

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

### Setup

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

### Projektstruktur

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

### Architektur

Bewusst minimal: Ein einzelner `AppState extends ChangeNotifier` hält Nutzer,
Posts, Pending-Posts und Demo-Modus. UI hängt an `ListenableBuilder` —
keine externen State-Pakete, keine Persistenz. Das ist absichtlich, weil
Reasoned ein didaktischer Prototyp ist und die Regel-Logik im Vordergrund
steht.

Die Cooldown-Mechanik nutzt einen `Timer.periodic`, der wartende Posts nach
Ablauf in den Feed schiebt. Der Filterblasen-Mix wertet aus, welche Stance der
aktuelle User pro Thema dominiert vertritt, und sortiert Gegenpositionen nach
vorn.

### Lizenz

Privates Schulprojekt, keine Lizenz vergeben.

---

## English

<p align="center">
  <a href="https://rehajel15.github.io/reasoned/">
    <img src="https://img.shields.io/badge/%E2%96%B6%20Open%20live%20demo-6750A4?style=for-the-badge&logo=googlechrome&logoColor=white" alt="Open live demo">
  </a>
</p>

> ▶ **Live demo:** https://rehajel15.github.io/reasoned/ – a simplified web
> version of the Flutter app that lets you try all five rules end-to-end
> (onboarding, rules screen, feed, mandatory steelman, 15-second cooldown
> in demo mode). Runs entirely in the browser, no install required.

A Flutter app that enforces political debates the way they should actually
go: real names, steelmanning, cooldowns, popped filter bubbles, and written
justifications instead of likes.

Reasoned is a local prototype built for the German school assignment
"Mangelnde Debattenkultur? – Lösungen reflektieren" (textbook page 228,
exercise 2). The app implements five rules for constructive debate
directly in the UI.

**Language note:** The entire app UI is in German and is not translated.
Only this README is also available in English – the app itself remains
German.

### The five rules

| # | Rule | Where it applies |
|---|------|------------------|
| 1 | **Show yourself** – real names required, no anonymous posting | Onboarding with first + last name and a simulated verification step |
| 2 | **Respect your opponents** – steelman before criticism | When replying with "disagree", the reply field is locked until the opposing position (≥ 80 characters) has been summarised charitably |
| 3 | **Stay calm** – 15-minute cooldown for emotional posts | Detects loaded words, all-caps shouting and multiple exclamation marks, then holds the post in a queue |
| 4 | **Burst your bubble** – opposing views in the feed | The feed mixes posts so opposing positions appear first and alternate with the user's own side |
| 5 | **Reason instead of rate** – no likes or dislikes | Replies need at least 120 characters of justification; shorter posts are still shown, but they don't count |

On first launch a dedicated rules screen presents all five rules. Only after
they are explicitly accepted does the user reach the feed. The screen is
reachable again at any time from settings.

### Features

- **Profile picture (optional):** During onboarding a photo can be selected
  or captured (`image_picker`). If none is uploaded, the user gets a
  coloured circle with the first letter of their first name. Demo users
  ship with bundled DiceBear avatars.
- **Real name + city + verification:** No anonymous accounts; verification
  is simulated in the prototype.
- **Topic colour system:** Speed limit (orange), unemployment benefits
  ("Bürgergeld", green), climate vs. economy (teal), voting age 16
  (purple). Each post gets a coloured stripe so the topic is instantly
  recognisable.
- **Stance chips:** Pro / Contra / Question / Neutral with their own
  colours and icons.
- **Steelman block** on every disagreeing reply, visually separated from
  the actual argument.
- **Demo mode** in settings: shortens the cooldown to 15 seconds instead
  of 15 minutes so rule 3 can be tested immediately.
- **Perspective switch:** Four pre-seeded verified demo users can be
  switched in settings, letting you experience the filter-bubble mix from
  several different angles.

### Setup

Requirements:

- Flutter 3.41+ / Dart 3.11+
- Android emulator or a physical Android device with USB debugging
  enabled (iOS, Windows and Web should work as well, but are untested)

Install and run:

```bash
flutter pub get
flutter run
```

Regenerate the app icons (only needed when `assets/icon/icon.png` changes):

```bash
python tool/make_icon.py
dart run flutter_launcher_icons
```

### Project structure

```
lib/
  main.dart                       # App entry, theme, routing conditional
  app_state.dart                  # ChangeNotifier with seed data,
                                  # cooldown timer, filter-bubble mix
  models.dart                     # AppUser, Post, Reply, Topic, Stance
  emotion_detector.dart           # Detects loaded posts
  screens/
    onboarding_screen.dart        # Real name + verification + optional avatar
    rules_screen.dart             # Mandatory rules page with accept button
    feed_screen.dart              # Mixes opposing views in
    post_detail_screen.dart       # Post + replies
    compose_post_screen.dart      # New post, cooldown trigger
    compose_reply_screen.dart     # Reply with mandatory steelman on disagree
    pending_screen.dart           # Queued posts with countdown
    settings_screen.dart          # Demo mode, perspective switch
  widgets/
    post_card.dart
    reply_card.dart
    stance_chip.dart              # StanceChip + TopicChip
    rule_banner.dart
    user_avatar.dart              # Avatar widget supporting asset and file paths

assets/
  avatars/                        # 4 DiceBear avatars (PNG) for demo users
  icon/                           # Source icon + adaptive foreground layer

tool/
  make_icon.py                    # Generates assets/icon/*.png with Pillow
```

### Architecture

Deliberately minimal: a single `AppState extends ChangeNotifier` holds users,
posts, pending posts and the demo flag. The UI listens via
`ListenableBuilder` – no external state-management packages, no persistence.
That is intentional, because Reasoned is a didactic prototype and the rule
logic is what matters.

The cooldown mechanism uses a `Timer.periodic` that promotes pending posts
into the feed when their wait is over. The filter-bubble mix evaluates which
stance the current user predominantly holds per topic and sorts opposing
posts to the top.

### License

Private school project, no license granted.
