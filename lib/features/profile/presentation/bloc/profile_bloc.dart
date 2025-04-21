import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../data/models/user_model.dart';
import '../../../../data/repositories/user_repository.dart';

// Events
abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class LoadProfile extends ProfileEvent {}

class EditProfile extends ProfileEvent {}

class ChangeProfilePhoto extends ProfileEvent {}

class SubscribeToPremium extends ProfileEvent {}

class LogoutRequested extends ProfileEvent {}

class UpdateUserInfo extends ProfileEvent {
  final String? name;
  final double? height;
  final double? weight;
  final int? fitnessLevel;

  const UpdateUserInfo({
    this.name,
    this.height,
    this.weight,
    this.fitnessLevel,
  });

  @override
  List<Object?> get props => [name, height, weight, fitnessLevel];
}

// States
abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final UserModel user;

  const ProfileLoaded(this.user);

  @override
  List<Object?> get props => [user];
}

class ProfileError extends ProfileState {
  final String message;

  const ProfileError(this.message);

  @override
  List<Object?> get props => [message];
}

// Bloc
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final UserRepository userRepository;

  ProfileBloc({required this.userRepository}) : super(ProfileInitial()) {
    on<LoadProfile>(_onLoadProfile);
    on<EditProfile>(_onEditProfile);
    on<ChangeProfilePhoto>(_onChangeProfilePhoto);
    on<UpdateUserInfo>(_onUpdateUserInfo);
    on<SubscribeToPremium>(_onSubscribeToPremium);
    on<LogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onLoadProfile(
      LoadProfile event, Emitter<ProfileState> emit) async {
    emit(ProfileLoading());
    try {
      final user = await userRepository.getCurrentUser();
      if (user != null) {
        emit(ProfileLoaded(user));
      } else {
        emit(const ProfileError('Usuário não encontrado'));
      }
    } catch (e) {
      emit(ProfileError('Erro ao carregar perfil: $e'));
    }
  }

  void _onEditProfile(EditProfile event, Emitter<ProfileState> emit) {
    // This would typically navigate to an edit profile screen
    // For now, we'll just acknowledge the event
  }

  void _onChangeProfilePhoto(
      ChangeProfilePhoto event, Emitter<ProfileState> emit) {
    // This would typically launch image picker and update profile photo
    // For now, we'll just acknowledge the event
  }

  Future<void> _onUpdateUserInfo(
      UpdateUserInfo event, Emitter<ProfileState> emit) async {
    emit(ProfileLoading());
    try {
      final currentState = state;
      if (currentState is ProfileLoaded) {
        final updatedUser = await userRepository.updateUserProfile(
          userId: currentState.user.id,
          name: event.name,
          height: event.height,
          weight: event.weight,
          fitnessLevel: event.fitnessLevel,
        );

        emit(ProfileLoaded(updatedUser));
      }
    } catch (e) {
      emit(ProfileError('Erro ao atualizar perfil: $e'));
    }
  }

  Future<void> _onSubscribeToPremium(
      SubscribeToPremium event, Emitter<ProfileState> emit) async {
    // This would typically launch the payment flow
    // For now, we'll just simulate a premium status update
    try {
      final currentState = state;
      if (currentState is ProfileLoaded) {
        final isPremium = !currentState.user.isPremium;
        await userRepository.togglePremiumStatus(
            currentState.user.id, isPremium);

        // Reload user data
        add(LoadProfile());
      }
    } catch (e) {
      emit(ProfileError('Erro ao atualizar status premium: $e'));
    }
  }

  Future<void> _onLogoutRequested(
      LogoutRequested event, Emitter<ProfileState> emit) async {
    try {
      await userRepository.logout();
      // Note: Navigation to login screen would typically be handled by the AuthBloc
    } catch (e) {
      emit(ProfileError('Erro ao fazer logout: $e'));
    }
  }
}
