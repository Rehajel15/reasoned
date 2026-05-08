import 'package:flutter/material.dart';

import '../app_state.dart';
import '../widgets/post_card.dart';
import '../widgets/reply_card.dart';
import 'compose_reply_screen.dart';

class PostDetailScreen extends StatelessWidget {
  final AppState state;
  final String postId;
  const PostDetailScreen({
    super.key,
    required this.state,
    required this.postId,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: state,
      builder: (context, _) {
        final post = state.postById(postId);
        if (post == null) {
          return const Scaffold(
            body: Center(child: Text('Beitrag nicht gefunden.')),
          );
        }
        final counting = post.replies.where((r) => r.counts).length;
        final notCounting = post.replies.length - counting;

        return Scaffold(
          appBar: AppBar(title: const Text('Beitrag')),
          body: ListView(
            padding: const EdgeInsets.symmetric(vertical: 8),
            children: [
              PostCard(post: post, state: state),
              const Divider(),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                child: Row(
                  children: [
                    Text(
                      'Antworten ($counting begründet'
                      '${notCounting > 0 ? ", $notCounting zählen nicht" : ""})',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
              if (post.replies.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(
                    child: Text(
                      'Noch keine Antworten. Sei die erste Person, die '
                      'sachlich antwortet.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              else
                ...post.replies.map((r) => ReplyCard(reply: r, state: state)),
              const SizedBox(height: 80),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            icon: const Icon(Icons.reply),
            label: const Text('Antworten'),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ComposeReplyScreen(
                    state: state,
                    postId: postId,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
