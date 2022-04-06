part of 'home_bloc.dart';

class HomeState {
  final bool loading;
  List<Room> listRooms = [];
  Map<String, int> unreadMsg = {};

  HomeState({
    this.loading = false,
    this.listRooms = const [],
    this.unreadMsg = const {},
  });

  HomeState copyWith({
    bool? newLoading,
    List<Room>? rooms,
    Map<String, int>? unreads,
  }) {
    return HomeState(
      loading: newLoading ?? loading,
      listRooms: rooms ?? listRooms,
      unreadMsg: unreads ?? unreadMsg,
    );
  }
}
