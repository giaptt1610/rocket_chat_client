import 'u.dart';

class Room {
  final String id;

  //d: Direct chat
  // c: Chat
  // p: Private chat
  // l: Livechat
  final String t;

  // room name
  final String? name;
  final String? fname;

  // the room creator
  final U? u;

  final String? topic;

  // list of muted users by its username
  final List<String>? muted;

  final String? ts;

  final String? updatedAt;

  final List<String>? usernames;
  final int? usersCount;

  Room({
    this.id = '',
    this.t = '',
    this.name,
    this.fname,
    this.u,
    this.topic,
    this.muted,
    this.ts,
    this.updatedAt,
    this.usernames,
    this.usersCount,
  });

  Room.fromMap(Map<String, dynamic> map)
      : id = map['_id'],
        t = map['t'],
        name = map['name'],
        fname = map['fname'],
        u = map['u'] != null ? U.fromMap(map['u']) : null,
        topic = map['topic'],
        muted = map['muted'],
        ts = map['ts'],
        updatedAt = map['_updatedAt'],
        usernames = map['usernames'] != null
            ? (map['usernames'] as List).map((e) => e.toString()).toList()
            : null,
        usersCount = map['usersCount'];

  Map<String, dynamic> toMap() => {
        '_id': id,
        't': t,
        'name': name,
        'topic': topic,
        'muted': muted,
        'ts': ts,
        '_updatedAt': updatedAt,
      };

  String? get dmName {
    if (usernames != null) {
      return usernames![0];
    }
  }
}
