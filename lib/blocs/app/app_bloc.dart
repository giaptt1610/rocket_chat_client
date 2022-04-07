import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../../common/apis.dart';
import '../../common/ws_message.dart';
import '../../models/auth_result.dart';
import '../../models/room.dart';

part 'app_event.dart';
part 'app_state.dart';

class AppBloc extends Bloc<AppEvent, AppState> {
  late WebSocketChannel _channel;
  static const WS_URL = 'ws://${Apis.HOST}/websocket';

  final StreamController _wsStreamController = StreamController.broadcast();

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
      _wsStreamController.sink.add(map);

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

        /// update total unread msg

        // int newUnread = ([rid] ?? 0);
        // newUnread += args.length;
        // _unreadMsg[rid] = newUnread;
        emit(state);
      }
    } catch (e) {
      print('--- ${e.toString()}');
    }
  }

  Stream get wsEventStream => _wsStreamController.stream;

  @override
  Future<void> close() {
    _wsStreamController.close();
    _channel.sink.close();
    return super.close();
  }
}
