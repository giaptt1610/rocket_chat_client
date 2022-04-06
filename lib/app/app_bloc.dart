import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:websocket_channel/apis.dart';
import 'package:websocket_channel/auth_result.dart';

import '../ws_message.dart';
import '../room.dart';

part 'app_event.dart';
part 'app_state.dart';

class AppBloc extends Bloc<AppEvent, AppState> {
  late WebSocketChannel _channel;
  static const WS_URL = 'ws://${Apis.HOST}/websocket';

  AppBloc() : super(AppState()) {
    _channel = WebSocketChannel.connect(
      Uri.parse(WS_URL),
    );

    _channel.stream.listen(_handleWsEvent);

    on<AppEvent>((event, emit) {
      // TODO: implement event handler
    });

    on<AuthenticatedEvent>((event, emit) {
      emit(state.copyWith(authResult: event.authResult));
    });

    on<WsLoginEvent>((event, emit) {
      _channel.sink.add(WsMessage.connectMsg());
      _channel.sink.add(WsMessage.loginRequest(event.authToken));
    });

    on<WsSubscribeRoomsEvent>((event, emit) {
      event.rooms.forEach((room) {
        _channel.sink.add(WsMessage.streamRoomMessage(room.id));
      });
    });
  }

  void _handleWsEvent(event) {
    try {
      final Map<String, dynamic> map = jsonDecode(event);
      print(map);
      if (map['msg'] == 'ping') {
        _channel.sink.add(WsMessage.pongMsg());
      } else if (map['msg'] == 'connected') {
      } else if (map['msg'] == 'changed' &&
          map['collection'] == 'stream-room-messages') {
        final fields = map['fields'] as Map;
        final eventName = fields['eventName'];

        final args = fields['args'] as List;
        print('-- args: $args');
        final rid = args[0]['rid'];
        // setState(() {
        //   int newUnread = (_unreadMsg[rid] ?? 0);
        //   newUnread += args.length;
        //   _unreadMsg[rid] = newUnread;
        // });
      }
    } catch (e) {
      print('--- ${e.toString()}');
    }
  }

  @override
  Future<void> close() {
    _channel.sink.close();
    return super.close();
  }
}
