import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../data/models/workout_model.dart';
import '../../../../data/repositories/workout_repository.dart';

// Events
abstract class WorkoutEvent extends Equatable {
  const WorkoutEvent();

  @override
  List<Object?> get props => [];
}

class LoadWorkouts extends WorkoutEvent {
  final WorkoutType? type;
  final bool? isPremium;

  const LoadWorkouts({this.type, this.isPremium});

  @override
  List<Object?> get props => [type, isPremium];
}

class LoadWorkoutDetails extends WorkoutEvent {
  final String workoutId;

  const LoadWorkoutDetails(this.workoutId);

  @override
  List<Object?> get props => [workoutId];
}

class StartWorkout extends WorkoutEvent {
  final String workoutId;

  const StartWorkout(this.workoutId);

  @override
  List<Object?> get props => [workoutId];
}

class CompleteWorkout extends WorkoutEvent {
  final String workoutId;
  final int durationMinutes;
  final int caloriesBurned;

  const CompleteWorkout({
    required this.workoutId,
    required this.durationMinutes,
    required this.caloriesBurned,
  });

  @override
  List<Object?> get props => [workoutId, durationMinutes, caloriesBurned];
}

// States
abstract class WorkoutState extends Equatable {
  const WorkoutState();

  @override
  List<Object?> get props => [];
}

class WorkoutInitial extends WorkoutState {}

class WorkoutLoading extends WorkoutState {}

class WorkoutsLoaded extends WorkoutState {
  final List<WorkoutModel> workouts;

  const WorkoutsLoaded(this.workouts);

  @override
  List<Object?> get props => [workouts];
}

class WorkoutDetailsLoaded extends WorkoutState {
  final WorkoutModel workout;

  const WorkoutDetailsLoaded(this.workout);

  @override
  List<Object?> get props => [workout];
}

class WorkoutInProgress extends WorkoutState {
  final WorkoutModel workout;
  final int currentExerciseIndex;
  final DateTime startTime;

  const WorkoutInProgress({
    required this.workout,
    required this.currentExerciseIndex,
    required this.startTime,
  });

  @override
  List<Object?> get props => [workout, currentExerciseIndex, startTime];
}

class WorkoutComplete extends WorkoutState {
  final WorkoutModel workout;
  final int durationMinutes;
  final int caloriesBurned;

  const WorkoutComplete({
    required this.workout,
    required this.durationMinutes,
    required this.caloriesBurned,
  });

  @override
  List<Object?> get props => [workout, durationMinutes, caloriesBurned];
}

class WorkoutError extends WorkoutState {
  final String message;

  const WorkoutError(this.message);

  @override
  List<Object?> get props => [message];
}

// Bloc
class WorkoutBloc extends Bloc<WorkoutEvent, WorkoutState> {
  final WorkoutRepository _workoutRepository;

  WorkoutBloc(this._workoutRepository) : super(WorkoutInitial()) {
    on<LoadWorkouts>(_onLoadWorkouts);
    on<LoadWorkoutDetails>(_onLoadWorkoutDetails);
    on<StartWorkout>(_onStartWorkout);
    on<CompleteWorkout>(_onCompleteWorkout);
  }

  Future<void> _onLoadWorkouts(
    LoadWorkouts event,
    Emitter<WorkoutState> emit,
  ) async {
    emit(WorkoutLoading());
    try {
      final workouts = await _workoutRepository.getWorkouts(
        type: event.type,
        isPremium: event.isPremium,
      );
      emit(WorkoutsLoaded(workouts));
    } catch (e) {
      emit(WorkoutError(e.toString()));
    }
  }

  Future<void> _onLoadWorkoutDetails(
    LoadWorkoutDetails event,
    Emitter<WorkoutState> emit,
  ) async {
    emit(WorkoutLoading());
    try {
      final workout = await _workoutRepository.getWorkoutById(event.workoutId);
      emit(WorkoutDetailsLoaded(workout));
    } catch (e) {
      emit(WorkoutError(e.toString()));
    }
  }

  Future<void> _onStartWorkout(
    StartWorkout event,
    Emitter<WorkoutState> emit,
  ) async {
    emit(WorkoutLoading());
    try {
      final workout = await _workoutRepository.getWorkoutById(event.workoutId);
      emit(WorkoutInProgress(
        workout: workout,
        currentExerciseIndex: 0,
        startTime: DateTime.now(),
      ));
    } catch (e) {
      emit(WorkoutError(e.toString()));
    }
  }

  Future<void> _onCompleteWorkout(
    CompleteWorkout event,
    Emitter<WorkoutState> emit,
  ) async {
    if (state is WorkoutInProgress) {
      final currentState = state as WorkoutInProgress;
      emit(WorkoutComplete(
        workout: currentState.workout,
        durationMinutes: event.durationMinutes,
        caloriesBurned: event.caloriesBurned,
      ));
    }
  }
}
