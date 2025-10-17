part of 'auth_bloc.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}
class AuthInitializeEvent extends AuthEvent {}

class LoginEvent extends AuthEvent {
  final String username;
  final String password;

  LoginEvent({required this.username, required this.password});
}

class LogoutEvent extends AuthEvent {}

class RefreshTokenEvent extends AuthEvent {}

class _ProactiveRefreshEvent extends AuthEvent {}