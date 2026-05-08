import 'dart:io';

import 'package:flutter/material.dart';

import '../models.dart';

/// Renders a user avatar that supports both bundled assets (paths starting
/// with `assets/`) and on-device files (any other path). Falls back to the
/// user's initial on a colored background.
class UserAvatar extends StatelessWidget {
  final AppUser? user;
  final double radius;
  final Color? fallbackColor;
  final TextStyle? initialStyle;

  const UserAvatar({
    super.key,
    required this.user,
    required this.radius,
    this.fallbackColor,
    this.initialStyle,
  });

  ImageProvider? _provider() {
    final path = user?.avatarPath;
    if (path == null || path.isEmpty) return null;
    if (path.startsWith('assets/')) return AssetImage(path);
    final file = File(path);
    if (!file.existsSync()) return null;
    return FileImage(file);
  }

  @override
  Widget build(BuildContext context) {
    final provider = _provider();
    final color =
        fallbackColor ?? Theme.of(context).colorScheme.primaryContainer;
    if (provider != null) {
      return CircleAvatar(
        radius: radius,
        backgroundImage: provider,
      );
    }
    return CircleAvatar(
      radius: radius,
      backgroundColor: color.withValues(alpha: 0.2),
      foregroundColor: color,
      child: Text(
        user == null || user!.klarname.isEmpty
            ? '?'
            : user!.klarname.characters.first,
        style: initialStyle ??
            TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: radius * 0.9,
            ),
      ),
    );
  }
}
