import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../data/models/user_model.dart';
import '../../../../data/repositories/user_repository.dart';

// Events
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class CheckAuthStatus extends AuthEvent {}

class Login extends AuthEvent {
  final String email;
  final String password;

  const Login({
    required this.email,
    required this.password,
  });

  @override
  List<Object> get props => [email, password];
}

class Register extends AuthEvent {
  final String email;
  final String password;
  final String name;

  const Register({
    required this.email,
    required this.password,
    required this.name,
  });

  @override
  List<Object> get props => [email, password, name];
}

class Logout extends AuthEvent {}

// States
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class Authenticated extends AuthState {
  final UserModel user;
  final bool hasCompletedOnboarding;

  const Authenticated({
    required this.user,
    this.hasCompletedOnboarding = false,
  });

  @override
  List<Object?> get props => [user, hasCompletedOnboarding];
}

class Unauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object> get props => [message];
}

// Bloc
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final UserRepository userRepository;

  AuthBloc({required this.userRepository}) : super(AuthInitial()) {
    on<CheckAuthStatus>(_onCheckAuthStatus);
    on<Login>(_onLogin);
    on<Register>(_onRegister);
    on<Logout>(_onLogout);
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatus event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await userRepository.getCurrentUser();
      if (user != null) {
        final hasCompletedOnboarding = user.height != null &&
            user.weight != null &&
            user.targetAreas.isNotEmpty;

        emit(Authenticated(
          user: user,
          hasCompletedOnboarding: hasCompletedOnboarding,
        ));
      } else {
        emit(Unauthenticated());
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onLogin(
    Login event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await userRepository.loginWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );

      final hasCompletedOnboarding = user.height != null &&
          user.weight != null &&
          user.targetAreas.isNotEmpty;

      emit(Authenticated(
        user: user,
        hasCompletedOnboarding: hasCompletedOnboarding,
      ));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onRegister(
    Register event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await userRepository.createUser(
        email: event.email,
        password: event.password,
        name: event.name,
      );

      emit(Authenticated(
        user: user,
        hasCompletedOnboarding: false,
      ));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onLogout(
    Logout event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await userRepository.logout();
      emit(Unauthenticated());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
}
