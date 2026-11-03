/// One saved study session (one row in the study_sessions table).
class StudySession {
  final int? id; // null until the row is inserted
  final String title;
  final String subject;
  final int durationMinutes;
  final String notes; // optional, empty string when not provided
  final DateTime createdAt;

  const StudySession({
    this.id,
    required this.title,
    required this.subject,
    required this.durationMinutes,
    this.notes = '',
    required this.createdAt,
  });

  Map<String, Object?> toMap() => {
        'id': id,
        'title': title,
        'subject': subject,
        'duration_minutes': durationMinutes,
        'notes': notes,
        'created_at': createdAt.toIso8601String(),
      };

  factory StudySession.fromMap(Map<String, Object?> map) => StudySession(
        id: map['id'] as int,
        title: map['title'] as String,
        subject: map['subject'] as String,
        durationMinutes: map['duration_minutes'] as int,
        notes: (map['notes'] as String?) ?? '',
        createdAt: DateTime.parse(map['created_at'] as String),
      );

  /// e.g. "05/11/2026 14:30"
  String get formattedDate {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(createdAt.day)}/${two(createdAt.month)}/${createdAt.year} '
        '${two(createdAt.hour)}:${two(createdAt.minute)}';
  }
}
