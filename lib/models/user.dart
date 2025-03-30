class User {
  final String id;
  final String name;
  final String username;
  final String email;
  final String? photoUrl;

  User({
    required this.id,
    required this.name,
    required this.username,
    required this.email,
    required this.photoUrl,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      username: json['username'],
      email: json['email'],
      photoUrl: json['photo_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'username': username,
      'email': email,
      'photo_url': photoUrl,
    };
  }
}
