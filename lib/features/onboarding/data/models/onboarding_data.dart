import 'package:equatable/equatable.dart';
import '../../../../data/models/user_model.dart';

class OnboardingData extends Equatable {
  final double? weight;
  final double? height;
  final List<String> targetAreas;
  final FitnessLevel fitnessLevel;
  final WeightGoal weightGoal;
  final TrainingIntensity intensity;
  final bool isExercising;

  const OnboardingData({
    this.weight,
    this.height,
    this.targetAreas = const [],
    this.fitnessLevel = FitnessLevel.beginner,
    this.weightGoal = WeightGoal.maintain,
    this.intensity = TrainingIntensity.normal,
    this.isExercising = false,
  });

  OnboardingData copyWith({
    double? weight,
    double? height,
    List<String>? targetAreas,
    FitnessLevel? fitnessLevel,
    WeightGoal? weightGoal,
    TrainingIntensity? intensity,
    bool? isExercising,
  }) {
    return OnboardingData(
      weight: weight ?? this.weight,
      height: height ?? this.height,
      targetAreas: targetAreas ?? this.targetAreas,
      fitnessLevel: fitnessLevel ?? this.fitnessLevel,
      weightGoal: weightGoal ?? this.weightGoal,
      intensity: intensity ?? this.intensity,
      isExercising: isExercising ?? this.isExercising,
    );
  }

  @override
  List<Object?> get props => [
        weight,
        height,
        targetAreas,
        fitnessLevel,
        weightGoal,
        intensity,
        isExercising,
      ];
}
