import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter/material.dart';
import 'package:websocket_channel/test_pick_files.dart';
import 'package:websocket_channel/ws_message.dart';

import 'apis.dart';
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
  static const WS_URL = 'ws://localhost:3000/websocket';

  final TextEditingController _controller = TextEditingController();
  late WebSocketChannel _channel;
  StreamController wsEventStream = StreamController.broadcast();
  String _session = '';
  AuthResult? authResult;

  List<Room> _listRooms = [];
  Map<String, int> _unreadMsg = {};

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
                        Apis.login('giaptt.hust', '123456').then((value) {
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
                          // _channel.sink.add(
                          //     WsMessage.streamNotifyUser(authResult!.userId));
                        }
                      },
                      child: Text('subscription')),
              TextButton(
                  onPressed: () {
                    Apis.getListRoom(authResult!.authToken, authResult!.userId)
                        .then((value) {
                      setState(() {
                        _listRooms = value;
                        _listRooms.forEach((room) {
                          _unreadMsg.addEntries([MapEntry(room.id, 0)]);
                        });
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
                    itemBuilder: (context, index) {
                      final room = _listRooms[index];
                      return Card(
                        child: ListTile(
                          title: Row(
                            children: [
                              Expanded(child: Text('${room.name}')),
                              _unreadMsg[room.id]! > 0
                                  ? Text(
                                      '${_unreadMsg[room.id]}',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.red),
                                    )
                                  : SizedBox(),
                              IconButton(
                                  onPressed: () {
                                    _channel.sink.add(
                                        WsMessage.unSubStreamRoomMessage(
                                            room.id));
                                  },
                                  icon: Icon(Icons.remove))
                            ],
                          ),
                          onTap: () {
                            _channel.sink.add(WsMessage.streamRoomMessage(
                                _listRooms[index].id));
                          },
                        ),
                      );
                    }),
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
        final fields = map['fields'] as Map;
        final eventName = fields['eventName'];

        final args = fields['args'] as List;
        print('-- args: $args');
        final rid = args[0]['rid'];
        setState(() {
          int newUnread = (_unreadMsg[rid] ?? 0);
          newUnread += args.length;
          _unreadMsg[rid] = newUnread;
        });
      }
    } catch (e) {
      print('--- ${e.toString()}');
    }
  }
}
