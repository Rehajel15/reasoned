import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';

import 'models.dart';

class AppState extends ChangeNotifier {
  static const Duration _realCooldown = Duration(minutes: 15);
  static const Duration _demoCooldown = Duration(seconds: 15);

  final Map<String, AppUser> _users = {};
  final List<Post> _posts = [];
  final List<PendingPost> _pending = [];

  String? _currentUserId;
  bool _demoMode = true;
  Timer? _ticker;
  int _idCounter = 0;

  AppState() {
    _seed();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  // ---------- Public state ----------

  bool get demoMode => _demoMode;
  Duration get cooldownDuration => _demoMode ? _demoCooldown : _realCooldown;
  Iterable<AppUser> get users => _users.values;
  AppUser? get currentUser =>
      _currentUserId == null ? null : _users[_currentUserId!];
  List<PendingPost> get pendingForCurrentUser => _pending
      .where((p) => p.authorId == _currentUserId)
      .toList(growable: false);

  AppUser? userById(String id) => _users[id];

  void setDemoMode(bool value) {
    _demoMode = value;
    notifyListeners();
  }

  // ---------- Onboarding ----------

  String createUser({
    required String klarname,
    required String stadt,
    int? alter,
    String? avatarPath,
  }) {
    final id = _newId('u');
    _users[id] = AppUser(
      id: id,
      klarname: klarname,
      verified: false,
      rulesAccepted: false,
      stadt: stadt,
      alter: alter,
      avatarPath: avatarPath,
    );
    _currentUserId = id;
    notifyListeners();
    return id;
  }

  void acceptRules() {
    final u = currentUser;
    if (u == null) return;
    _users[u.id] = u.copyWith(rulesAccepted: true);
    notifyListeners();
  }

  void setCurrentUserAvatar(String path) {
    final u = currentUser;
    if (u == null) return;
    _users[u.id] = u.copyWith(avatarPath: path);
    notifyListeners();
  }

  void switchUser(String id) {
    if (_users.containsKey(id)) {
      _currentUserId = id;
      notifyListeners();
    }
  }

  Future<void> simulateVerification() async {
    final u = currentUser;
    if (u == null) return;
    await Future.delayed(const Duration(seconds: 2));
    _users[u.id] = u.copyWith(verified: true);
    notifyListeners();
  }

  // ---------- Posts ----------

  /// Returns null if published immediately, otherwise the queued PendingPost.
  PendingPost? submitPost({
    required Topic topic,
    required Stance stance,
    required String content,
    required bool requiresCooldown,
    required String triggerReason,
  }) {
    final user = currentUser;
    if (user == null || !user.verified) {
      throw StateError('Nur verifizierte Nutzer dürfen posten.');
    }
    final now = DateTime.now();
    final id = _newId('p');
    if (requiresCooldown) {
      final pending = PendingPost(
        id: id,
        authorId: user.id,
        topic: topic,
        stance: stance,
        content: content,
        queuedAt: now,
        publishAt: now.add(cooldownDuration),
        triggerReason: triggerReason,
      );
      _pending.add(pending);
      notifyListeners();
      return pending;
    }
    _posts.insert(
      0,
      Post(
        id: id,
        authorId: user.id,
        topic: topic,
        stance: stance,
        content: content,
        publishedAt: now,
        replies: const [],
      ),
    );
    notifyListeners();
    return null;
  }

  void cancelPending(String id) {
    _pending.removeWhere((p) => p.id == id);
    notifyListeners();
  }

  void addReply(
    String postId, {
    required Stance stance,
    required String? steelman,
    required String content,
  }) {
    final user = currentUser;
    if (user == null || !user.verified) {
      throw StateError('Nur verifizierte Nutzer dürfen antworten.');
    }
    final idx = _posts.indexWhere((p) => p.id == postId);
    if (idx == -1) return;
    final reply = Reply(
      id: _newId('r'),
      authorId: user.id,
      stance: stance,
      steelman: steelman,
      content: content,
      publishedAt: DateTime.now(),
    );
    _posts[idx] = _posts[idx].withReply(reply);
    notifyListeners();
  }

  Post? postById(String id) {
    for (final p in _posts) {
      if (p.id == id) return p;
    }
    return null;
  }

  // ---------- Feed ----------

  /// Mixes posts so opposing stances appear early & alternate, breaking
  /// the user's filter bubble.
  List<Post> feedForCurrentUser() {
    final user = currentUser;
    if (user == null) return List.unmodifiable(_posts);

    final ownStances = <Topic, Map<Stance, int>>{};
    for (final p in _posts.where((p) => p.authorId == user.id)) {
      final m = ownStances.putIfAbsent(p.topic, () => <Stance, int>{});
      m[p.stance] = (m[p.stance] ?? 0) + 1;
    }

    final sameSide = <Post>[];
    final otherSide = <Post>[];
    final neutralOrUnknown = <Post>[];

    for (final p in _posts) {
      final stances = ownStances[p.topic];
      if (stances == null || stances.isEmpty) {
        neutralOrUnknown.add(p);
        continue;
      }
      final dominant = stances.entries
          .reduce((a, b) => a.value >= b.value ? a : b)
          .key;
      final opposite = _opposite(dominant);
      if (p.stance == dominant) {
        sameSide.add(p);
      } else if (p.stance == opposite) {
        otherSide.add(p);
      } else {
        neutralOrUnknown.add(p);
      }
    }

    sameSide.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
    otherSide.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
    neutralOrUnknown.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));

    final result = <Post>[];
    var i = 0, j = 0, k = 0;
    while (i < sameSide.length || j < otherSide.length || k < neutralOrUnknown.length) {
      if (j < otherSide.length) result.add(otherSide[j++]);
      if (i < sameSide.length) result.add(sameSide[i++]);
      if (k < neutralOrUnknown.length) result.add(neutralOrUnknown[k++]);
    }
    return result;
  }

  Stance _opposite(Stance s) {
    switch (s) {
      case Stance.pro:
        return Stance.contra;
      case Stance.contra:
        return Stance.pro;
      default:
        return Stance.neutral;
    }
  }

  // ---------- Internals ----------

  void _tick() {
    final now = DateTime.now();
    final ready = _pending.where((p) => !p.publishAt.isAfter(now)).toList();
    if (ready.isEmpty) return;
    for (final p in ready) {
      _pending.remove(p);
      _posts.insert(0, p.toPublished());
    }
    notifyListeners();
  }

  String _newId(String prefix) {
    _idCounter += 1;
    return '$prefix${_idCounter.toString().padLeft(4, '0')}';
  }

  void _seed() {
    final anna = AppUser(
      id: 'u-anna',
      klarname: 'Anna Müller',
      verified: true,
      rulesAccepted: true,
      stadt: 'Hamburg',
      alter: 32,
      avatarPath: 'assets/avatars/anna.png',
    );
    final bernd = AppUser(
      id: 'u-bernd',
      klarname: 'Bernd Schäfer',
      verified: true,
      rulesAccepted: true,
      stadt: 'München',
      alter: 47,
      avatarPath: 'assets/avatars/bernd.png',
    );
    final clara = AppUser(
      id: 'u-clara',
      klarname: 'Clara Otieno',
      verified: true,
      rulesAccepted: true,
      stadt: 'Leipzig',
      alter: 28,
      avatarPath: 'assets/avatars/clara.png',
    );
    final david = AppUser(
      id: 'u-david',
      klarname: 'David Petrov',
      verified: true,
      rulesAccepted: true,
      stadt: 'Köln',
      alter: 39,
      avatarPath: 'assets/avatars/david.png',
    );
    _users[anna.id] = anna;
    _users[bernd.id] = bernd;
    _users[clara.id] = clara;
    _users[david.id] = david;

    final base = DateTime.now().subtract(const Duration(hours: 6));
    Duration t(int h) => Duration(hours: h);

    _posts.addAll([
      Post(
        id: _newId('p'),
        authorId: anna.id,
        topic: Topic.tempolimit,
        stance: Stance.pro,
        content:
            'Ein generelles Tempolimit von 130 km/h würde nachweislich CO₂ einsparen, '
            'die Unfallzahlen senken und den Verkehrsfluss verstetigen. Die meisten EU-Länder '
            'leben seit Jahrzehnten gut damit – warum sollte das ausgerechnet hier nicht funktionieren?',
        publishedAt: base.add(t(0)),
        replies: const [],
      ),
      Post(
        id: _newId('p'),
        authorId: bernd.id,
        topic: Topic.tempolimit,
        stance: Stance.contra,
        content:
            'Ein pauschales Tempolimit löst das Klimaproblem nicht. Die eingesparten Emissionen '
            'sind im Gesamtbild marginal. Statt Symbolpolitik sollten wir lieber in Schienen, '
            'Brückensanierung und E-Fuels investieren – das wirkt strukturell.',
        publishedAt: base.add(t(1)),
        replies: const [],
      ),
      Post(
        id: _newId('p'),
        authorId: clara.id,
        topic: Topic.buergergeld,
        stance: Stance.pro,
        content:
            'Das Bürgergeld ist sozialstaatlich konsequent: Es ersetzt erniedrigende Sanktionen '
            'durch Zumutbarkeitsregeln und gibt Menschen Spielraum, sich umzuorientieren. Wer '
            'Armut bekämpfen will, muss vor allem Vertrauen finanzieren.',
        publishedAt: base.add(t(2)),
        replies: const [],
      ),
      Post(
        id: _newId('p'),
        authorId: david.id,
        topic: Topic.buergergeld,
        stance: Stance.contra,
        content:
            'Wenn Arbeit kaum mehr als Bürgergeld bringt, gerät das Lohnabstandsgebot in Schieflage. '
            'Eine Reform muss Erwerbstätigkeit klar attraktiver machen, sonst verlieren wir die '
            'Akzeptanz des Sozialstaats in der Mittelschicht.',
        publishedAt: base.add(t(3)),
        replies: const [],
      ),
      Post(
        id: _newId('p'),
        authorId: clara.id,
        topic: Topic.klimaWirtschaft,
        stance: Stance.nachfrage,
        content:
            'Mich interessiert: Welche konkreten Branchen seht ihr als unrettbar an, wenn der '
            'CO₂-Preis weiter steigt – und welche profitieren? Quellen gerne mit dazu.',
        publishedAt: base.add(t(4)),
        replies: const [],
      ),
      Post(
        id: _newId('p'),
        authorId: anna.id,
        topic: Topic.wahlrechtAb16,
        stance: Stance.pro,
        content:
            'Wenn 16-Jährige Verträge mitunterschreiben und Steuern zahlen, dürfen sie auch wählen. '
            'Studien aus Österreich zeigen keine schlechteren Wahlentscheidungen, sondern eine '
            'höhere langfristige Wahlbeteiligung.',
        publishedAt: base.add(t(5)),
        replies: const [],
      ),
      Post(
        id: _newId('p'),
        authorId: bernd.id,
        topic: Topic.wahlrechtAb16,
        stance: Stance.contra,
        content:
            'Wahlrecht heißt Reife für komplexe Trade-offs. Bevor wir das Wahlalter senken, sollten '
            'wir politische Bildung in Schulen wirklich stärken – sonst geben wir eine Stimme ab, '
            'ohne den Boden dafür bereitet zu haben.',
        publishedAt: base.add(t(5) + const Duration(minutes: 30)),
        replies: const [],
      ),
    ]);

    // a couple of seeded replies showcasing the rule
    final firstPost = _posts.last; // wahlrecht contra (older)
    _posts[_posts.indexOf(firstPost)] = firstPost.withReply(
      Reply(
        id: _newId('r'),
        authorId: clara.id,
        stance: Stance.contra,
        steelman:
            'Du argumentierst, dass politische Reife entscheidend für ein verantwortungsvolles '
            'Wahlrecht ist und dass die Schule diese Reife bisher nicht zuverlässig vermittelt.',
        content:
            'Ich teile die Sorge um politische Bildung, aber Wahlrecht und Bildungsreform schließen '
            'sich nicht aus. Wer Bildung an das Wahlrecht koppelt, verschiebt es faktisch auf '
            'Sankt-Nimmerleinstag – und benachteiligt junge Menschen, deren Schulen am wenigsten '
            'Ressourcen haben.',
        publishedAt: base.add(t(6)),
      ),
    );

    _currentUserId = null; // start without user, force onboarding
    // make seed deterministic-ish
    Random(42);
  }
}
