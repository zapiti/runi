import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../data/models/workout_model.dart';
import '../../../../data/repositories/workout_repository.dart';

// Events
abstract class DashboardEvent extends Equatable {
  const DashboardEvent();

  @override
  List<Object?> get props => [];
}

class LoadDashboard extends DashboardEvent {}

class RefreshDashboard extends DashboardEvent {}

// States
abstract class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object?> get props => [];
}

class DashboardInitial extends DashboardState {}

class DashboardLoading extends DashboardState {}

class DashboardLoaded extends DashboardState {
  final List<WorkoutModel> recommendedWorkouts;
  final int totalWorkoutsThisMonth;
  final int totalCaloriesBurned;
  final int totalMinutesWorkedOut;
  final List<WorkoutActivity> recentActivities;

  const DashboardLoaded({
    required this.recommendedWorkouts,
    required this.totalWorkoutsThisMonth,
    required this.totalCaloriesBurned,
    required this.totalMinutesWorkedOut,
    required this.recentActivities,
  });

  @override
  List<Object?> get props => [
        recommendedWorkouts,
        totalWorkoutsThisMonth,
        totalCaloriesBurned,
        totalMinutesWorkedOut,
        recentActivities,
      ];
}

class DashboardError extends DashboardState {
  final String message;

  const DashboardError(this.message);

  @override
  List<Object?> get props => [message];
}

// Models
class WorkoutActivity {
  final String title;
  final String subtitle;
  final DateTime timestamp;
  final int caloriesBurned;
  final int durationMinutes;

  const WorkoutActivity({
    required this.title,
    required this.subtitle,
    required this.timestamp,
    required this.caloriesBurned,
    required this.durationMinutes,
  });
}

// Bloc
class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final WorkoutRepository _workoutRepository;

  DashboardBloc(this._workoutRepository) : super(DashboardInitial()) {
    on<LoadDashboard>(_onLoadDashboard);
    on<RefreshDashboard>(_onRefreshDashboard);
  }

  Future<void> _onLoadDashboard(
    LoadDashboard event,
    Emitter<DashboardState> emit,
  ) async {
    emit(DashboardLoading());
    try {
      // Carregar treinos recomendados
      final recommendedWorkouts = await _workoutRepository.getWorkouts();

      // TODO: Implementar lógica para buscar estatísticas reais do usuário
      // Por enquanto, usando dados mockados
      emit(
        DashboardLoaded(
          recommendedWorkouts: recommendedWorkouts,
          totalWorkoutsThisMonth: 12,
          totalCaloriesBurned: 3200,
          totalMinutesWorkedOut: 320,
          recentActivities: [
            WorkoutActivity(
              title: 'Treino Completo',
              subtitle: 'Core + Cardio',
              timestamp: DateTime.now().subtract(const Duration(hours: 2)),
              caloriesBurned: 150,
              durationMinutes: 25,
            ),
            WorkoutActivity(
              title: 'Treino de Força',
              subtitle: 'Braços + Costas',
              timestamp: DateTime.now().subtract(const Duration(days: 1)),
              caloriesBurned: 200,
              durationMinutes: 35,
            ),
            WorkoutActivity(
              title: 'Cardio Intenso',
              subtitle: 'HIIT',
              timestamp: DateTime.now().subtract(const Duration(days: 2)),
              caloriesBurned: 300,
              durationMinutes: 45,
            ),
          ],
        ),
      );
    } catch (e) {
      emit(DashboardError(e.toString()));
    }
  }

  Future<void> _onRefreshDashboard(
    RefreshDashboard event,
    Emitter<DashboardState> emit,
  ) async {
    try {
      if (state is DashboardLoaded) {
        final currentState = state as DashboardLoaded;
        // Recarregar treinos recomendados
        final recommendedWorkouts = await _workoutRepository.getWorkouts();
        emit(
          DashboardLoaded(
            recommendedWorkouts: recommendedWorkouts,
            totalWorkoutsThisMonth: currentState.totalWorkoutsThisMonth,
            totalCaloriesBurned: currentState.totalCaloriesBurned,
            totalMinutesWorkedOut: currentState.totalMinutesWorkedOut,
            recentActivities: currentState.recentActivities,
          ),
        );
      }
    } catch (e) {
      // Manter o estado anterior em caso de erro no refresh
      if (state is DashboardLoaded) {
        emit(state);
      } else {
        emit(DashboardError(e.toString()));
      }
    }
  }
}
