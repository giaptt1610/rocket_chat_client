part of 'app_bloc.dart';

class AppState {
  final AuthResult? authResult;

  AppState({this.authResult});

  bool get isAuthenticated => authResult != null;

  AppState copyWith({AuthResult? authResult}) {
    return AppState(authResult: authResult ?? this.authResult);
  }
}
