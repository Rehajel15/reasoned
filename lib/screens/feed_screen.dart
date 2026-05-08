import 'package:flutter/material.dart';

import '../app_state.dart';
import '../widgets/post_card.dart';
import 'compose_post_screen.dart';
import 'pending_screen.dart';
import 'post_detail_screen.dart';
import 'settings_screen.dart';

class FeedScreen extends StatelessWidget {
  final AppState state;
  const FeedScreen({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: state,
      builder: (context, _) {
        final posts = state.feedForCurrentUser();
        final pendingCount = state.pendingForCurrentUser.length;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Reasoned'),
            actions: [
              IconButton(
                tooltip: 'Wartende Beiträge',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => PendingScreen(state: state),
                    ),
                  );
                },
                icon: Badge(
                  label: pendingCount > 0 ? Text('$pendingCount') : null,
                  isLabelVisible: pendingCount > 0,
                  child: const Icon(Icons.hourglass_top_outlined),
                ),
              ),
              IconButton(
                tooltip: 'Einstellungen',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => SettingsScreen(state: state),
                    ),
                  );
                },
                icon: const Icon(Icons.settings_outlined),
              ),
            ],
          ),
          body: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: posts.length,
            itemBuilder: (context, i) {
              final post = posts[i];
              return PostCard(
                post: post,
                state: state,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => PostDetailScreen(
                        state: state,
                        postId: post.id,
                      ),
                    ),
                  );
                },
              );
            },
          ),
          floatingActionButton: FloatingActionButton.extended(
            icon: const Icon(Icons.edit_outlined),
            label: const Text('Neuer Beitrag'),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ComposePostScreen(state: state),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
