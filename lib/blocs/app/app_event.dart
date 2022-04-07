part of 'app_bloc.dart';

@immutable
abstract class AppEvent {}

class AuthenticatedEvent extends AppEvent {
  final AuthResult authResult;
  AuthenticatedEvent(this.authResult);
}

class WsLoginEvent extends AppEvent {
  final String authToken;
  WsLoginEvent(this.authToken);
}

class WsSubscribeRoomsEvent extends AppEvent {
  final List<Room> rooms;
  WsSubscribeRoomsEvent(this.rooms);
}

class WsUnsubscribeRoomsEvent extends AppEvent {
  final List<Room> rooms;
  WsUnsubscribeRoomsEvent(this.rooms);
}
