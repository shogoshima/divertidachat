class User {
  String? id;
  String? name;
  String? username;
  String? email;
  String? photoUrl;

  User({
    this.id,
    this.name,
    this.username,
    this.email,
    this.photoUrl,
  });

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    username = json['username'];
    email = json['email'];
    photoUrl = json['photo_url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['username'] = username;
    data['email'] = email;
    data['photo_url'] = photoUrl;
    return data;
  }
}
