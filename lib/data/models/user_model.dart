import 'package:equatable/equatable.dart';

enum FitnessLevel { beginner, intermediate, advanced }

enum WeightGoal { lose, maintain, gain }

enum TrainingIntensity { slow, normal, fast }

class UserModel extends Equatable {
  final String id;
  final String email;
  final String name;
  final double? height; // in cm
  final double? weight; // in kg
  final int fitnessLevel; // 1 = beginner, 2 = intermediate, 3 = advanced
  final List<String> targetAreas;
  final bool isPremium;
  final String? profileImageUrl;
  final DateTime registrationDate;
  final DateTime lastLogin;

  // Fitness tracking statistics
  final int? totalWorkouts;
  final int? totalMinutes;
  final int? streakDays;
  final int? totalCaloriesBurned;
  final DateTime? lastWorkout;

  const UserModel({
    required this.id,
    required this.email,
    required this.name,
    this.height,
    this.weight,
    this.fitnessLevel = 1,
    this.targetAreas = const [],
    this.isPremium = false,
    this.profileImageUrl,
    required this.registrationDate,
    required this.lastLogin,
    this.totalWorkouts = 0,
    this.totalMinutes = 0,
    this.streakDays = 0,
    this.totalCaloriesBurned = 0,
    this.lastWorkout,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      height: json['height'] as double?,
      weight: json['weight'] as double?,
      fitnessLevel: json['fitness_level'] as int? ?? 1,
      targetAreas: json['target_areas'] != null
          ? List<String>.from(json['target_areas'] as List)
          : const [],
      isPremium: json['is_premium'] as bool? ?? false,
      profileImageUrl: json['profile_image_url'] as String?,
      registrationDate: json['registration_date'] != null
          ? DateTime.parse(json['registration_date'] as String)
          : DateTime.now(),
      lastLogin: json['last_login'] != null
          ? DateTime.parse(json['last_login'] as String)
          : DateTime.now(),
      totalWorkouts: json['total_workouts'] as int?,
      totalMinutes: json['total_minutes'] as int?,
      streakDays: json['streak_days'] as int?,
      totalCaloriesBurned: json['total_calories_burned'] as int?,
      lastWorkout: json['last_workout'] != null
          ? DateTime.parse(json['last_workout'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'height': height,
      'weight': weight,
      'fitness_level': fitnessLevel,
      'target_areas': targetAreas,
      'is_premium': isPremium,
      'profile_image_url': profileImageUrl,
      'registration_date': registrationDate.toIso8601String(),
      'last_login': lastLogin.toIso8601String(),
      'total_workouts': totalWorkouts,
      'total_minutes': totalMinutes,
      'streak_days': streakDays,
      'total_calories_burned': totalCaloriesBurned,
      'last_workout': lastWorkout?.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    double? height,
    double? weight,
    int? fitnessLevel,
    List<String>? targetAreas,
    bool? isPremium,
    String? profileImageUrl,
    DateTime? registrationDate,
    DateTime? lastLogin,
    int? totalWorkouts,
    int? totalMinutes,
    int? streakDays,
    int? totalCaloriesBurned,
    DateTime? lastWorkout,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      fitnessLevel: fitnessLevel ?? this.fitnessLevel,
      targetAreas: targetAreas ?? this.targetAreas,
      isPremium: isPremium ?? this.isPremium,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      registrationDate: registrationDate ?? this.registrationDate,
      lastLogin: lastLogin ?? this.lastLogin,
      totalWorkouts: totalWorkouts ?? this.totalWorkouts,
      totalMinutes: totalMinutes ?? this.totalMinutes,
      streakDays: streakDays ?? this.streakDays,
      totalCaloriesBurned: totalCaloriesBurned ?? this.totalCaloriesBurned,
      lastWorkout: lastWorkout ?? this.lastWorkout,
    );
  }

  @override
  List<Object?> get props => [
        id,
        email,
        name,
        height,
        weight,
        fitnessLevel,
        targetAreas,
        isPremium,
        profileImageUrl,
        registrationDate,
        lastLogin,
        totalWorkouts,
        totalMinutes,
        streakDays,
        totalCaloriesBurned,
        lastWorkout,
      ];
}
