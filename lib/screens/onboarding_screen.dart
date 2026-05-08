import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../app_state.dart';

class OnboardingScreen extends StatefulWidget {
  final AppState state;
  const OnboardingScreen({super.key, required this.state});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _stadtCtrl = TextEditingController();
  bool _verifying = false;
  String? _avatarPath;

  @override
  void initState() {
    super.initState();
    _nameCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _stadtCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (picked == null || !mounted) return;
      setState(() => _avatarPath = picked.path);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bildauswahl fehlgeschlagen: $e')),
      );
    }
  }

  Future<void> _showAvatarSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Aus Galerie wählen'),
              onTap: () {
                Navigator.pop(ctx);
                _pickAvatar(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Foto aufnehmen'),
              onTap: () {
                Navigator.pop(ctx);
                _pickAvatar(ImageSource.camera);
              },
            ),
            if (_avatarPath != null)
              ListTile(
                leading: const Icon(Icons.delete_outline),
                title: const Text('Bild entfernen'),
                onTap: () {
                  Navigator.pop(ctx);
                  setState(() => _avatarPath = null);
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _verifying = true);
    widget.state.createUser(
      klarname: _nameCtrl.text.trim(),
      stadt: _stadtCtrl.text.trim(),
      avatarPath: _avatarPath,
    );
    await widget.state.simulateVerification();
    // Navigation läuft über das ListenableBuilder-Conditional in main.dart.
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: scheme.surfaceContainerLowest,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(20, 28, 20, 28),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      scheme.primaryContainer,
                      scheme.tertiaryContainer,
                    ],
                  ),
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(28),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.forum_rounded,
                      size: 36,
                      color: scheme.onPrimaryContainer,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Willkommen bei Reasoned',
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(
                            color: scheme.onPrimaryContainer,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Politische Debatten, mit Regeln, die für alle gelten.',
                      style: TextStyle(
                        color: scheme.onPrimaryContainer
                            .withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Lege dein verifiziertes Profil an',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Anonyme Konten gibt es hier nicht. Du brauchst deinen '
                        'echten Namen und eine kurze Verifizierung. Ein '
                        'Profilbild ist optional.',
                        style: TextStyle(color: scheme.onSurfaceVariant),
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: GestureDetector(
                          onTap: _showAvatarSheet,
                          child: Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              Container(
                                width: 112,
                                height: 112,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _avatarPath == null
                                      ? scheme.primaryContainer
                                      : scheme.surface,
                                  border: Border.all(
                                    color: scheme.primary,
                                    width: 2,
                                  ),
                                  image: _avatarPath == null
                                      ? null
                                      : DecorationImage(
                                          image: FileImage(File(_avatarPath!)),
                                          fit: BoxFit.cover,
                                        ),
                                ),
                                child: _avatarPath != null
                                    ? null
                                    : Center(
                                        child: _nameCtrl.text.trim().isEmpty
                                            ? Icon(
                                                Icons.person_outline,
                                                size: 52,
                                                color: scheme.onPrimaryContainer,
                                              )
                                            : Text(
                                                _nameCtrl.text
                                                    .trim()
                                                    .characters
                                                    .first
                                                    .toUpperCase(),
                                                style: TextStyle(
                                                  fontSize: 56,
                                                  fontWeight: FontWeight.w800,
                                                  color: scheme
                                                      .onPrimaryContainer,
                                                ),
                                              ),
                                      ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  color: scheme.primary,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: scheme.surface,
                                    width: 2,
                                  ),
                                ),
                                padding: const EdgeInsets.all(7),
                                child: Icon(
                                  Icons.camera_alt_outlined,
                                  color: scheme.onPrimary,
                                  size: 18,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: Text(
                          _avatarPath == null
                              ? 'Profilbild auswählen (optional) – sonst wird '
                                  'dein Anfangsbuchstabe angezeigt'
                              : 'Antippen, um Bild zu ändern',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: scheme.onSurfaceVariant,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _nameCtrl,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: 'Vor- und Nachname (Klarname)',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                        validator: (v) {
                          final t = v?.trim() ?? '';
                          if (t.length < 4) {
                            return 'Bitte gib deinen vollen Namen ein.';
                          }
                          if (!t.contains(' ')) {
                            return 'Vor- und Nachname mit Leerzeichen, bitte.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _stadtCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Stadt',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.location_city_outlined),
                        ),
                        validator: (v) => (v?.trim().isEmpty ?? true)
                            ? 'Bitte ausfüllen.'
                            : null,
                      ),
                      const SizedBox(height: 20),
                      Container(
                        decoration: BoxDecoration(
                          color: scheme.secondaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Icon(
                              Icons.fingerprint,
                              color: scheme.onSecondaryContainer,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Im Prototyp wird die Verifizierung simuliert '
                                '(2 Sek.). In Produktion wäre hier z. B. ein '
                                'eID- oder Postident-Schritt.',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: scheme.onSecondaryContainer,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      FilledButton.icon(
                        onPressed: _verifying ? null : _submit,
                        icon: _verifying
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.verified_outlined),
                        label: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Text(
                            _verifying
                                ? 'Verifiziere…'
                                : 'Klarname bestätigen & verifizieren',
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
