part of 'home_bloc.dart';

@immutable
abstract class HomeEvent {}

class LoadListRoomEvent extends HomeEvent {
  final String authToken;
  final String userId;
  LoadListRoomEvent(this.authToken, this.userId);
}
