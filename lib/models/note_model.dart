class NoteModel {
  final int? id;
  final int userId;
  final String title;
  final String description;
  final String subject;
  final String semester; // S1-S8, or 'General'
  final String createdAt;

  NoteModel({
    this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.subject,
    this.semester = 'General',
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'description': description,
      'subject': subject,
      'semester': semester,
      'created_at': createdAt,
    };
  }

  factory NoteModel.fromMap(Map<String, dynamic> map) {
    return NoteModel(
      id: map['id'],
      userId: map['user_id'],
      title: map['title'],
      description: map['description'],
      subject: map['subject'],
      semester: map['semester'] ?? 'General',
      createdAt: map['created_at'],
    );
  }

  NoteModel copyWith({
    int? id,
    int? userId,
    String? title,
    String? description,
    String? subject,
    String? semester,
    String? createdAt,
  }) {
    return NoteModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      subject: subject ?? this.subject,
      semester: semester ?? this.semester,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
