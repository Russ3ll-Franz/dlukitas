part of 'app_bloc.dart';

enum AppStatus { authenticated, unauthenticated }

extension AppStatusX on AppStatus {
  bool get isAuthenticated => this == AppStatus.authenticated;
}

class AppState extends Equatable {
  const AppState.authenticated(this.user) : status = AppStatus.authenticated;

  const AppState.unauthenticated()
      : user = User.empty,
        status = AppStatus.unauthenticated;

  final User user;
  final AppStatus status;

  @override
  List<Object> get props => [user, status];
}
