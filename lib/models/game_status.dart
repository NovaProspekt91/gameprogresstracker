import 'package:flutter/material.dart';

enum GameStatus {
  playing,
  completed,
  backlog,
  dropped,
}

extension GameStatusExtension on GameStatus {
  String get label {
    switch (this) {
      case GameStatus.playing:
        return 'Playing';
      case GameStatus.completed:
        return 'Completed';
      case GameStatus.backlog:
        return 'Backlog';
      case GameStatus.dropped:
        return 'Dropped';
    }
  }

  Color get color {
    switch (this) {
      case GameStatus.playing:
        return const Color(0xFF4CAF50);
      case GameStatus.completed:
        return const Color(0xFF2196F3);
      case GameStatus.backlog:
        return const Color(0xFFFF9800);
      case GameStatus.dropped:
        return const Color(0xFFF44336);
    }
  }

  IconData get icon {
    switch (this) {
      case GameStatus.playing:
        return Icons.play_circle_filled;
      case GameStatus.completed:
        return Icons.check_circle;
      case GameStatus.backlog:
        return Icons.bookmark;
      case GameStatus.dropped:
        return Icons.cancel;
    }
  }

  String get value {
    return name;
  }

  static GameStatus fromString(String value) {
    return GameStatus.values.firstWhere(
      (s) => s.name == value,
      orElse: () => GameStatus.backlog,
    );
  }
}
