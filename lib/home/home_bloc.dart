import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:websocket_channel/app/app_bloc.dart';

import '../apis.dart';
import '../room.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final AppBloc appBloc;

  HomeBloc(this.appBloc) : super(HomeState()) {
    on<HomeEvent>((event, emit) {
      // TODO: implement event handler
    });

    on<LoadListRoomEvent>((event, emit) async {
      emit(state.copyWith(newLoading: true));

      final listRooms = await Apis.getListRoom(event.authToken, event.userId);
      appBloc.add(WsSubscribeRoomsEvent(listRooms));
      emit(state.copyWith(newLoading: false, rooms: listRooms));
    });

    on<ChannelChangedEvent>((event, emit) {
      Map<String, int> _unreads = {...state.unreadMsg};
      event.args.forEach((element) {
        final map = element as Map<String, dynamic>;

        if (map['rid'] != null) {
          int unread = state.unreadMsg[map['rid']] ?? 0;
          unread += event.args.length;
          _unreads[map['rid']] = unread;
        }
      });

      emit(state.copyWith(unreads: _unreads));
    });

    on<ClearUnreadMsgEvent>((event, emit) {
      Map<String, int> _unreads = {...state.unreadMsg};
      if (_unreads[event.roomId] != null) {
        _unreads[event.roomId] = 0;
      }

      emit(state.copyWith(unreads: _unreads));
    });
  }
}
