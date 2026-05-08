import 'package:flutter/material.dart';

import '../app_state.dart';
import '../emotion_detector.dart';
import '../models.dart';
import '../widgets/rule_banner.dart';
import 'pending_screen.dart';

class ComposePostScreen extends StatefulWidget {
  final AppState state;
  const ComposePostScreen({super.key, required this.state});

  @override
  State<ComposePostScreen> createState() => _ComposePostScreenState();
}

class _ComposePostScreenState extends State<ComposePostScreen> {
  final _formKey = GlobalKey<FormState>();
  final _contentCtrl = TextEditingController();
  Topic _topic = Topic.tempolimit;
  Stance _stance = Stance.pro;
  EmotionCheck _emotion = const EmotionCheck(false, '');

  @override
  void initState() {
    super.initState();
    _contentCtrl.addListener(() {
      final c = EmotionDetector.check(_contentCtrl.text);
      if (c.isEmotional != _emotion.isEmotional || c.reason != _emotion.reason) {
        setState(() => _emotion = c);
      }
    });
  }

  @override
  void dispose() {
    _contentCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final pending = widget.state.submitPost(
      topic: _topic,
      stance: _stance,
      content: _contentCtrl.text.trim(),
      requiresCooldown: _emotion.isEmotional,
      triggerReason: _emotion.reason,
    );
    if (!mounted) return;
    Navigator.of(context).pop();
    if (pending != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Dein Beitrag wartet ${_formatDuration(widget.state.cooldownDuration)} '
            'in der Abkühlzeit.',
          ),
          action: SnackBarAction(
            label: 'Anzeigen',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => PendingScreen(state: widget.state),
                ),
              );
            },
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Beitrag veröffentlicht.')),
      );
    }
  }

  String _formatDuration(Duration d) {
    if (d.inMinutes >= 1) return '${d.inMinutes} Min.';
    return '${d.inSeconds} Sek.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Neuer Beitrag')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Thema',
                    style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: 6),
                DropdownButtonFormField<Topic>(
                  initialValue: _topic,
                  items: Topic.values
                      .map((t) =>
                          DropdownMenuItem(value: t, child: Text(t.label)))
                      .toList(),
                  onChanged: (v) => setState(() => _topic = v ?? _topic),
                  decoration: const InputDecoration(border: OutlineInputBorder()),
                ),
                const SizedBox(height: 14),
                Text('Deine Position',
                    style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: 6),
                SegmentedButton<Stance>(
                  segments: const [
                    ButtonSegment(value: Stance.pro, label: Text('Pro')),
                    ButtonSegment(value: Stance.contra, label: Text('Contra')),
                    ButtonSegment(
                        value: Stance.nachfrage, label: Text('Nachfrage')),
                    ButtonSegment(
                        value: Stance.neutral, label: Text('Neutral')),
                  ],
                  selected: {_stance},
                  onSelectionChanged: (s) =>
                      setState(() => _stance = s.first),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _contentCtrl,
                  maxLines: 6,
                  decoration: const InputDecoration(
                    labelText: 'Dein Beitrag',
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                  validator: (v) {
                    final t = v?.trim() ?? '';
                    if (t.length < 60) {
                      return 'Mindestens 60 Zeichen, damit dein Punkt klar wird.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                if (_emotion.isEmotional)
                  RuleBanner(
                    icon: Icons.timer_outlined,
                    color: const Color(0xFFE65100),
                    title: 'Abkühlzeit aktiviert',
                    body:
                        '${_emotion.reason} Dein Beitrag wird '
                        '${_formatDuration(widget.state.cooldownDuration)} '
                        'zurückgehalten. Du kannst ihn währenddessen zurückziehen.',
                  )
                else
                  RuleBanner(
                    icon: Icons.spa_outlined,
                    color: const Color(0xFF2E7D32),
                    title: 'Sachlich formuliert',
                    body:
                        'Aktuell erkennen wir keine aufgeladenen Marker. '
                        'Dein Beitrag wird sofort veröffentlicht.',
                  ),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: _submit,
                  icon: const Icon(Icons.send_outlined),
                  label: const Text('Veröffentlichen'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
