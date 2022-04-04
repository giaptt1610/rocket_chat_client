class Room {
  final String id;

  //d: Direct chat
  // c: Chat
  // p: Private chat
  // l: Livechat
  final String t;

  // room name
  final String name;
  final String? fname;

  // the room creator
  final U? u;

  final String? topic;

  // list of muted users by its username
  final List<String>? muted;

  final String? ts;

  final String? updatedAt;

  Room({
    this.id = '',
    this.t = '',
    this.name = '',
    this.fname,
    this.u,
    this.topic,
    this.muted,
    this.ts,
    this.updatedAt,
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
        updatedAt = map['_updatedAt'];

  Map<String, dynamic> toMap() => {
        '_id': id,
        't': t,
        'name': name,
        'topic': topic,
        'muted': muted,
        'ts': ts,
        '_updatedAt': updatedAt,
      };
}

class U {
  final String id;
  final String username;

  U.fromMap(Map<String, dynamic> map)
      : id = map['_id'],
        username = map['username'];
}