class User {
  final String id;
  final String name;
  final String username;

  final String status;
  final String? avatarUrl;
  final Object? emails;

  User(
      {this.id = '',
      this.name = '',
      this.username = '',
      this.status = '',
      this.avatarUrl,
      this.emails});

  User.fromMap(Map<String, dynamic> map)
      : id = map['_id'],
        name = map['name'],
        username = map['username'],
        status = map['status'],
        avatarUrl = map['avatarUrl'],
        emails = map['emails'];

  Map<String, dynamic> toMap() => {
        '_id': id,
        'name': name,
        'username': username,
        'status': status,
        'avatarUrl': avatarUrl,
        'emails': emails,
      };

  @override
  String toString() {
    return '${toMap()}';
  }
}
