import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../data/models/workout_model.dart';
import '../../../../data/models/workout_exercise_model.dart';
import '../../../../data/repositories/user_repository.dart';

// Events
abstract class ActiveWorkoutEvent extends Equatable {
  const ActiveWorkoutEvent();

  @override
  List<Object?> get props => [];
}

class StartWorkout extends ActiveWorkoutEvent {}

class PauseWorkout extends ActiveWorkoutEvent {}

class ResumeWorkout extends ActiveWorkoutEvent {}

class CompleteExerciseSet extends ActiveWorkoutEvent {}

class SkipRest extends ActiveWorkoutEvent {}

class TimerTick extends ActiveWorkoutEvent {
  final int remainingSeconds;

  const TimerTick(this.remainingSeconds);

  @override
  List<Object?> get props => [remainingSeconds];
}

// States
abstract class ActiveWorkoutState extends Equatable {
  const ActiveWorkoutState();

  @override
  List<Object?> get props => [];
}

class WorkoutInitial extends ActiveWorkoutState {}

class WorkoutLoading extends ActiveWorkoutState {}

class WorkoutInProgress extends ActiveWorkoutState {
  final WorkoutModel workout;
  final int currentExerciseIndex;
  final int currentSet;
  final int remainingSeconds;
  final bool isResting;
  final bool isActive; // Whether the workout is active or paused

  WorkoutInProgress({
    required this.workout,
    required this.currentExerciseIndex,
    required this.currentSet,
    required this.remainingSeconds,
    required this.isResting,
    required this.isActive,
  });

  @override
  List<Object?> get props => [
        workout,
        currentExerciseIndex,
        currentSet,
        remainingSeconds,
        isResting,
        isActive,
      ];

  WorkoutExerciseModel get currentExercise =>
      workout.exercises[currentExerciseIndex];

  WorkoutInProgress copyWith({
    WorkoutModel? workout,
    int? currentExerciseIndex,
    int? currentSet,
    int? remainingSeconds,
    bool? isResting,
    bool? isActive,
  }) {
    return WorkoutInProgress(
      workout: workout ?? this.workout,
      currentExerciseIndex: currentExerciseIndex ?? this.currentExerciseIndex,
      currentSet: currentSet ?? this.currentSet,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      isResting: isResting ?? this.isResting,
      isActive: isActive ?? this.isActive,
    );
  }
}

class WorkoutCompleted extends ActiveWorkoutState {
  final WorkoutModel workout;

  const WorkoutCompleted(this.workout);

  @override
  List<Object?> get props => [workout];
}

class WorkoutError extends ActiveWorkoutState {
  final String message;

  const WorkoutError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class ActiveWorkoutBloc extends Bloc<ActiveWorkoutEvent, ActiveWorkoutState> {
  final WorkoutModel workout;
  final UserRepository?
      userRepository; // Optional: can be null for standalone usage

  Timer? _timer;
  static const int _restDuration = 30; // 30 seconds rest between sets

  ActiveWorkoutBloc({
    required this.workout,
    this.userRepository,
  }) : super(WorkoutInitial()) {
    on<StartWorkout>(_onStartWorkout);
    on<PauseWorkout>(_onPauseWorkout);
    on<ResumeWorkout>(_onResumeWorkout);
    on<CompleteExerciseSet>(_onCompleteExerciseSet);
    on<SkipRest>(_onSkipRest);
    on<TimerTick>(_onTimerTick);
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        final currentState = state;
        if (currentState is WorkoutInProgress) {
          if (currentState.remainingSeconds > 0) {
            add(TimerTick(currentState.remainingSeconds - 1));
          } else {
            // Time's up
            if (currentState.isResting) {
              // Rest period finished, move to the next exercise or set
              _moveToNextExerciseOrSet(currentState);
            } else {
              // Exercise set finished, start rest period
              add(CompleteExerciseSet());
            }
          }
        }
      },
    );
  }

  void _onStartWorkout(StartWorkout event, Emitter<ActiveWorkoutState> emit) {
    emit(WorkoutLoading());

    if (workout.exercises.isEmpty) {
      emit(const WorkoutError('Este treino não possui exercícios.'));
      return;
    }

    final initialExercise = workout.exercises.first;
    final exerciseDuration = initialExercise.durationSeconds ??
        60; // Default to 60 seconds if not specified

    emit(WorkoutInProgress(
      workout: workout,
      currentExerciseIndex: 0,
      currentSet: 0,
      remainingSeconds: exerciseDuration,
      isResting: false,
      isActive: true,
    ));

    _startTimer();
  }

  void _onPauseWorkout(PauseWorkout event, Emitter<ActiveWorkoutState> emit) {
    _timer?.cancel();

    final currentState = state;
    if (currentState is WorkoutInProgress) {
      emit(currentState.copyWith(isActive: false));
    }
  }

  void _onResumeWorkout(ResumeWorkout event, Emitter<ActiveWorkoutState> emit) {
    final currentState = state;
    if (currentState is WorkoutInProgress) {
      emit(currentState.copyWith(isActive: true));
      _startTimer();
    }
  }

  void _onCompleteExerciseSet(
      CompleteExerciseSet event, Emitter<ActiveWorkoutState> emit) {
    final currentState = state;
    if (currentState is WorkoutInProgress) {
      if (currentState.isResting) {
        // Already resting, move to next exercise
        _moveToNextExerciseOrSet(currentState);
      } else {
        // Start rest period
        emit(currentState.copyWith(
          isResting: true,
          remainingSeconds: _restDuration,
        ));
      }
    }
  }

  void _onSkipRest(SkipRest event, Emitter<ActiveWorkoutState> emit) {
    final currentState = state;
    if (currentState is WorkoutInProgress && currentState.isResting) {
      _moveToNextExerciseOrSet(currentState);
    }
  }

  void _onTimerTick(TimerTick event, Emitter<ActiveWorkoutState> emit) {
    final currentState = state;
    if (currentState is WorkoutInProgress) {
      emit(currentState.copyWith(remainingSeconds: event.remainingSeconds));
    }
  }

  void _moveToNextExerciseOrSet(WorkoutInProgress currentState) {
    // Check if we need to move to the next set or next exercise
    final currentExercise = currentState.currentExercise;
    final currentSet = currentState.currentSet;

    if (currentSet < currentExercise.sets - 1) {
      // Move to the next set of the same exercise
      emit(currentState.copyWith(
        currentSet: currentSet + 1,
        isResting: false,
        remainingSeconds: currentExercise.durationSeconds ?? 60,
      ));
    } else {
      // Move to the next exercise
      final nextExerciseIndex = currentState.currentExerciseIndex + 1;

      if (nextExerciseIndex < currentState.workout.exercises.length) {
        // There's another exercise
        final nextExercise = currentState.workout.exercises[nextExerciseIndex];

        emit(currentState.copyWith(
          currentExerciseIndex: nextExerciseIndex,
          currentSet: 0,
          isResting: false,
          remainingSeconds: nextExercise.durationSeconds ?? 60,
        ));
      } else {
        // Workout completed
        _workoutCompleted(currentState.workout);
      }
    }
  }

  void _workoutCompleted(WorkoutModel workout) async {
    _timer?.cancel();

    if (userRepository != null) {
      try {
        // Update user stats
        final user = await userRepository?.getCurrentUser();
        if (user != null) {
          await userRepository?.updateLastWorkout(user.id, DateTime.now());
        }
      } catch (e) {
        // Ignore errors in stats tracking
      }
    }

    emit(WorkoutCompleted(workout));
  }
}
