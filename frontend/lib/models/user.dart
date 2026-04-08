class User {
  final String id;
  final String email;
  final String displayName;
  final String? defaultAiProvider;

  const User({
    required this.id,
    required this.email,
    required this.displayName,
    this.defaultAiProvider,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      displayName: json['display_name'] as String? ?? json['displayName'] as String? ?? '',
      defaultAiProvider: json['default_ai_provider'] as String? ?? json['defaultAiProvider'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'display_name': displayName,
      'default_ai_provider': defaultAiProvider,
    };
  }

  User copyWith({
    String? id,
    String? email,
    String? displayName,
    String? defaultAiProvider,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      defaultAiProvider: defaultAiProvider ?? this.defaultAiProvider,
    );
  }
}
