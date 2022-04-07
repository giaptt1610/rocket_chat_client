import 'u.dart';

class Message {
  final String id;

  // room id
  final String rid;

  // the textual message
  final String msg;

  // timestamp (date creation on client)
  final String ts;

  // the user that sent the message
  final U? u;

  final String updatedAt;

  final String? editedAt;
  final U? editedBy;

  final Object? urls;
  final List<String>? attachments;
  final Object? alias;

  final String? avatar;

  /// that states whether or not this message should be grouped together with other messages from the same user
  final bool? groupable;

  final Object? parseUrls;

  Message({
    this.id = '',
    this.rid = '',
    this.msg = '',
    this.ts = '',
    this.u,
    this.updatedAt = '',
    this.editedAt,
    this.editedBy,
    this.urls,
    this.attachments,
    this.alias,
    this.avatar,
    this.groupable,
    this.parseUrls,
  });

  Message.fromMap(Map<String, dynamic> map)
      : id = map['_id'],
        rid = map['rid'],
        msg = map['msg'],
        ts = map['ts'],
        u = map['u'] != null ? U.fromMap(map['u']) : null,
        updatedAt = map['_updatedAt'],
        editedAt = map['editedAt'],
        editedBy = map['editedBy'] != null ? U.fromMap(map['editedBy']) : null,
        urls = map['urls'],
        attachments = map['attachments'],
        alias = map['alias'],
        avatar = map['avatar'],
        groupable = map['groupable'] != null ? map['groupable'] as bool : null,
        parseUrls = map['parseUrls'];
}
