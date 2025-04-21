import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../data/repositories/user_repository.dart';

// Events
abstract class OnboardingEvent extends Equatable {
  const OnboardingEvent();

  @override
  List<Object?> get props => [];
}

class UpdateBasicInfo extends OnboardingEvent {
  final double height;
  final double weight;

  const UpdateBasicInfo({
    required this.height,
    required this.weight,
  });

  @override
  List<Object> get props => [height, weight];
}

class UpdateFitnessGoals extends OnboardingEvent {
  final int fitnessLevel;

  const UpdateFitnessGoals({
    required this.fitnessLevel,
  });

  @override
  List<Object> get props => [fitnessLevel];
}

class UpdateTargetAreas extends OnboardingEvent {
  final List<String> targetAreas;

  const UpdateTargetAreas({
    required this.targetAreas,
  });

  @override
  List<Object> get props => [targetAreas];
}

class CompleteOnboarding extends OnboardingEvent {}

// States
abstract class OnboardingState extends Equatable {
  const OnboardingState();

  @override
  List<Object?> get props => [];
}

class OnboardingInitial extends OnboardingState {}

class OnboardingInProgress extends OnboardingState {
  final double? height;
  final double? weight;
  final int? fitnessLevel;
  final List<String> targetAreas;

  const OnboardingInProgress({
    this.height,
    this.weight,
    this.fitnessLevel,
    this.targetAreas = const [],
  });

  @override
  List<Object?> get props => [height, weight, fitnessLevel, targetAreas];

  OnboardingInProgress copyWith({
    double? height,
    double? weight,
    int? fitnessLevel,
    List<String>? targetAreas,
  }) {
    return OnboardingInProgress(
      height: height ?? this.height,
      weight: weight ?? this.weight,
      fitnessLevel: fitnessLevel ?? this.fitnessLevel,
      targetAreas: targetAreas ?? this.targetAreas,
    );
  }
}

class OnboardingLoading extends OnboardingState {}

class OnboardingCompleted extends OnboardingState {}

class OnboardingError extends OnboardingState {
  final String message;

  const OnboardingError(this.message);

  @override
  List<Object> get props => [message];
}

// Bloc
class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  final UserRepository userRepository;

  OnboardingBloc({required this.userRepository}) : super(OnboardingInitial()) {
    on<UpdateBasicInfo>(_onUpdateBasicInfo);
    on<UpdateFitnessGoals>(_onUpdateFitnessGoals);
    on<UpdateTargetAreas>(_onUpdateTargetAreas);
    on<CompleteOnboarding>(_onCompleteOnboarding);
  }

  Future<void> _onUpdateBasicInfo(
    UpdateBasicInfo event,
    Emitter<OnboardingState> emit,
  ) async {
    if (state is OnboardingInitial) {
      emit(OnboardingInProgress(
        height: event.height,
        weight: event.weight,
      ));
    } else if (state is OnboardingInProgress) {
      final currentState = state as OnboardingInProgress;
      emit(currentState.copyWith(
        height: event.height,
        weight: event.weight,
      ));
    }
  }

  Future<void> _onUpdateFitnessGoals(
    UpdateFitnessGoals event,
    Emitter<OnboardingState> emit,
  ) async {
    if (state is OnboardingInProgress) {
      final currentState = state as OnboardingInProgress;
      emit(currentState.copyWith(
        fitnessLevel: event.fitnessLevel,
      ));
    }
  }

  Future<void> _onUpdateTargetAreas(
    UpdateTargetAreas event,
    Emitter<OnboardingState> emit,
  ) async {
    if (state is OnboardingInProgress) {
      final currentState = state as OnboardingInProgress;
      emit(currentState.copyWith(
        targetAreas: event.targetAreas,
      ));
    }
  }

  Future<void> _onCompleteOnboarding(
    CompleteOnboarding event,
    Emitter<OnboardingState> emit,
  ) async {
    if (state is OnboardingInProgress) {
      final currentState = state as OnboardingInProgress;

      if (currentState.height == null ||
          currentState.weight == null ||
          currentState.fitnessLevel == null ||
          currentState.targetAreas.isEmpty) {
        emit(const OnboardingError(
            'Por favor, complete todas as informações necessárias.'));
        return;
      }

      emit(OnboardingLoading());

      try {
        final user = await userRepository.getCurrentUser();

        if (user != null) {
          await userRepository.updateUserProfile(
            userId: user.id,
            height: currentState.height,
            weight: currentState.weight,
            fitnessLevel: currentState.fitnessLevel,
            targetAreas: currentState.targetAreas,
          );

          emit(OnboardingCompleted());
        } else {
          emit(const OnboardingError('Usuário não encontrado.'));
        }
      } catch (e) {
        emit(OnboardingError(e.toString()));
      }
    }
  }
}
