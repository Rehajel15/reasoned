import 'package:flutter/material.dart';

import '../app_state.dart';

class _Rule {
  final IconData icon;
  final Color color;
  final String title;
  final String body;
  const _Rule({
    required this.icon,
    required this.color,
    required this.title,
    required this.body,
  });
}

class RulesScreen extends StatefulWidget {
  final AppState state;
  final bool isReview;
  const RulesScreen({super.key, required this.state, this.isReview = false});

  @override
  State<RulesScreen> createState() => _RulesScreenState();
}

class _RulesScreenState extends State<RulesScreen> {
  bool _accepted = false;

  static const List<_Rule> _rules = [
    _Rule(
      icon: Icons.badge_outlined,
      color: Color(0xFF1565C0),
      title: 'Zeige dich',
      body:
          'Niemand postet anonym. Klarname und verifiziertes Profil sind '
          'Pflicht. So übernimmst du Verantwortung für das, was du sagst – '
          'und Hassrede verliert ihren Schutzraum.',
    ),
    _Rule(
      icon: Icons.shield_moon_outlined,
      color: Color(0xFF6A1B9A),
      title: 'Schätze deine Gegner',
      body:
          'Bevor du widersprichst, fasst du die Gegenposition fair zusammen '
          '(Steelman). Erst dann wird dein Antwortfeld freigeschaltet. Wer '
          'das andere Argument verstanden hat, kritisiert besser.',
    ),
    _Rule(
      icon: Icons.timer_outlined,
      color: Color(0xFFE65100),
      title: 'Bewahre Ruhe',
      body:
          'Aufgeladene Beiträge werden 15 Minuten zurückgehalten, bevor sie '
          'erscheinen. In der Wartezeit darfst du dich umentscheiden – '
          'Affekt-Antworten kommen so gar nicht erst online.',
    ),
    _Rule(
      icon: Icons.bubble_chart_outlined,
      color: Color(0xFF00838F),
      title: 'Platzt deine Blase',
      body:
          'Dein Feed mischt bewusst Gegenpositionen ein. Du siehst andere '
          'Sichtweisen statt nur eine Echokammer – das ist anstrengend, aber '
          'der Sinn der Sache.',
    ),
    _Rule(
      icon: Icons.balance_outlined,
      color: Color(0xFF2E7D32),
      title: 'Begründe statt bewerte',
      body:
          'Es gibt keine Like- oder Dislike-Buttons. Zustimmung und Ablehnung '
          'müssen geschrieben werden – mit Mindestlänge. Wer nichts begründet, '
          'zählt nicht mit.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final user = widget.state.currentUser;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            pinned: true,
            backgroundColor: scheme.primaryContainer,
            foregroundColor: scheme.onPrimaryContainer,
            automaticallyImplyLeading: widget.isReview,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsetsDirectional.fromSTEB(20, 0, 20, 16),
              title: Text(
                'Spielregeln für gute Debatten',
                style: TextStyle(
                  color: scheme.onPrimaryContainer,
                  fontWeight: FontWeight.w800,
                ),
              ),
              background: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      scheme.primaryContainer,
                      scheme.tertiaryContainer,
                    ],
                  ),
                ),
                child: Align(
                  alignment: const Alignment(0.9, -0.4),
                  child: Icon(
                    Icons.forum_rounded,
                    size: 140,
                    color: scheme.onPrimaryContainer.withValues(alpha: 0.18),
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, widget.isReview ? 24 : 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                if (user != null && !widget.isReview)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      'Hallo ${user.klarname.split(" ").first}, bevor du loslegst:',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                Text(
                  widget.isReview
                      ? 'Diese fünf Regeln gelten für alle Beiträge auf Reasoned.'
                      : 'Reasoned funktioniert nur, wenn alle dieselben fünf Regeln '
                          'einhalten. Bitte lies sie in Ruhe durch.',
                  style: TextStyle(color: scheme.onSurfaceVariant),
                ),
                const SizedBox(height: 16),
                for (var i = 0; i < _rules.length; i++) ...[
                  _RuleTile(index: i + 1, rule: _rules[i]),
                  const SizedBox(height: 10),
                ],
                if (!widget.isReview) ...[
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: scheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(8),
                    child: CheckboxListTile(
                      value: _accepted,
                      onChanged: (v) => setState(() => _accepted = v ?? false),
                      title: const Text(
                        'Ich habe die Regeln gelesen und halte mich daran.',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                  ),
                ],
              ]),
            ),
          ),
        ],
      ),
      bottomNavigationBar: widget.isReview
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: FilledButton.icon(
                  onPressed:
                      _accepted ? () => widget.state.acceptRules() : null,
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 6),
                    child: Text('Akzeptieren und in den Feed'),
                  ),
                ),
              ),
            ),
    );
  }
}

class _RuleTile extends StatelessWidget {
  final int index;
  final _Rule rule;
  const _RuleTile({required this.index, required this.rule});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: rule.color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: rule.color.withValues(alpha: 0.25)),
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: rule.color,
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Icon(rule.icon, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$index. ${rule.title}',
                  style: TextStyle(
                    color: rule.color,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(rule.body),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
