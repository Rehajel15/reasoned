import 'package:flutter/material.dart';

import '../app_state.dart';
import '../widgets/user_avatar.dart';
import 'rules_screen.dart';

class SettingsScreen extends StatelessWidget {
  final AppState state;
  const SettingsScreen({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: state,
      builder: (context, _) {
        final user = state.currentUser;
        return Scaffold(
          appBar: AppBar(title: const Text('Einstellungen')),
          body: ListView(
            children: [
              if (user != null) ...[
                ListTile(
                  leading: UserAvatar(user: user, radius: 22),
                  title: Text(user.klarname),
                  subtitle: Text(
                    '${user.stadt}'
                    '${user.alter != null ? " · ${user.alter} J." : ""}'
                    '\n${user.verified ? "verifiziert" : "nicht verifiziert"}',
                  ),
                  isThreeLine: true,
                  trailing:
                      user.verified ? const Icon(Icons.verified, color: Color(0xFF1976D2)) : null,
                ),
                const Divider(),
              ],
              SwitchListTile(
                title: const Text('Demo-Modus'),
                subtitle: Text(
                  state.demoMode
                      ? 'Abkühlzeit: 15 Sekunden statt 15 Minuten – damit du sie sofort testen kannst.'
                      : 'Abkühlzeit: echte 15 Minuten.',
                ),
                value: state.demoMode,
                onChanged: state.setDemoMode,
              ),
              const Divider(),
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: Text(
                  'Perspektive wechseln',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Text(
                  'Wechsle in einen anderen verifizierten Account, um den Filterblasen-Mix '
                  'aus einer anderen Sicht zu erleben.',
                  style: TextStyle(fontSize: 13),
                ),
              ),
              ...state.users.map(
                (u) {
                  final selected = state.currentUser?.id == u.id;
                  return ListTile(
                    selected: selected,
                    leading: UserAvatar(user: u, radius: 18),
                    title: Row(
                      children: [
                        Text(u.klarname),
                        if (u.verified) ...[
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.verified,
                            size: 14,
                            color: Color(0xFF1976D2),
                          ),
                        ],
                      ],
                    ),
                    subtitle: Text(u.stadt),
                    trailing: selected
                        ? Icon(
                            Icons.radio_button_checked,
                            color: Theme.of(context).colorScheme.primary,
                          )
                        : const Icon(Icons.radio_button_unchecked),
                    onTap: () => state.switchUser(u.id),
                  );
                },
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.menu_book_outlined),
                title: const Text('Spielregeln erneut ansehen'),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          RulesScreen(state: state, isReview: true),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Reasoned ist ein Prototyp für eine politische Debatten-App.',
                  style: TextStyle(
                    color: Theme.of(context).hintColor,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
