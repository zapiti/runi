import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/workout_model.dart';
import '../models/workout_exercise_model.dart';
import 'workout_repository.dart';

class SupabaseWorkoutRepository implements WorkoutRepository {
  final SupabaseClient _supabase;

  SupabaseWorkoutRepository(this._supabase);

  @override
  Future<List<WorkoutModel>> getWorkouts({
    WorkoutType? type,
    bool? isPremium,
    int? limit,
    int? offset,
  }) async {
    dynamic query = _supabase.from('workouts').select('*');

    if (type != null) {
      query = query.eq('type', type.name);
    }

    if (isPremium != null) {
      query = query.eq('is_premium', isPremium);
    }

    if (limit != null) {
      query = query.limit(limit);
    }

    if (offset != null) {
      query = query.range(offset, offset + (limit ?? 10) - 1);
    }

    final response = await query;
    return (response as List).map((workout) {
      return WorkoutModel.fromJson(Map<String, dynamic>.from(workout));
    }).toList();
  }

  @override
  Future<WorkoutModel> getWorkoutById(String id) async {
    final response =
        await _supabase.from('workouts').select('*').eq('id', id).single();

    return WorkoutModel.fromJson(Map<String, dynamic>.from(response));
  }

  @override
  Future<List<WorkoutModel>> getRecommendedWorkouts({
    required List<MuscleGroup> targetMuscles,
    required int fitnessLevel,
    int limit = 5,
  }) async {
    final response = await _supabase
        .from('workouts')
        .select('*')
        .contains('target_areas', targetMuscles.map((e) => e.name).toList())
        .eq('fitness_level', fitnessLevel)
        .limit(limit);

    return (response as List).map((workout) {
      return WorkoutModel.fromJson(Map<String, dynamic>.from(workout));
    }).toList();
  }

  @override
  Future<List<Exercise>> getExercisesByMuscleGroup(
      MuscleGroup muscleGroup) async {
    final response = await _supabase
        .from('exercises')
        .select()
        .contains('target_muscles', [muscleGroup.name]);

    return (response as List)
        .map((e) => Exercise.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  @override
  Future<WorkoutModel> createCustomWorkout({
    required String name,
    required String description,
    required WorkoutType type,
    required List<Exercise> exercises,
    String? thumbnailUrl,
  }) async {
    final workout = WorkoutModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      description: description,
      imageUrl: thumbnailUrl ?? 'https://via.placeholder.com/160x90',
      duration: exercises.fold(
        0,
        (total, exercise) => total + (exercise.durationSeconds ~/ 60),
      ),
      difficulty: 'custom',
      isPremium: false,
      targetAreas: exercises
          .expand((e) => e.targetMuscles)
          .map((e) => e.name)
          .toSet()
          .toList(),
      equipment: [],
      exercises: exercises
          .map((e) => WorkoutExerciseModel(
                id: e.id,
                name: e.name,
                description: e.description,
                imageUrl: e.videoUrl,
                durationSeconds: e.durationSeconds,
                sets: e.sets,
                reps: e.reps ?? 10,
                instructions: e.description,
              ))
          .toList(),
    );

    await _supabase.from('workouts').insert(workout.toJson());
    return workout;
  }

  @override
  Future<void> deleteWorkout(String id) async {
    await _supabase.from('workouts').delete().eq('id', id);
  }

  @override
  Future<void> updateWorkout(WorkoutModel workout) async {
    await _supabase
        .from('workouts')
        .update(workout.toJson())
        .eq('id', workout.id);
  }

  @override
  Stream<List<WorkoutModel>> workoutStream({
    WorkoutType? type,
    bool? isPremium,
  }) {
    final stream = _supabase.from('workouts').stream(primaryKey: ['id']);

    return stream.map((workouts) {
      return workouts
          .where((workout) {
            if (type != null && workout['type'] != type.name) return false;
            if (isPremium != null && workout['is_premium'] != isPremium)
              return false;
            return true;
          })
          .map((workout) =>
              WorkoutModel.fromJson(Map<String, dynamic>.from(workout)))
          .toList();
    });
  }
}
