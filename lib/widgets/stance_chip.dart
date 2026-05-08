import 'package:flutter/material.dart';

import '../models.dart';

class StanceChip extends StatelessWidget {
  final Stance stance;
  final bool dense;
  const StanceChip({super.key, required this.stance, this.dense = false});

  @override
  Widget build(BuildContext context) {
    final color = stance.color;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: dense ? 8 : 10,
        vertical: dense ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(stance.icon, size: dense ? 12 : 14, color: color),
          const SizedBox(width: 4),
          Text(
            stance.label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: dense ? 11 : 12,
            ),
          ),
        ],
      ),
    );
  }
}

class TopicChip extends StatelessWidget {
  final Topic topic;
  const TopicChip({super.key, required this.topic});

  @override
  Widget build(BuildContext context) {
    final color = topic.color;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(topic.icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(
            topic.label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
