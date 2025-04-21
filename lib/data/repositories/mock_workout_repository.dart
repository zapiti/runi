import '../models/workout_model.dart';
import '../models/workout_exercise_model.dart';
import 'workout_repository.dart';

class MockWorkoutRepository implements WorkoutRepository {
  @override
  Future<List<WorkoutModel>> getWorkouts({
    WorkoutType? type,
    bool? isPremium,
    int? limit,
    int? offset,
  }) async {
    await Future.delayed(
        const Duration(milliseconds: 800)); // Simulate network delay

    var workouts = _getMockWorkouts();

    if (type != null) {
      workouts =
          workouts.where((w) => w.targetAreas.contains(type.name)).toList();
    }

    if (isPremium != null) {
      workouts = workouts.where((w) => w.isPremium == isPremium).toList();
    }

    if (limit != null) {
      workouts = workouts.take(limit).toList();
    }

    return workouts;
  }

  @override
  Future<WorkoutModel> getWorkoutById(String id) async {
    await Future.delayed(
        const Duration(milliseconds: 500)); // Simulate network delay

    final workouts = _getMockWorkouts();
    final workout = workouts.firstWhere(
      (w) => w.id == id,
      orElse: () => throw Exception('Workout not found'),
    );

    return workout;
  }

  @override
  Future<List<WorkoutModel>> getRecommendedWorkouts({
    required List<MuscleGroup> targetMuscles,
    required int fitnessLevel,
    int limit = 5,
  }) async {
    await Future.delayed(
        const Duration(milliseconds: 800)); // Simulate network delay

    final workouts = _getMockWorkouts();
    final targetNames = targetMuscles.map((e) => e.name).toList();

    // Filter workouts that match at least one target muscle
    var filtered = workouts.where((w) {
      return w.targetAreas.any((area) => targetNames.contains(area));
    }).toList();

    // Take only the requested number
    filtered = filtered.take(limit).toList();

    return filtered;
  }

  @override
  Future<List<Exercise>> getExercisesByMuscleGroup(
      MuscleGroup muscleGroup) async {
    await Future.delayed(
        const Duration(milliseconds: 600)); // Simulate network delay

    const exercises = [
      Exercise(
        id: 'e1',
        name: 'Flexões',
        description: 'Exercício clássico para peito, ombros e tríceps',
        videoUrl: 'https://example.com/videos/pushups.mp4',
        targetMuscles: [
          MuscleGroup.chest,
          MuscleGroup.shoulders,
          MuscleGroup.arms
        ],
        durationSeconds: 60,
        sets: 3,
        reps: 15,
        requiresEquipment: false,
      ),
      Exercise(
        id: 'e2',
        name: 'Agachamentos',
        description: 'Fortalece quadríceps, glúteos e isquiotibiais',
        videoUrl: 'https://example.com/videos/squats.mp4',
        targetMuscles: [MuscleGroup.legs],
        durationSeconds: 90,
        sets: 4,
        reps: 12,
        requiresEquipment: false,
      ),
      Exercise(
        id: 'e3',
        name: 'Pranchas',
        description: 'Fortalece todo o core e estabiliza a coluna',
        videoUrl: 'https://example.com/videos/planks.mp4',
        targetMuscles: [MuscleGroup.core],
        durationSeconds: 30,
        sets: 3,
        reps: null,
        requiresEquipment: false,
      ),
    ];

    return exercises
        .where((e) => e.targetMuscles.contains(muscleGroup))
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
    await Future.delayed(
        const Duration(milliseconds: 1000)); // Simulate network delay

    final workout = WorkoutModel(
      id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      description: description,
      imageUrl: thumbnailUrl ??
          'https://via.placeholder.com/400x200?text=Custom+Workout',
      duration:
          exercises.fold(0, (total, e) => total + (e.durationSeconds ~/ 60)),
      difficulty: 'Personalizado',
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
              ))
          .toList(),
    );

    return workout;
  }

  @override
  Future<void> deleteWorkout(String id) async {
    await Future.delayed(
        const Duration(milliseconds: 700)); // Simulate network delay
    // In a real app, we would delete from a database
    return;
  }

  @override
  Future<void> updateWorkout(WorkoutModel workout) async {
    await Future.delayed(
        const Duration(milliseconds: 800)); // Simulate network delay
    // In a real app, we would update in a database
    return;
  }

  @override
  Stream<List<WorkoutModel>> workoutStream({
    WorkoutType? type,
    bool? isPremium,
  }) {
    // Return a stream that emits once with the mock data
    return Stream.value(_getMockWorkouts().where((workout) {
      if (type != null && !workout.targetAreas.contains(type.name)) {
        return false;
      }
      if (isPremium != null && workout.isPremium != isPremium) {
        return false;
      }
      return true;
    }).toList());
  }

  // Helper to get mock workouts
  List<WorkoutModel> _getMockWorkouts() {
    return const [
      WorkoutModel(
        id: 'w1',
        name: 'Treino HIIT Total',
        description:
            'Um treino de alta intensidade que trabalha todo o corpo em 30 minutos.',
        imageUrl:
            'https://images.unsplash.com/photo-1517836357463-d25dfeac3438?ixlib=rb-1.2.1&auto=format&fit=crop&w=1350&q=80',
        duration: 30,
        difficulty: 'Intermediário',
        isPremium: false,
        targetAreas: ['fullBody', 'cardio'],
        equipment: ['nenhum'],
        exercises: [
          WorkoutExerciseModel(
            id: 'e1',
            name: 'Jumping Jacks',
            description: '30 segundos de jumping jacks',
            durationSeconds: 30,
            sets: 3,
            reps: 10,
            instructions: 'Faça o exercício por 30 segundos',
          ),
          WorkoutExerciseModel(
            id: 'e2',
            name: 'Burpees',
            description: '45 segundos de burpees',
            durationSeconds: 45,
            sets: 3,
            reps: 10,
            instructions: 'Faça o exercício por 45 segundos',
          ),
          WorkoutExerciseModel(
            id: 'e3',
            name: 'Mountain Climbers',
            description: '30 segundos de mountain climbers',
            durationSeconds: 30,
            sets: 3,
            reps: 10,
            instructions: 'Faça o exercício por 30 segundos',
          ),
        ],
      ),
      WorkoutModel(
        id: 'w2',
        name: 'Treino de Força',
        description:
            'Focado em desenvolver força nos principais grupos musculares.',
        imageUrl:
            'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?ixlib=rb-1.2.1&auto=format&fit=crop&w=1350&q=80',
        duration: 45,
        difficulty: 'Avançado',
        isPremium: true,
        targetAreas: ['chest', 'back', 'legs', 'arms'],
        equipment: ['halteres', 'banco'],
        exercises: [
          WorkoutExerciseModel(
            id: 'e4',
            name: 'Supino com Halteres',
            description: '4 séries de 8-10 repetições',
            durationSeconds: 180,
            sets: 4,
            reps: 10,
            instructions: 'Deite no banco com os halteres nas mãos',
          ),
          WorkoutExerciseModel(
            id: 'e5',
            name: 'Remada com Halteres',
            description: '4 séries de 10-12 repetições',
            durationSeconds: 180,
            sets: 4,
            reps: 12,
            instructions: 'Segure os halteres com o tronco inclinado',
          ),
          WorkoutExerciseModel(
            id: 'e6',
            name: 'Agachamento',
            description: '4 séries de 12-15 repetições',
            durationSeconds: 180,
            sets: 4,
            reps: 15,
            instructions: 'Mantenha as costas retas durante o exercício',
          ),
        ],
      ),
      WorkoutModel(
        id: 'w3',
        name: 'Yoga para Iniciantes',
        description:
            'Uma introdução gentil ao yoga, focando em respiração e flexibilidade.',
        imageUrl:
            'https://images.unsplash.com/photo-1545389336-cf090694435e?ixlib=rb-1.2.1&auto=format&fit=crop&w=1350&q=80',
        duration: 20,
        difficulty: 'Iniciante',
        isPremium: false,
        targetAreas: ['flexibility', 'core'],
        equipment: ['tapete'],
        exercises: [
          WorkoutExerciseModel(
            id: 'e7',
            name: 'Postura da Montanha',
            description:
                'Fique de pé com os pés juntos e braços ao lado do corpo',
            durationSeconds: 60,
            sets: 1,
            reps: 10,
            instructions: 'Mantenha a respiração controlada',
          ),
          WorkoutExerciseModel(
            id: 'e8',
            name: 'Postura do Cachorro Olhando para Baixo',
            description: 'Forma um V invertido com o corpo',
            durationSeconds: 90,
            sets: 1,
            reps: 10,
            instructions: 'Mantenha os calcanhares no chão se possível',
          ),
          WorkoutExerciseModel(
            id: 'e9',
            name: 'Postura da Criança',
            description: 'Postura de descanso com o tronco sobre as pernas',
            durationSeconds: 120,
            sets: 1,
            reps: 10,
            instructions: 'Respire profundamente',
          ),
        ],
      ),
      WorkoutModel(
        id: 'w4',
        name: 'Core Express',
        description:
            'Treino rápido focado no fortalecimento abdominal e lombar.',
        imageUrl:
            'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?ixlib=rb-1.2.1&auto=format&fit=crop&w=1350&q=80',
        duration: 15,
        difficulty: 'Intermediário',
        isPremium: false,
        targetAreas: ['core'],
        equipment: ['tapete'],
        exercises: [
          WorkoutExerciseModel(
            id: 'e10',
            name: 'Prancha',
            description: 'Mantenha a posição por 30 segundos',
            durationSeconds: 30,
            sets: 3,
            reps: 10,
            instructions: 'Mantenha o corpo reto durante o exercício',
          ),
          WorkoutExerciseModel(
            id: 'e11',
            name: 'Abdominais',
            description: '15 repetições',
            durationSeconds: 45,
            sets: 3,
            reps: 15,
            instructions: 'Exale ao subir, inspire ao descer',
          ),
          WorkoutExerciseModel(
            id: 'e12',
            name: 'Superman',
            description: 'Levante braços e pernas simultaneamente',
            durationSeconds: 30,
            sets: 3,
            reps: 10,
            instructions: 'Mantenha o pescoço alinhado',
          ),
        ],
      ),
      WorkoutModel(
        id: 'w5',
        name: 'Corrida Intervalada',
        description:
            'Alternando entre corrida e caminhada para melhorar o condicionamento.',
        imageUrl:
            'https://images.unsplash.com/photo-1476480862126-209bfaa8edc8?ixlib=rb-1.2.1&auto=format&fit=crop&w=1350&q=80',
        duration: 25,
        difficulty: 'Intermediário',
        isPremium: true,
        targetAreas: ['cardio', 'legs'],
        equipment: ['nenhum'],
        exercises: [
          WorkoutExerciseModel(
            id: 'e13',
            name: 'Aquecimento - Caminhada',
            description: '5 minutos de caminhada leve',
            durationSeconds: 300,
            sets: 1,
            reps: 10,
            instructions: 'Mantenha um ritmo leve',
          ),
          WorkoutExerciseModel(
            id: 'e14',
            name: 'Corrida Rápida',
            description: '1 minuto correndo em ritmo acelerado',
            durationSeconds: 60,
            sets: 5,
            reps: 10,
            instructions: 'Aumente o ritmo ao máximo',
          ),
          WorkoutExerciseModel(
            id: 'e15',
            name: 'Caminhada de Recuperação',
            description: '2 minutos de caminhada leve',
            durationSeconds: 120,
            sets: 5,
            reps: 10,
            instructions: 'Respire profundamente para recuperar',
          ),
        ],
      ),
    ];
  }
}
