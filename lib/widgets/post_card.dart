import 'package:flutter/material.dart';

import '../app_state.dart';
import '../models.dart';
import 'stance_chip.dart';
import 'user_avatar.dart';

class PostCard extends StatelessWidget {
  final Post post;
  final AppState state;
  final VoidCallback? onTap;
  const PostCard({
    super.key,
    required this.post,
    required this.state,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final author = state.userById(post.authorId);
    final countingReplies = post.replies.where((r) => r.counts).length;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(color: post.topic.color, width: 5),
            ),
          ),
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  UserAvatar(
                    user: author,
                    radius: 20,
                    fallbackColor: post.topic.color,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                author?.klarname ?? 'Unbekannt',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (author?.verified ?? false) ...[
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.verified,
                                size: 16,
                                color: Color(0xFF1976D2),
                              ),
                            ],
                          ],
                        ),
                        Text(
                          author?.stadt ?? '',
                          style: TextStyle(
                            color: Theme.of(context).hintColor,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    _relativeTime(post.publishedAt),
                    style: TextStyle(
                      color: Theme.of(context).hintColor,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  TopicChip(topic: post.topic),
                  StanceChip(stance: post.stance),
                ],
              ),
              const SizedBox(height: 10),
              Text(post.content),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.forum_outlined,
                    size: 16,
                    color: Theme.of(context).hintColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '$countingReplies begründete Antworten',
                    style: TextStyle(
                      color: Theme.of(context).hintColor,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _relativeTime(DateTime t) {
    final d = DateTime.now().difference(t);
    if (d.inMinutes < 1) return 'gerade';
    if (d.inMinutes < 60) return '${d.inMinutes} Min.';
    if (d.inHours < 24) return '${d.inHours} Std.';
    return '${d.inDays} T.';
  }
}
