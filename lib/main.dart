import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter/material.dart';
import 'package:websocket_channel/test_pick_files.dart';
import 'package:websocket_channel/ws_message.dart';
import 'package:http/http.dart' as http;

import 'auth_result.dart';
import 'room.dart';
import 'user.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const title = 'Demo';
    return const MaterialApp(
      title: title,
      home: MyHomePage(
        title: title,
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    Key? key,
    required this.title,
  }) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static const HOST = 'localhost:3000';
  static const WS_URL = 'ws://localhost:3000/websocket';

  final TextEditingController _controller = TextEditingController();
  late WebSocketChannel _channel;
  StreamController wsEventStream = StreamController.broadcast();
  String _session = '';
  AuthResult? authResult;

  List<Room> _listRooms = [];

  @override
  void initState() {
    super.initState();

    _channel = WebSocketChannel.connect(
      Uri.parse(WS_URL),
    );

    _channel.stream.listen((event) {
      wsEventStream.sink.add(event);
    });

    wsEventStream.stream.listen((event) {
      _handleWsEvent(event);
    });

    _channel.sink.add(WsMessage.connectMsg());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Form(
              //   child: TextFormField(
              //     controller: _controller,
              //     decoration: const InputDecoration(labelText: 'Send a message'),
              //   ),
              // ),
              // const SizedBox(height: 24),
              authResult == null
                  ? TextButton(
                      onPressed: () {
                        _login('giaptt.hust', '123456').then((value) {
                          setState(() {
                            authResult = value;
                          });
                        });
                      },
                      child: Text('login'))
                  : TextButton(
                      onPressed: () {
                        if (_session.isNotEmpty) {
                          _channel.sink.add(
                              WsMessage.loginRequest(authResult!.authToken));
                          _channel.sink.add(
                              WsMessage.streamNotifyUser(authResult!.userId));
                        }
                      },
                      child: Text('subscription')),
              TextButton(
                  onPressed: () {
                    _getListRoom(authResult!.authToken, authResult!.userId)
                        .then((value) {
                      setState(() {
                        _listRooms = value;
                      });
                    });
                  },
                  child: Text('get room')),
              SizedBox(height: 10.0),
              Container(
                constraints: const BoxConstraints(
                  maxHeight: 300,
                  // minHeight: 150,
                ),
                child: ListView.builder(
                  itemCount: _listRooms.length,
                  itemBuilder: (context, index) => Card(
                    child: ListTile(
                      title: Row(
                        children: [
                          Expanded(child: Text('${_listRooms[index].name}')),
                          IconButton(
                              onPressed: () {
                                _channel.sink.add(
                                    WsMessage.unSubStreamRoomMessage(
                                        _listRooms[index].id));
                              },
                              icon: Icon(Icons.remove))
                        ],
                      ),
                      onTap: () {
                        _channel.sink.add(
                            WsMessage.streamRoomMessage(_listRooms[index].id));
                      },
                    ),
                  ),
                ),
              ),

              TextButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        CupertinoPageRoute(
                            builder: (context) => TestPickFile()));
                  },
                  child: Text('Test Pick File')),
            ],
          ),
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: _sendMessage,
      //   tooltip: 'Send message',
      //   child: const Icon(Icons.send),
      // ),
    );
  }

  void _sendMessage() {
    if (_controller.text.isNotEmpty) {
      _channel.sink.add(_controller.text);
    }
  }

  @override
  void dispose() {
    wsEventStream.sink.close();
    _channel.sink.close();
    _controller.dispose();
    super.dispose();
  }

  void _handleWsEvent(event) {
    try {
      final Map<String, dynamic> map = jsonDecode(event);
      print(map);
      if (map['msg'] == 'ping') {
        _channel.sink.add(WsMessage.pongMsg());
      } else if (map['msg'] == 'connected') {
        setState(() {
          _session = map['session'];
        });
      } else if (map['msg'] == 'changed' &&
          map['collection'] == 'stream-room-messages') {
        final args = map['args'] as List;
      }
    } catch (e) {
      print('--- ${e.toString()}');
    }
  }

  Future<AuthResult?> _login(String username, String pass) async {
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

  Future<List<Room>> _getListRoom(String authToken, String userId) async {
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
