import 'package:equatable/equatable.dart';
import 'workout_exercise_model.dart';

enum WorkoutType { core, cardio, strength, flexibility }

enum MuscleGroup { core, shoulders, back, chest, arms, legs, fullBody }

class Exercise extends Equatable {
  final String id;
  final String name;
  final String description;
  final String videoUrl;
  final List<MuscleGroup> targetMuscles;
  final int durationSeconds;
  final int sets;
  final int? reps;
  final double? weight;
  final bool requiresEquipment;

  const Exercise({
    required this.id,
    required this.name,
    required this.description,
    required this.videoUrl,
    required this.targetMuscles,
    required this.durationSeconds,
    required this.sets,
    this.reps,
    this.weight,
    this.requiresEquipment = false,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      videoUrl: json['video_url'] as String,
      targetMuscles: (json['target_muscles'] as List<dynamic>)
          .map((e) => MuscleGroup.values.firstWhere((m) => m.name == e))
          .toList(),
      durationSeconds: json['duration_seconds'] as int,
      sets: json['sets'] as int,
      reps: json['reps'] as int?,
      weight: json['weight'] as double?,
      requiresEquipment: json['requires_equipment'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'video_url': videoUrl,
      'target_muscles': targetMuscles.map((e) => e.name).toList(),
      'duration_seconds': durationSeconds,
      'sets': sets,
      'reps': reps,
      'weight': weight,
      'requires_equipment': requiresEquipment,
    };
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        videoUrl,
        targetMuscles,
        durationSeconds,
        sets,
        reps,
        weight,
        requiresEquipment,
      ];
}

class WorkoutModel extends Equatable {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final int duration; // in minutes
  final String difficulty;
  final bool isPremium;
  final List<String> targetAreas;
  final List<String> equipment;
  final List<WorkoutExerciseModel> exercises;

  const WorkoutModel({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.duration,
    required this.difficulty,
    required this.isPremium,
    required this.targetAreas,
    required this.equipment,
    required this.exercises,
  });

  factory WorkoutModel.fromJson(Map<String, dynamic> json) {
    return WorkoutModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      imageUrl: json['image_url'] as String,
      duration: json['duration'] as int,
      difficulty: json['difficulty'] as String,
      isPremium: json['is_premium'] as bool,
      targetAreas: List<String>.from(json['target_areas'] as List),
      equipment: List<String>.from(json['equipment'] as List),
      exercises: (json['exercises'] as List)
          .map((e) => WorkoutExerciseModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'image_url': imageUrl,
      'duration': duration,
      'difficulty': difficulty,
      'is_premium': isPremium,
      'target_areas': targetAreas,
      'equipment': equipment,
      'exercises': exercises.map((e) => e.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        imageUrl,
        duration,
        difficulty,
        isPremium,
        targetAreas,
        equipment,
        exercises,
      ];
}
