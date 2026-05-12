import 'package:flutter/material.dart';

enum Stance { pro, contra, nachfrage, neutral }

extension StanceX on Stance {
  String get label {
    switch (this) {
      case Stance.pro:
        return 'Zustimmung';
      case Stance.contra:
        return 'Ablehnung';
      case Stance.nachfrage:
        return 'Nachfrage';
      case Stance.neutral:
        return 'Neutral';
    }
  }

  Color get color {
    switch (this) {
      case Stance.pro:
        return const Color(0xFF2E7D32);
      case Stance.contra:
        return const Color(0xFFC62828);
      case Stance.nachfrage:
        return const Color(0xFF6A1B9A);
      case Stance.neutral:
        return const Color(0xFF455A64);
    }
  }

  IconData get icon {
    switch (this) {
      case Stance.pro:
        return Icons.thumb_up_alt_outlined;
      case Stance.contra:
        return Icons.thumb_down_alt_outlined;
      case Stance.nachfrage:
        return Icons.help_outline;
      case Stance.neutral:
        return Icons.remove;
    }
  }
}

enum Topic { tempolimit, buergergeld, klimaWirtschaft, wahlrechtAb16 }

extension TopicX on Topic {
  String get label {
    switch (this) {
      case Topic.tempolimit:
        return 'Tempolimit auf Autobahnen';
      case Topic.buergergeld:
        return 'Bürgergeld';
      case Topic.klimaWirtschaft:
        return 'Klimaschutz vs. Wirtschaft';
      case Topic.wahlrechtAb16:
        return 'Wahlrecht ab 16';
    }
  }

  Color get color {
    switch (this) {
      case Topic.tempolimit:
        return const Color(0xFFEF6C00);
      case Topic.buergergeld:
        return const Color(0xFF2E7D32);
      case Topic.klimaWirtschaft:
        return const Color(0xFF00838F);
      case Topic.wahlrechtAb16:
        return const Color(0xFF6A1B9A);
    }
  }

  IconData get icon {
    switch (this) {
      case Topic.tempolimit:
        return Icons.speed_outlined;
      case Topic.buergergeld:
        return Icons.savings_outlined;
      case Topic.klimaWirtschaft:
        return Icons.eco_outlined;
      case Topic.wahlrechtAb16:
        return Icons.how_to_vote_outlined;
    }
  }
}

class AppUser {
  final String id;
  final String klarname;
  final bool verified;
  final bool rulesAccepted;
  final String stadt;
  final int? alter;
  final String? avatarPath;

  const AppUser({
    required this.id,
    required this.klarname,
    required this.verified,
    required this.rulesAccepted,
    required this.stadt,
    this.alter,
    this.avatarPath,
  });

  AppUser copyWith({
    String? klarname,
    bool? verified,
    bool? rulesAccepted,
    String? stadt,
    int? alter,
    String? avatarPath,
  }) {
    return AppUser(
      id: id,
      klarname: klarname ?? this.klarname,
      verified: verified ?? this.verified,
      rulesAccepted: rulesAccepted ?? this.rulesAccepted,
      stadt: stadt ?? this.stadt,
      alter: alter ?? this.alter,
      avatarPath: avatarPath ?? this.avatarPath,
    );
  }
}

class Reply {
  final String id;
  final String authorId;
  final Stance stance;
  final String? steelman;
  final String content;
  final DateTime publishedAt;

  static const int minContentLength = 120;
  static const int minSteelmanLength = 80;

  const Reply({
    required this.id,
    required this.authorId,
    required this.stance,
    required this.steelman,
    required this.content,
    required this.publishedAt,
  });

  bool get counts {
    if (content.trim().length < minContentLength) return false;
    if (stance == Stance.contra) {
      final s = steelman?.trim() ?? '';
      if (s.length < minSteelmanLength) return false;
    }
    return true;
  }
}

class Post {
  final String id;
  final String authorId;
  final Topic topic;
  final Stance stance;
  final String content;
  final DateTime publishedAt;
  final List<Reply> replies;

  const Post({
    required this.id,
    required this.authorId,
    required this.topic,
    required this.stance,
    required this.content,
    required this.publishedAt,
    required this.replies,
  });

  Post withReply(Reply r) {
    return Post(
      id: id,
      authorId: authorId,
      topic: topic,
      stance: stance,
      content: content,
      publishedAt: publishedAt,
      replies: [...replies, r],
    );
  }
}

class PendingPost {
  final String id;
  final String authorId;
  final Topic topic;
  final Stance stance;
  final String content;
  final DateTime queuedAt;
  final DateTime publishAt;
  final String triggerReason;

  const PendingPost({
    required this.id,
    required this.authorId,
    required this.topic,
    required this.stance,
    required this.content,
    required this.queuedAt,
    required this.publishAt,
    required this.triggerReason,
  });

  Duration remaining(DateTime now) {
    final d = publishAt.difference(now);
    return d.isNegative ? Duration.zero : d;
  }

  Post toPublished() {
    return Post(
      id: id,
      authorId: authorId,
      topic: topic,
      stance: stance,
      content: content,
      publishedAt: publishAt,
      replies: const [],
    );
  }
}
