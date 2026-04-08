class Note {
  final String id;
  final String title;
  final String contentMarkdown;
  final String? sourceImageUrl;
  final String? aiProviderUsed;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Note({
    required this.id,
    required this.title,
    required this.contentMarkdown,
    this.sourceImageUrl,
    this.aiProviderUsed,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'] as String,
      title: json['title'] as String? ?? 'Untitled',
      contentMarkdown: json['content_markdown'] as String? ??
          json['contentMarkdown'] as String? ??
          '',
      sourceImageUrl: json['source_image_url'] as String? ??
          json['sourceImageUrl'] as String?,
      aiProviderUsed: json['ai_provider_used'] as String? ??
          json['aiProviderUsed'] as String?,
      createdAt: DateTime.parse(
          json['created_at'] as String? ?? json['createdAt'] as String? ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(
          json['updated_at'] as String? ?? json['updatedAt'] as String? ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content_markdown': contentMarkdown,
      'source_image_url': sourceImageUrl,
      'ai_provider_used': aiProviderUsed,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Note copyWith({
    String? id,
    String? title,
    String? contentMarkdown,
    String? sourceImageUrl,
    String? aiProviderUsed,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      contentMarkdown: contentMarkdown ?? this.contentMarkdown,
      sourceImageUrl: sourceImageUrl ?? this.sourceImageUrl,
      aiProviderUsed: aiProviderUsed ?? this.aiProviderUsed,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
