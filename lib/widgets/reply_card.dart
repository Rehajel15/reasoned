import 'package:flutter/material.dart';

import '../app_state.dart';
import '../models.dart';
import 'stance_chip.dart';
import 'user_avatar.dart';

class ReplyCard extends StatelessWidget {
  final Reply reply;
  final AppState state;
  const ReplyCard({super.key, required this.reply, required this.state});

  @override
  Widget build(BuildContext context) {
    final author = state.userById(reply.authorId);
    final scheme = Theme.of(context).colorScheme;
    final counts = reply.counts;

    final stanceColor = reply.stance.color;
    final outlineColor = counts
        ? scheme.outlineVariant
        : scheme.error.withValues(alpha: 0.4);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border.all(color: outlineColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
          Row(
            children: [
              UserAvatar(
                user: author,
                radius: 16,
                fallbackColor: stanceColor,
                initialStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        author?.klarname ?? 'Unbekannt',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (author?.verified ?? false) ...[
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.verified,
                        size: 13,
                        color: Color(0xFF1976D2),
                      ),
                    ],
                  ],
                ),
              ),
              StanceChip(stance: reply.stance, dense: true),
            ],
          ),
          if (reply.steelman != null && reply.steelman!.trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: scheme.secondaryContainer.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(13, 10, 10, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.shield_outlined, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              'Steelman der Gegenposition',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: scheme.onSecondaryContainer,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          reply.steelman!,
                          style: const TextStyle(
                            fontStyle: FontStyle.italic,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    width: 3,
                    child: ColoredBox(color: scheme.secondary),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 8),
          Text(reply.content),
          if (!counts) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.info_outline, size: 14, color: scheme.error),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    'Zählt nicht – die Begründung erfüllt die Mindestanforderungen nicht.',
                    style: TextStyle(color: scheme.error, fontSize: 12),
                  ),
                ),
              ],
            ),
          ],
        ],
            ),
          ),
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            width: 4,
            child: ColoredBox(color: stanceColor),
          ),
        ],
      ),
    );
  }
}
