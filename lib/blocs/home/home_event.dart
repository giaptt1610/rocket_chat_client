part of 'home_bloc.dart';

@immutable
abstract class HomeEvent {}

class LoadListRoomEvent extends HomeEvent {
  final String authToken;
  final String userId;
  LoadListRoomEvent(this.authToken, this.userId);
}

class ChannelChangedEvent extends HomeEvent {
  final List args;
  ChannelChangedEvent(this.args);
}

class ClearUnreadMsgEvent extends HomeEvent {
  final String roomId;
  ClearUnreadMsgEvent(this.roomId);
}
