# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Working directory

The user's default cwd is `C:\Dev\Reasoned`, but the actual Flutter project (and git repo) lives at `C:\Dev\Reasoned\reasoned\`. **Almost every command must run from `reasoned/`**, either by `cd`ing in or by using an absolute path. The parent `C:\Dev\Reasoned` only contains IDE/Claude metadata.

## Common commands

Run from `reasoned/`:

| Task | Command |
|------|---------|
| Install deps | `flutter pub get` |
| Static analysis | `flutter analyze` |
| Run all tests | `flutter test` |
| Run one test file | `flutter test test/widget_test.dart` |
| Run on default device | `flutter run` (target is Android) |
| List devices | `flutter devices` |
| Regenerate launcher icons | `python tool/make_icon.py && dart run flutter_launcher_icons` |

Tests must use `tester.pump(Duration(...))`, **never** `pumpAndSettle()` — `AppState` runs a `Timer.periodic` every second that the binding will wait on forever.

## Architecture

This is a Flutter prototype for a German-only debate app that enforces five rules on user behaviour. Two parallel implementations live in this repo and must stay in sync:

- **`lib/`** — the actual Flutter app (Dart, primary product).
- **`docs/index.html`** — a vanilla-JS single-file recreation hosted via GitHub Pages at <https://rehajel15.github.io/reasoned/>. It mirrors the Flutter app's screens 1:1 and reuses the same data shapes, algorithm names, and seed content. When changing rule logic, consider whether the web demo needs the same change.

### State management (Flutter)

- Single `AppState extends ChangeNotifier` in `lib/app_state.dart` holds all users, posts, pending posts, current user ID, and `demoMode`. No Provider, Riverpod, BLoC, or persistence — everything is in-memory and resets on restart.
- UI rebuilds via `ListenableBuilder(listenable: state, ...)`. After mutating, call `notifyListeners()` explicitly.
- A `Timer.periodic` in `AppState` promotes posts out of `_pending` into `_posts` when their cooldown expires.

### Routing

`main.dart` does **not** use a router. The `home:` is a `ListenableBuilder` that picks one of three screens based on `currentUser` state:

1. `null` or `!verified` → `OnboardingScreen`
2. verified but `!rulesAccepted` → `RulesScreen`
3. else → `FeedScreen`

Inner navigation is plain `Navigator.push(MaterialPageRoute(...))`.

### The five rules (where they're enforced)

| # | Rule | File |
|---|------|------|
| 1 | Klarname + Verifizierung | `screens/onboarding_screen.dart`, gating in `app_state.dart`'s `submitPost`/`addReply` |
| 2 | Steelman vor Kritik | `screens/compose_reply_screen.dart` — `_steelmanRequired` + `AbsorbPointer` over the content field |
| 3 | 15-Min Abkühlzeit | `emotion_detector.dart` triggers, `AppState.submitPost` queues, `Timer.periodic` releases |
| 4 | Filterblasen-Mix | `AppState.feedForCurrentUser()` interleaves opposing/own/neutral stances per topic |
| 5 | Begründete Antworten | `Reply.counts` getter (`models.dart`) — replies under `minContentLength` are rendered but excluded from the counter |

`demoMode` (toggle in Settings) shortens Rule 3's cooldown from 15 minutes to 15 seconds for testing.

### Color system

Topic and stance colors are defined as Dart `extension` getters in `lib/models.dart` (`TopicX.color`, `StanceX.color`). The same colors are duplicated as CSS variables in `docs/index.html`. **Keep both in sync** when adjusting palette.

### Avatars

`lib/widgets/user_avatar.dart` accepts `AppUser.avatarPath` which can be either an asset (path starts with `assets/`) or a filesystem path (from `image_picker`); falls back to the user's first-letter initial in a colored circle if no path. Profile picture is **optional** at onboarding — users without one always show the initial. Demo users ship with bundled DiceBear PNGs in `assets/avatars/`.

### App icon pipeline

1. Edit `tool/make_icon.py` (Pillow) — generates `assets/icon/icon.png` (full square) + `assets/icon/icon_foreground.png` (Android adaptive layer).
2. Run `dart run flutter_launcher_icons` to propagate to all Android mipmap densities and iOS AppIcon.appiconset. Config lives under `flutter_launcher_icons:` in `pubspec.yaml`.

## README and language

- App UI is **German only** — all labels, errors, banners, snackbars stay German. Do not add i18n unless asked.
- `README.md` is bilingual (German first, English second). Keep both sections in sync when documenting changes.
- The Live-Demo badge at the top of the README points at GitHub Pages; do not break that link.

## GitHub Pages

`docs/` on `main` auto-deploys to <https://rehajel15.github.io/reasoned/>. Pushing to `main` is the deploy step — no separate workflow.
