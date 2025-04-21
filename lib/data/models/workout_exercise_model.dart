import 'package:equatable/equatable.dart';

class WorkoutExerciseModel extends Equatable {
  final String id;
  final String name;
  final String? description;
  final String? imageUrl;
  final int? durationSeconds;
  final int sets;
  final int reps;
  final String? instructions;

  const WorkoutExerciseModel({
    required this.id,
    required this.name,
    this.description,
    this.imageUrl,
    this.durationSeconds = 60,
    required this.sets,
    required this.reps,
    this.instructions,
  });

  factory WorkoutExerciseModel.fromJson(Map<String, dynamic> json) {
    return WorkoutExerciseModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      imageUrl: json['image_url'] as String?,
      durationSeconds: json['duration_seconds'] as int? ?? 60,
      sets: json['sets'] as int? ?? 3,
      reps: json['reps'] as int? ?? 10,
      instructions: json['instructions'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'image_url': imageUrl,
      'duration_seconds': durationSeconds,
      'sets': sets,
      'reps': reps,
      'instructions': instructions,
    };
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        imageUrl,
        durationSeconds,
        sets,
        reps,
        instructions,
      ];
}
