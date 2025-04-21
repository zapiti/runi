import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/workout_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../data/models/workout_model.dart';
import 'workout_details_screen.dart';

class WorkoutsScreen extends StatefulWidget {
  const WorkoutsScreen({super.key});

  @override
  State<WorkoutsScreen> createState() => _WorkoutsScreenState();
}

class _WorkoutsScreenState extends State<WorkoutsScreen> {
  WorkoutType? _selectedType;

  @override
  void initState() {
    super.initState();
    context.read<WorkoutBloc>().add(const LoadWorkouts());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Treinos'),
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildTypeFilter(),
          Expanded(
            child: BlocBuilder<WorkoutBloc, WorkoutState>(
              builder: (context, state) {
                if (state is WorkoutLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (state is WorkoutError) {
                  return Center(
                    child: Text(
                      state.message,
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }

                if (state is WorkoutsLoaded) {
                  if (state.workouts.isEmpty) {
                    return const Center(
                      child: Text(
                        'Nenhum treino disponível',
                        style: TextStyle(color: AppTheme.textColor),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: state.workouts.length,
                    itemBuilder: (context, index) {
                      final workout = state.workouts[index];
                      return _WorkoutCard(
                        workout: workout,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  WorkoutDetailsScreen(workout: workout),
                            ),
                          );
                        },
                      );
                    },
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeFilter() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          const SizedBox(width: 16),
          FilterChip(
            label: const Text('Todos'),
            selected: _selectedType == null,
            onSelected: (selected) {
              setState(() {
                _selectedType = null;
              });
              context.read<WorkoutBloc>().add(const LoadWorkouts());
            },
            backgroundColor: AppTheme.surfaceColor,
            selectedColor: AppTheme.primaryColor,
            checkmarkColor: Colors.white,
            labelStyle: TextStyle(
              color:
                  _selectedType == null ? Colors.white : AppTheme.subtitleColor,
            ),
          ),
          ...WorkoutType.values.map((type) {
            return Padding(
              padding: const EdgeInsets.only(left: 8),
              child: FilterChip(
                label: Text(_getWorkoutTypeLabel(type)),
                selected: _selectedType == type,
                onSelected: (selected) {
                  setState(() {
                    _selectedType = selected ? type : null;
                  });
                  context.read<WorkoutBloc>().add(
                        LoadWorkouts(type: selected ? type : null),
                      );
                },
                backgroundColor: AppTheme.surfaceColor,
                selectedColor: AppTheme.primaryColor,
                checkmarkColor: Colors.white,
                labelStyle: TextStyle(
                  color: _selectedType == type
                      ? Colors.white
                      : AppTheme.subtitleColor,
                ),
              ),
            );
          }).toList(),
          const SizedBox(width: 16),
        ],
      ),
    );
  }

  String _getWorkoutTypeLabel(WorkoutType type) {
    switch (type) {
      case WorkoutType.core:
        return 'Core';
      case WorkoutType.cardio:
        return 'Cardio';
      case WorkoutType.strength:
        return 'Força';
      case WorkoutType.flexibility:
        return 'Flexibilidade';
    }
  }
}

class _WorkoutCard extends StatelessWidget {
  final WorkoutModel workout;
  final VoidCallback onTap;

  const _WorkoutCard({
    required this.workout,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: AppTheme.surfaceColor,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (workout.imageUrl.isNotEmpty)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child: Image.network(
                  workout.imageUrl,
                  height: 160,
                  fit: BoxFit.cover,
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          workout.name,
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(color: AppTheme.textColor),
                        ),
                      ),
                      if (workout.isPremium)
                        const Icon(
                          Icons.star,
                          color: Colors.amber,
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    workout.description,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: AppTheme.subtitleColor),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(
                        Icons.timer,
                        size: 16,
                        color: AppTheme.subtitleColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${workout.duration} min',
                        style: const TextStyle(color: AppTheme.subtitleColor),
                      ),
                      const SizedBox(width: 16),
                      const Icon(
                        Icons.fitness_center,
                        size: 16,
                        color: AppTheme.subtitleColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${workout.exercises.length} exercícios',
                        style: const TextStyle(color: AppTheme.subtitleColor),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
