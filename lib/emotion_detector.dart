class EmotionCheck {
  final bool isEmotional;
  final String reason;
  const EmotionCheck(this.isEmotional, this.reason);
}

class EmotionDetector {
  static const List<String> _chargedWords = [
    'idiot',
    'idioten',
    'dumm',
    'dumme',
    'dummkopf',
    'lüge',
    'lügen',
    'lügner',
    'verrückt',
    'wahnsinn',
    'unverschämt',
    'frechheit',
    'skandal',
    'hass',
    'hassen',
    'verachte',
    'widerlich',
    'ekelhaft',
    'asozial',
    'spinner',
    'arschloch',
    'volksverräter',
    'zerstören',
    'vernichten',
    'feind',
    'feinde',
  ];

  static EmotionCheck check(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return const EmotionCheck(false, '');

    final exclamations = '!'.allMatches(trimmed).length;
    if (exclamations >= 3) {
      return EmotionCheck(true, 'Mehrere Ausrufezeichen ($exclamations) deuten auf Affekt hin.');
    }

    final letters = trimmed.replaceAll(RegExp(r'[^A-Za-zÄÖÜäöüß]'), '');
    if (letters.length >= 12) {
      final upper = letters.replaceAll(RegExp(r'[a-zäöüß]'), '');
      final ratio = upper.length / letters.length;
      if (ratio > 0.6) {
        return const EmotionCheck(
          true,
          'Überwiegend Großbuchstaben wirken wie Geschrei.',
        );
      }
    }

    final lower = trimmed.toLowerCase();
    for (final w in _chargedWords) {
      final pattern = RegExp(r'\b' + RegExp.escape(w) + r'\b');
      if (pattern.hasMatch(lower)) {
        return EmotionCheck(true, 'Aufgeladenes Wort erkannt: „$w".');
      }
    }

    return const EmotionCheck(false, '');
  }
}
