import '../models/workout_model.dart';

abstract class WorkoutRepository {
  Future<List<WorkoutModel>> getWorkouts({
    WorkoutType? type,
    bool? isPremium,
    int? limit,
    int? offset,
  });

  Future<WorkoutModel> getWorkoutById(String id);

  Future<List<WorkoutModel>> getRecommendedWorkouts({
    required List<MuscleGroup> targetMuscles,
    required int fitnessLevel,
    int limit = 5,
  });

  Future<List<Exercise>> getExercisesByMuscleGroup(MuscleGroup muscleGroup);

  Future<WorkoutModel> createCustomWorkout({
    required String name,
    required String description,
    required WorkoutType type,
    required List<Exercise> exercises,
    String? thumbnailUrl,
  });

  Future<void> deleteWorkout(String id);

  Future<void> updateWorkout(WorkoutModel workout);

  Stream<List<WorkoutModel>> workoutStream({
    WorkoutType? type,
    bool? isPremium,
  });
}
