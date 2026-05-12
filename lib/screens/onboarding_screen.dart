import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../app_state.dart';

enum _Step { capture, verifying, verified }

class OnboardingScreen extends StatefulWidget {
  final AppState state;
  const OnboardingScreen({super.key, required this.state});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  // Werte, die die simulierte KI aus dem Ausweis "ausliest".
  static const String _aiKlarname = 'Max Mustermann';
  static const String _aiStadt = 'Berlin';
  static const int _aiAlter = 34;

  _Step _step = _Step.capture;
  String? _frontPath;
  String? _backPath;
  bool _submitting = false;

  Future<void> _pickIdPhoto({
    required bool front,
    required ImageSource source,
  }) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: source,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 85,
      );
      if (picked == null || !mounted) return;
      setState(() {
        if (front) {
          _frontPath = picked.path;
        } else {
          _backPath = picked.path;
        }
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Aufnahme fehlgeschlagen: $e')),
      );
    }
  }

  Future<void> _showIdSheet({required bool front}) async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Foto aufnehmen'),
              onTap: () {
                Navigator.pop(ctx);
                _pickIdPhoto(front: front, source: ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Aus Galerie wählen'),
              onTap: () {
                Navigator.pop(ctx);
                _pickIdPhoto(front: front, source: ImageSource.gallery);
              },
            ),
            if ((front ? _frontPath : _backPath) != null)
              ListTile(
                leading: const Icon(Icons.delete_outline),
                title: const Text('Foto entfernen'),
                onTap: () {
                  Navigator.pop(ctx);
                  setState(() {
                    if (front) {
                      _frontPath = null;
                    } else {
                      _backPath = null;
                    }
                  });
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _startAiCheck() async {
    setState(() => _step = _Step.verifying);
    // Simulierte KI-Echtheitsprüfung.
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;
    setState(() => _step = _Step.verified);
  }

  Future<void> _submit() async {
    setState(() => _submitting = true);
    widget.state.createUser(
      klarname: _aiKlarname,
      stadt: _aiStadt,
      alter: _aiAlter,
      avatarPath: _frontPath,
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
              _Header(scheme: scheme),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildStepBody(scheme),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepBody(ColorScheme scheme) {
    switch (_step) {
      case _Step.capture:
        return _buildCaptureStep(scheme);
      case _Step.verifying:
        return _buildVerifyingStep(scheme);
      case _Step.verified:
        return _buildVerifiedStep(scheme);
    }
  }

  Widget _buildCaptureStep(ColorScheme scheme) {
    final bothCaptured = _frontPath != null && _backPath != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Verifiziere dich mit deinem Personalausweis',
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        Text(
          'Fotografiere die Vorder- und Rückseite deines Personalausweises. '
          'Anschließend prüft eine KI die Echtheit und übernimmt Name, '
          'Alter, Stadt und dein Profilbild automatisch.',
          style: TextStyle(color: scheme.onSurfaceVariant),
        ),
        const SizedBox(height: 20),
        _IdSlot(
          label: 'Vorderseite',
          hint: 'Foto vorne (mit Bild & Name)',
          path: _frontPath,
          onTap: () => _showIdSheet(front: true),
          scheme: scheme,
        ),
        const SizedBox(height: 12),
        _IdSlot(
          label: 'Rückseite',
          hint: 'Foto hinten (mit Anschrift)',
          path: _backPath,
          onTap: () => _showIdSheet(front: false),
          scheme: scheme,
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
              Icon(Icons.fingerprint, color: scheme.onSecondaryContainer),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Im Prototyp wird die KI-Echtheitsprüfung simuliert (3 Sek.). '
                  'In Produktion wäre hier z. B. eine eID- oder Postident-'
                  'Erkennung.',
                  style: TextStyle(
                    fontSize: 13,
                    color: scheme.onSecondaryContainer,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        FilledButton.icon(
          onPressed: bothCaptured ? _startAiCheck : null,
          icon: const Icon(Icons.auto_awesome),
          label: const Padding(
            padding: EdgeInsets.symmetric(vertical: 6),
            child: Text('Echtheit per KI prüfen'),
          ),
        ),
      ],
    );
  }

  Widget _buildVerifyingStep(ColorScheme scheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 16),
        Center(
          child: Container(
            width: 92,
            height: 92,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: scheme.primaryContainer,
            ),
            child: Center(
              child: SizedBox(
                width: 44,
                height: 44,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: scheme.primary,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Center(
          child: Text(
            'KI prüft die Echtheit deines Ausweises…',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(height: 6),
        Center(
          child: Text(
            'Wir lesen Name, Alter, Stadt und dein Lichtbild aus. '
            'Das dauert nur einen Moment.',
            textAlign: TextAlign.center,
            style: TextStyle(color: scheme.onSurfaceVariant),
          ),
        ),
      ],
    );
  }

  Widget _buildVerifiedStep(ColorScheme scheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Icon(Icons.verified, color: scheme.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Ausweis erkannt – Daten übernommen',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Die folgenden Felder hat die KI automatisch aus deinem Ausweis '
          'gezogen. Du kannst sie hier nicht ändern – das ist der Sinn der '
          'Verifizierung.',
          style: TextStyle(color: scheme.onSurfaceVariant),
        ),
        const SizedBox(height: 20),
        Center(
          child: Container(
            width: 112,
            height: 112,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: scheme.primaryContainer,
              border: Border.all(color: scheme.primary, width: 2),
              image: _frontPath == null
                  ? null
                  : DecorationImage(
                      image: FileImage(File(_frontPath!)),
                      fit: BoxFit.cover,
                    ),
            ),
            child: _frontPath != null
                ? null
                : Center(
                    child: Icon(
                      Icons.person_outline,
                      size: 52,
                      color: scheme.onPrimaryContainer,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: Text(
            'Profilbild aus Ausweisfoto',
            style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 12),
          ),
        ),
        const SizedBox(height: 20),
        _ReadonlyField(
          label: 'Vor- und Nachname (Klarname)',
          value: _aiKlarname,
          icon: Icons.person_outline,
        ),
        const SizedBox(height: 12),
        _ReadonlyField(
          label: 'Alter',
          value: '$_aiAlter Jahre',
          icon: Icons.cake_outlined,
        ),
        const SizedBox(height: 12),
        _ReadonlyField(
          label: 'Stadt',
          value: _aiStadt,
          icon: Icons.location_city_outlined,
        ),
        const SizedBox(height: 24),
        FilledButton.icon(
          onPressed: _submitting ? null : _submit,
          icon: _submitting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.verified_outlined),
          label: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Text(
              _submitting ? 'Verifiziere…' : 'Übernehmen & fortfahren',
            ),
          ),
        ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  final ColorScheme scheme;
  const _Header({required this.scheme});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [scheme.primaryContainer, scheme.tertiaryContainer],
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
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: scheme.onPrimaryContainer,
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'Politische Debatten, mit Regeln, die für alle gelten.',
            style: TextStyle(
              color: scheme.onPrimaryContainer.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}

class _IdSlot extends StatelessWidget {
  final String label;
  final String hint;
  final String? path;
  final VoidCallback onTap;
  final ColorScheme scheme;

  const _IdSlot({
    required this.label,
    required this.hint,
    required this.path,
    required this.onTap,
    required this.scheme,
  });

  @override
  Widget build(BuildContext context) {
    final hasPhoto = path != null;
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        height: 140,
        decoration: BoxDecoration(
          color: hasPhoto ? scheme.surface : scheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: hasPhoto ? scheme.primary : scheme.outlineVariant,
            width: hasPhoto ? 2 : 1,
          ),
          image: hasPhoto
              ? DecorationImage(
                  image: FileImage(File(path!)),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.black.withValues(alpha: 0.15),
                    BlendMode.darken,
                  ),
                )
              : null,
        ),
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Icon(
              hasPhoto ? Icons.check_circle : Icons.add_a_photo_outlined,
              color: hasPhoto ? Colors.white : scheme.primary,
              size: 32,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: hasPhoto ? Colors.white : scheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    hasPhoto ? 'Foto aufgenommen – antippen zum Ändern' : hint,
                    style: TextStyle(
                      fontSize: 13,
                      color: hasPhoto
                          ? Colors.white.withValues(alpha: 0.85)
                          : scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReadonlyField extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _ReadonlyField({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      enabled: false,
      initialValue: value,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        prefixIcon: Icon(icon),
        suffixIcon: const Icon(Icons.lock_outline, size: 18),
      ),
    );
  }
}
