import 'dart:convert';

class WsMessage {
  static String connectMsg() {
    return jsonEncode({
      "msg": "connect",
      "version": "1",
      "support": ["1", "pre2", "pre1"]
    });
  }

  static String loginRequest(String authToken) {
    return jsonEncode({
      "msg": "method",
      "method": "login",
      "id": "42",
      "params": [
        {"resume": authToken}
      ]
    });
  }

  static String pongMsg() {
    return jsonEncode({
      "msg": "pong",
    });
  }

  static String subscription(String uniqueId) {
    return jsonEncode({
      "msg": "sub",
      "id": uniqueId,
      "name": "the-stream",
      "params": ["event", false]
    });
  }

  static String streamNotifyUser(String userId) {
    return jsonEncode({
      "msg": "sub",
      "id": "$userId subscription-id",
      "name": "stream-notify-user",
      "params": ["$userId/event", false]
    });
  }

  static String streamRoomMessage(String roomId) {
    return jsonEncode({
      "msg": "sub",
      "id": roomId + "subscription-id",
      "name": "stream-room-messages",
      "params": [roomId, false]
    });
  }

  static String unSubStreamRoomMessage(String roomId) {
    return jsonEncode({
      "msg": "unsub",
      "id": roomId + "subscription-id",
    });
  }
}
