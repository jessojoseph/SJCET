import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../services/database_service.dart';

// Events
abstract class AuthEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class CheckAuthStatusEvent extends AuthEvent {}

class RegisterUserEvent extends AuthEvent {
  final UserModel user;
  RegisterUserEvent(this.user);

  @override
  List<Object?> get props => [user];
}

class LoginUserEvent extends AuthEvent {
  final String email;
  final String password;
  LoginUserEvent(this.email, this.password);

  @override
  List<Object?> get props => [email, password];
}

class ResetPasswordEvent extends AuthEvent {
  final String email;
  final String newPassword;
  ResetPasswordEvent(this.email, this.newPassword);

  @override
  List<Object?> get props => [email, newPassword];
}

class FindUserEvent extends AuthEvent {
  final String email;
  FindUserEvent(this.email);

  @override
  List<Object?> get props => [email];
}

class LogoutEvent extends AuthEvent {}

class UpdateStudyTimeEvent extends AuthEvent {
  final int additionalSeconds;
  UpdateStudyTimeEvent(this.additionalSeconds);

  @override
  List<Object?> get props => [additionalSeconds];
}

// States
abstract class AuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  final UserModel user;
  AuthSuccess(this.user);

  @override
  List<Object?> get props => [user];
}

class UserFound extends AuthState {
  final UserModel user;
  UserFound(this.user);

  @override
  List<Object?> get props => [user];
}

class RegisterSuccess extends AuthState {}

class PasswordResetSuccess extends AuthState {}

class AuthFailed extends AuthState {
  final String message;
  AuthFailed(this.message);

  @override
  List<Object?> get props => [message];
}

class Unauthenticated extends AuthState {}

// Bloc
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final DatabaseService _databaseService = DatabaseService();
  static const String _userKey = 'logged_in_user_id';

  AuthBloc() : super(AuthInitial()) {
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
    on<RegisterUserEvent>(_onRegisterUser);
    on<LoginUserEvent>(_onLoginUser);
    on<ResetPasswordEvent>(_onResetPassword);
    on<FindUserEvent>(_onFindUser);
    on<LogoutEvent>(_onLogout);
    on<UpdateStudyTimeEvent>(_onUpdateStudyTime);
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatusEvent event,
    Emitter<AuthState> emit,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt(_userKey);

    if (userId != null) {
      final user = await _databaseService.getUserById(userId);
      if (user != null) {
        emit(AuthSuccess(user));
        return;
      }
    }
    emit(Unauthenticated());
  }

  Future<void> _onFindUser(FindUserEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await _databaseService.getUserByEmail(event.email);
      if (user != null) {
        emit(UserFound(user));
      } else {
        emit(AuthFailed('No account found with this email.'));
      }
    } catch (e) {
      log('Error finding user: $e');
      emit(AuthFailed('An error occurred while searching for the account.'));
    }
  }

  Future<void> _onRegisterUser(
    RegisterUserEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final result = await _databaseService.registerUser(event.user);
      if (result != -1) {
        log('User registered successfully');
        emit(RegisterSuccess());
      } else {
        emit(AuthFailed('Registration failed. Email might already be in use.'));
      }
    } catch (e) {
      log('Error registering user: $e');
      emit(AuthFailed('An error occurred during registration.'));
    }
  }

  Future<void> _onLoginUser(
    LoginUserEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await _databaseService.loginUser(
        event.email,
        event.password,
      );
      if (user != null) {
        log('Login successful for: ${user.name}');

        // Save session
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt(_userKey, user.id!);

        emit(AuthSuccess(user));
      } else {
        emit(AuthFailed('Invalid email or password.'));
      }
    } catch (e) {
      log('Error during login: $e');
      emit(AuthFailed('An error occurred during login.'));
    }
  }

  Future<void> _onResetPassword(
    ResetPasswordEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final result = await _databaseService.updatePassword(
        event.email,
        event.newPassword,
      );
      if (result > 0) {
        log('Password reset successful');
        emit(PasswordResetSuccess());
      } else {
        emit(AuthFailed('Failed to reset password.'));
      }
    } catch (e) {
      log('Error resetting password: $e');
      emit(AuthFailed('An error occurred during password reset.'));
    }
  }

  Future<void> _onLogout(LogoutEvent event, Emitter<AuthState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
    emit(Unauthenticated());
  }

  Future<void> _onUpdateStudyTime(
    UpdateStudyTimeEvent event,
    Emitter<AuthState> emit,
  ) async {
    if (state is AuthSuccess) {
      final currentUser = (state as AuthSuccess).user;
      await _databaseService.updateStudyTime(
        currentUser.id!,
        event.additionalSeconds,
      );
      // Re-fetch user to update state
      final updatedUser = await _databaseService.getUserById(currentUser.id!);
      if (updatedUser != null) {
        emit(AuthSuccess(updatedUser));
      }
    }
  }
}
