import 'package:flutter/material.dart';

import '../app_state.dart';
import '../models.dart';
import '../widgets/post_card.dart';
import '../widgets/rule_banner.dart';

class ComposeReplyScreen extends StatefulWidget {
  final AppState state;
  final String postId;
  const ComposeReplyScreen({
    super.key,
    required this.state,
    required this.postId,
  });

  @override
  State<ComposeReplyScreen> createState() => _ComposeReplyScreenState();
}

class _ComposeReplyScreenState extends State<ComposeReplyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _steelmanCtrl = TextEditingController();
  final _contentCtrl = TextEditingController();
  Stance _stance = Stance.contra;

  @override
  void initState() {
    super.initState();
    _steelmanCtrl.addListener(() => setState(() {}));
    _contentCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _steelmanCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  bool get _steelmanRequired => _stance == Stance.contra;

  bool get _readyToSubmit {
    final contentLen = _contentCtrl.text.trim().length;
    if (contentLen < Reply.minContentLength) return false;
    if (_steelmanRequired) {
      final s = _steelmanCtrl.text.trim().length;
      if (s < Reply.minSteelmanLength) return false;
    }
    return true;
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    widget.state.addReply(
      widget.postId,
      stance: _stance,
      steelman: _steelmanRequired ? _steelmanCtrl.text.trim() : null,
      content: _contentCtrl.text.trim(),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.state.postById(widget.postId);
    final contentLen = _contentCtrl.text.trim().length;
    final steelmanLen = _steelmanCtrl.text.trim().length;

    return Scaffold(
      appBar: AppBar(title: const Text('Antworten')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (post != null)
                  Card(
                    color: Theme.of(context)
                        .colorScheme
                        .surfaceContainerHighest,
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: PostCard(post: post, state: widget.state),
                    ),
                  ),
                const SizedBox(height: 16),
                Text('Deine Haltung zu diesem Beitrag',
                    style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: 6),
                SegmentedButton<Stance>(
                  segments: const [
                    ButtonSegment(value: Stance.pro, label: Text('Zustimmung')),
                    ButtonSegment(value: Stance.contra, label: Text('Ablehnung')),
                    ButtonSegment(
                        value: Stance.nachfrage, label: Text('Nachfrage')),
                  ],
                  selected: {_stance},
                  onSelectionChanged: (s) =>
                      setState(() => _stance = s.first),
                ),
                const SizedBox(height: 14),
                if (_steelmanRequired) ...[
                  const RuleBanner(
                    icon: Icons.shield_outlined,
                    color: Color(0xFF6A1B9A),
                    title: 'Erst Steelman, dann Kritik',
                    body:
                        'Fasse die Position deines Gegenübers fair zusammen, '
                        'bevor du widersprichst. Erst dann wird das '
                        'Antwortfeld freigeschaltet.',
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _steelmanCtrl,
                    maxLines: 4,
                    decoration: InputDecoration(
                      labelText:
                          'Steelman: stärkste Form der Gegenposition (mind. ${Reply.minSteelmanLength} Zeichen)',
                      border: const OutlineInputBorder(),
                      counterText: '$steelmanLen / ${Reply.minSteelmanLength}+',
                      alignLabelWithHint: true,
                    ),
                    validator: (v) {
                      if (!_steelmanRequired) return null;
                      final t = v?.trim() ?? '';
                      if (t.length < Reply.minSteelmanLength) {
                        return 'Bitte fasse die Gegenposition fair zusammen.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                ],
                AbsorbPointer(
                  absorbing: _steelmanRequired &&
                      _steelmanCtrl.text.trim().length <
                          Reply.minSteelmanLength,
                  child: Opacity(
                    opacity: _steelmanRequired &&
                            _steelmanCtrl.text.trim().length <
                                Reply.minSteelmanLength
                        ? 0.45
                        : 1.0,
                    child: TextFormField(
                      controller: _contentCtrl,
                      maxLines: 6,
                      decoration: InputDecoration(
                        labelText:
                            'Deine Begründung (mind. ${Reply.minContentLength} Zeichen)',
                        border: const OutlineInputBorder(),
                        counterText:
                            '$contentLen / ${Reply.minContentLength}+',
                        alignLabelWithHint: true,
                      ),
                      validator: (v) {
                        final t = v?.trim() ?? '';
                        if (t.length < Reply.minContentLength) {
                          return 'Mindestens ${Reply.minContentLength} Zeichen, '
                              'damit deine Antwort zählt.';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const RuleBanner(
                  icon: Icons.balance_outlined,
                  color: Color(0xFF2E7D32),
                  title: 'Begründete Antwort statt Daumen',
                  body:
                      'Es gibt keine Likes oder Dislikes. Wer die Mindestlänge '
                      'unterläuft, wird angezeigt – aber nicht gezählt.',
                ),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: _readyToSubmit ? _submit : null,
                  icon: const Icon(Icons.send_outlined),
                  label: const Text('Antwort senden'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
