import 'game_status.dart';

class Game {
  final int? id;
  final String title;
  final String platform;
  final GameStatus status;
  final double hoursPlayed;
  final int completionPercent;
  final double rating;
  final String notes;
  final DateTime createdAt;

  const Game({
    this.id,
    required this.title,
    required this.platform,
    required this.status,
    required this.hoursPlayed,
    required this.completionPercent,
    required this.rating,
    required this.notes,
    required this.createdAt,
  });

  Game copyWith({
    int? id,
    String? title,
    String? platform,
    GameStatus? status,
    double? hoursPlayed,
    int? completionPercent,
    double? rating,
    String? notes,
    DateTime? createdAt,
  }) {
    return Game(
      id: id ?? this.id,
      title: title ?? this.title,
      platform: platform ?? this.platform,
      status: status ?? this.status,
      hoursPlayed: hoursPlayed ?? this.hoursPlayed,
      completionPercent: completionPercent ?? this.completionPercent,
      rating: rating ?? this.rating,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'platform': platform,
      'status': status.value,
      'hoursPlayed': hoursPlayed,
      'completionPercent': completionPercent,
      'rating': rating,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Game.fromMap(Map<String, dynamic> map) {
    return Game(
      id: map['id'] as int?,
      title: map['title'] as String,
      platform: map['platform'] as String,
      status: GameStatusExtension.fromString(map['status'] as String),
      hoursPlayed: (map['hoursPlayed'] as num).toDouble(),
      completionPercent: map['completionPercent'] as int,
      rating: (map['rating'] as num).toDouble(),
      notes: map['notes'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  @override
  String toString() {
    return 'Game(id: $id, title: $title, platform: $platform, status: ${status.label})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Game && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
