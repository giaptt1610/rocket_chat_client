import 'dart:convert';

import 'package:http/http.dart' as http;
import 'auth_result.dart';
import 'room.dart';

class Apis {
  static const HOST = 'localhost:3000';
  static Future<AuthResult?> login(String username, String pass) async {
    try {
      final response = await http.post(
        Uri.parse('http://$HOST/api/v1/login'),
        body: {
          'user': username,
          'password': pass,
        },
      );

      if (response.statusCode != 200) {
        return null;
      }

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      if (json['status'] != 'success') {
        return null;
      }

      final result = AuthResult.fromMap(json['data']);
      print('-- result: ${result.toString()}');
      return result;
    } catch (e) {
      print('-- Exception: ${e.toString()}');
      return null;
    }
  }

  static Future<List<Room>> getListRoom(String authToken, String userId) async {
    try {
      final response = await http.get(
        Uri.parse('http://$HOST/api/v1/rooms.get'),
        headers: {
          'Content-type': 'application/json',
          'X-Auth-Token': authToken,
          'X-User-Id': userId
        },
      );

      if (response.statusCode != 200) {
        return [];
      }

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      if (json['success'] != true) {
        return [];
      }

      List<Room> listRooms = [];
      final update = json['update'] as List;
      listRooms = update.map((e) => Room.fromMap(e)).toList();

      return listRooms;
    } catch (e) {
      print('-- Exception: ${e.toString()}');
      return [];
    }
  }
}
