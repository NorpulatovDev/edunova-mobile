
import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/auth_models.dart';
import '../../data/repositories/auth_repository.dart';
import 'package:equatable/equatable.dart';
part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepositoryImpl _authRepository;
  Timer? _refreshTimer;

  AuthBloc(this._authRepository) : super(AuthInitialState()) {
    on<AuthInitializeEvent>(_onInitialize);
    on<LoginEvent>(_onLogin);
    on<LogoutEvent>(_onLogout);
    on<RefreshTokenEvent>(_onRefreshToken);
    on<_ProactiveRefreshEvent>(_onProactiveRefresh);
  }

  @override
  Future<void> close() {
    _refreshTimer?.cancel();
    return super.close();
  }

  void _startProactiveRefresh() {
    _refreshTimer?.cancel();
    // Refresh token every 10 minutes (before 15-minute expiration)
    _refreshTimer = Timer.periodic(const Duration(minutes: 10), (timer) {
      if (!isClosed) {
        add(_ProactiveRefreshEvent());
      }
    });
  }

  void _stopProactiveRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }

  void _onInitialize(AuthInitializeEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoadingState());
    
    if (_authRepository.isAuthenticated()) {
      try {
        // Try to refresh token to verify it's still valid
        final refreshToken = _authRepository.getRefreshToken();
        if (refreshToken != null) {
          await _authRepository.refreshToken(refreshToken);
          final accessToken = _authRepository.getAccessToken();
          emit(AuthenticatedState(accessToken: accessToken!));
          _startProactiveRefresh();
        } else {
          emit(UnauthenticatedState());
        }
      } catch (e) {
        emit(UnauthenticatedState());
      }
    } else {
      emit(UnauthenticatedState());
    }
  }

  void _onLogin(LoginEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoadingState());
    
    try {
      final request = LoginRequest(username: event.username, password: event.password);
      final response = await _authRepository.login(request);
      emit(AuthenticatedState(accessToken: response.accessToken));
      _startProactiveRefresh();
    } catch (e) {
      emit(AuthErrorState(message: e.toString().replaceFirst('Exception: ', '')));
    }
  }

  void _onLogout(LogoutEvent event, Emitter<AuthState> emit) async {
    _stopProactiveRefresh();
    try {
      await _authRepository.logout();
    } catch (e) {
      // Continue with logout even if server request fails
      print('Logout error: $e');
    }
    emit(UnauthenticatedState());
  }

  void _onRefreshToken(RefreshTokenEvent event, Emitter<AuthState> emit) async {
    try {
      final refreshToken = _authRepository.getRefreshToken();
      if (refreshToken != null) {
        final response = await _authRepository.refreshToken(refreshToken);
        emit(AuthenticatedState(accessToken: response.accessToken));
      } else {
        _stopProactiveRefresh();
        emit(UnauthenticatedState());
      }
    } catch (e) {
      _stopProactiveRefresh();
      emit(UnauthenticatedState());
    }
  }

  void _onProactiveRefresh(_ProactiveRefreshEvent event, Emitter<AuthState> emit) async {
    // Only refresh if we're currently authenticated
    if (state is AuthenticatedState) {
      try {
        final refreshToken = _authRepository.getRefreshToken();
        if (refreshToken != null) {
          await _authRepository.refreshToken(refreshToken);
          final accessToken = _authRepository.getAccessToken();
          emit(AuthenticatedState(accessToken: accessToken!));
        } else {
          _stopProactiveRefresh();
          emit(UnauthenticatedState());
        }
      } catch (e) {
        // If proactive refresh fails, stop the timer and logout
        _stopProactiveRefresh();
        emit(UnauthenticatedState());
      }
    }
  }
}
