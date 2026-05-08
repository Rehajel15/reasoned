import 'package:flutter/material.dart';

import '../app_state.dart';
import '../models.dart';
import '../widgets/rule_banner.dart';
import '../widgets/stance_chip.dart';

class PendingScreen extends StatelessWidget {
  final AppState state;
  const PendingScreen({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: state,
      builder: (context, _) {
        final items = state.pendingForCurrentUser;
        return Scaffold(
          appBar: AppBar(title: const Text('Wartende Beiträge')),
          body: ListView(
            padding: const EdgeInsets.symmetric(vertical: 8),
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(12, 8, 12, 4),
                child: RuleBanner(
                  icon: Icons.timer_outlined,
                  color: Color(0xFFE65100),
                  title: 'Abkühlzeit läuft',
                  body:
                      'Diese Beiträge wurden als emotional eingestuft und warten '
                      'auf ihre Veröffentlichung. Du kannst sie jederzeit abbrechen.',
                ),
              ),
              if (items.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(
                    child: Text(
                      'Aktuell wartet kein Beitrag. Wenn du gleich wütend tippst, '
                      'siehst du ihn hier.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              else
                ...items.map((p) => _PendingTile(state: state, post: p)),
            ],
          ),
        );
      },
    );
  }
}

class _PendingTile extends StatefulWidget {
  final AppState state;
  final PendingPost post;
  const _PendingTile({required this.state, required this.post});

  @override
  State<_PendingTile> createState() => _PendingTileState();
}

class _PendingTileState extends State<_PendingTile> {
  @override
  Widget build(BuildContext context) {
    final remaining =
        widget.post.remaining(DateTime.now()).inSeconds.clamp(0, 999999);
    final mins = remaining ~/ 60;
    final secs = remaining % 60;
    final total = widget.post.publishAt
        .difference(widget.post.queuedAt)
        .inSeconds
        .clamp(1, 999999);
    final progress = (1 - remaining / total).clamp(0.0, 1.0);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                TopicChip(topic: widget.post.topic),
                StanceChip(stance: widget.post.stance),
              ],
            ),
            const SizedBox(height: 10),
            Text(widget.post.content),
            const SizedBox(height: 12),
            if (widget.post.triggerReason.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  'Erkannt: ${widget.post.triggerReason}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).hintColor,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.timer, size: 16, color: Theme.of(context).hintColor),
                const SizedBox(width: 4),
                Text(
                  remaining == 0
                      ? 'wird gleich veröffentlicht…'
                      : 'noch ${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}',
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () => widget.state.cancelPending(widget.post.id),
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Verwerfen'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _scheduleTick();
  }

  void _scheduleTick() async {
    while (mounted) {
      await Future<void>.delayed(const Duration(seconds: 1));
      if (!mounted) return;
      setState(() {});
    }
  }
}
