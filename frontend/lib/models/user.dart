class User {
  final String id;
  final String username;
  final String token;

  const User({
    required this.id,
    required this.username,
    required this.token,
  });

  factory User.fromJson(Map<String, dynamic> json, String token) {
    return User(
      id: json['_id'] as String,
      username: json['username'] as String,
      token: token,
    );
  }

  Map<String, dynamic> toJson() => {
        '_id': id,
        'username': username,
      };
}
