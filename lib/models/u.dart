/// simplified version of the user information
class U {
  final String id;
  final String username;

  U.fromMap(Map<String, dynamic> map)
      : id = map['_id'],
        username = map['username'];
}
