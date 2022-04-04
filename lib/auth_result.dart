import 'user.dart';

class AuthResult {
  final String authToken;
  final String userId;
  final User me;

  AuthResult({
    required this.me,
    this.authToken = '',
    this.userId = '',
  });

  AuthResult.fromMap(Map<String, dynamic> map)
      : authToken = map['authToken'],
        userId = map['userId'],
        me = User.fromMap(map['me']);

  Map<String, dynamic> toMap() => {
        'authToken': authToken,
        'userId': userId,
        'me': me.toMap(),
      };

  @override
  String toString() {
    return '${toMap()}';
  }
}
