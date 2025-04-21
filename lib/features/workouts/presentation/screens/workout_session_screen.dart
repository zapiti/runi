import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/workout_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../data/models/workout_model.dart';
import '../../../../data/models/workout_exercise_model.dart';

class WorkoutSessionScreen extends StatefulWidget {
  final WorkoutModel workout;

  const WorkoutSessionScreen({
    super.key,
    required this.workout,
  });

  @override
  State<WorkoutSessionScreen> createState() => _WorkoutSessionScreenState();
}

class _WorkoutSessionScreenState extends State<WorkoutSessionScreen> {
  late Timer _timer;
  late DateTime _startTime;
  int _currentExerciseIndex = 0;
  int _elapsedSeconds = 0;
  bool _isResting = false;
  int _restSeconds = 0;
  static const int restDuration = 30; // 30 seconds rest between exercises

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
    _startTimer();
    context.read<WorkoutBloc>().add(StartWorkout(widget.workout.id));
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_isResting) {
          _restSeconds++;
          if (_restSeconds >= restDuration) {
            _isResting = false;
            _restSeconds = 0;
            if (_currentExerciseIndex < widget.workout.exercises.length - 1) {
              _currentExerciseIndex++;
            }
          }
        } else {
          _elapsedSeconds++;
        }
      });
    });
  }

  void _completeWorkout() {
    _timer.cancel();
    final duration = DateTime.now().difference(_startTime);
    final durationMinutes = duration.inMinutes;
    // Simple calorie calculation based on duration and exercise type
    // In a real app, this would be more sophisticated
    final caloriesBurned = (durationMinutes * 6.5).round();

    context.read<WorkoutBloc>().add(
          CompleteWorkout(
            workoutId: widget.workout.id,
            durationMinutes: durationMinutes,
            caloriesBurned: caloriesBurned,
          ),
        );

    Navigator.pop(context);
  }

  void _nextExercise() {
    if (_currentExerciseIndex < widget.workout.exercises.length - 1) {
      setState(() {
        _isResting = true;
        _restSeconds = 0;
      });
    } else {
      _completeWorkout();
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentExercise = widget.workout.exercises[_currentExerciseIndex];

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _isResting
                  ? _buildRestingView()
                  : _buildExerciseView(currentExercise),
            ),
            _buildBottomBar(currentExercise),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Text(
            widget.workout.name,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Exercício ${_currentExerciseIndex + 1} de ${widget.workout.exercises.length}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value:
                (_currentExerciseIndex + 1) / widget.workout.exercises.length,
            backgroundColor: AppTheme.surfaceColor,
            valueColor:
                const AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
          ),
        ],
      ),
    );
  }

  Widget _buildRestingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.timer,
            size: 48,
            color: AppTheme.primaryColor,
          ),
          const SizedBox(height: 16),
          Text(
            'Descanse',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            '${restDuration - _restSeconds} segundos',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _isResting = false;
                _restSeconds = 0;
                if (_currentExerciseIndex <
                    widget.workout.exercises.length - 1) {
                  _currentExerciseIndex++;
                }
              });
            },
            child: const Text('Pular Descanso'),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseView(WorkoutExerciseModel exercise) {
    final durationSeconds = exercise.durationSeconds ?? 60;
    final sets = exercise.sets;
    final reps = exercise.reps;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            exercise.name,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            exercise.description ?? '',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
          _buildExerciseInfo(
            icon: Icons.timer,
            label: '${durationSeconds ~/ 60} min',
          ),
          const SizedBox(height: 8),
          _buildExerciseInfo(
            icon: Icons.repeat,
            label: '$sets séries',
          ),
          if (reps != null) ...[
            const SizedBox(height: 8),
            _buildExerciseInfo(
              icon: Icons.fitness_center,
              label: '$reps repetições',
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildExerciseInfo({
    required IconData icon,
    required String label,
  }) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.primaryColor),
        const SizedBox(width: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ],
    );
  }

  Widget _buildBottomBar(WorkoutExerciseModel currentExercise) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Text(
            'Tempo: ${_elapsedSeconds ~/ 60}:${(_elapsedSeconds % 60).toString().padLeft(2, '0')}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const Spacer(),
          ElevatedButton(
            onPressed: _nextExercise,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
            ),
            child: Text(
              _currentExerciseIndex < widget.workout.exercises.length - 1
                  ? 'Próximo'
                  : 'Finalizar',
            ),
          ),
        ],
      ),
    );
  }
}
