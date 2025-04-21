import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../data/models/workout_model.dart';
import '../bloc/active_workout_bloc.dart';

class ActiveWorkoutScreen extends StatelessWidget {
  final WorkoutModel workout;

  const ActiveWorkoutScreen({
    super.key,
    required this.workout,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ActiveWorkoutBloc(
        workout: workout,
      )..add(StartWorkout()),
      child: ActiveWorkoutView(workout: workout),
    );
  }
}

class ActiveWorkoutView extends StatelessWidget {
  final WorkoutModel workout;

  const ActiveWorkoutView({
    super.key,
    required this.workout,
  });

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ActiveWorkoutBloc, ActiveWorkoutState>(
      listener: (context, state) {
        if (state is WorkoutCompleted) {
          // Show completion dialog and navigate back
          _showCompletionDialog(context, state.workout);
        } else if (state is WorkoutError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppTheme.backgroundColor,
          appBar: AppBar(
            title: Text(workout.name),
            backgroundColor: AppTheme.backgroundColor,
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => _showExitConfirmation(context),
              ),
            ],
          ),
          body: _buildBody(context, state),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, ActiveWorkoutState state) {
    if (state is WorkoutLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is WorkoutInProgress) {
      return Column(
        children: [
          _buildProgressBar(context, state),
          _buildWorkoutHeader(context, state),
          const SizedBox(height: 16),
          _buildCurrentExercise(context, state),
          const Spacer(),
          _buildControls(context, state),
        ],
      );
    }

    return const Center(
      child: Text(
        'Preparando treino...',
        style: TextStyle(color: AppTheme.textColor),
      ),
    );
  }

  Widget _buildProgressBar(BuildContext context, WorkoutInProgress state) {
    final progress = state.currentExerciseIndex / workout.exercises.length;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: LinearProgressIndicator(
        value: progress,
        backgroundColor: AppTheme.surfaceColor,
        valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
        minHeight: 8,
      ),
    );
  }

  Widget _buildWorkoutHeader(BuildContext context, WorkoutInProgress state) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Exercício ${state.currentExerciseIndex + 1} de ${workout.exercises.length}',
                  style: const TextStyle(
                    color: AppTheme.subtitleColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  state.isResting ? 'Descansando' : state.currentExercise.name,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: AppTheme.textColor,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),
          _buildTimer(context, state),
        ],
      ),
    );
  }

  Widget _buildTimer(BuildContext context, WorkoutInProgress state) {
    final seconds = state.remainingSeconds % 60;
    final minutes = state.remainingSeconds ~/ 60;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: state.isResting ? Colors.blue : AppTheme.primaryColor,
        shape: BoxShape.circle,
      ),
      child: Text(
        '$minutes:${seconds.toString().padLeft(2, '0')}',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
    );
  }

  Widget _buildCurrentExercise(BuildContext context, WorkoutInProgress state) {
    if (state.isResting) {
      return _buildRestingView(context, state);
    }

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Card(
          color: AppTheme.surfaceColor,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (state.currentExercise.imageUrl != null &&
                    state.currentExercise.imageUrl!.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      state.currentExercise.imageUrl!,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                const SizedBox(height: 16),
                Text(
                  state.currentExercise.name,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppTheme.textColor,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Séries: ${state.currentExercise.sets} | '
                  'Repetições: ${state.currentExercise.reps}',
                  style: const TextStyle(
                    color: AppTheme.subtitleColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Instruções:',
                  style: TextStyle(
                    color: AppTheme.textColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  state.currentExercise.instructions ??
                      'Nenhuma instrução disponível',
                  style: const TextStyle(color: AppTheme.textColor),
                ),
                if (state.currentSet < state.currentExercise.sets)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      'Série ${state.currentSet + 1} de ${state.currentExercise.sets}',
                      style: const TextStyle(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRestingView(BuildContext context, WorkoutInProgress state) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Card(
          color: AppTheme.surfaceColor,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.hourglass_bottom,
                  size: 60,
                  color: Colors.blue,
                ),
                const SizedBox(height: 16),
                Text(
                  'Descansando',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: AppTheme.textColor,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Próximo exercício: ${_getNextExerciseName(state)}',
                  style: const TextStyle(
                    color: AppTheme.subtitleColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getNextExerciseName(WorkoutInProgress state) {
    final nextIndex = state.currentExerciseIndex + 1;
    if (nextIndex < workout.exercises.length) {
      return workout.exercises[nextIndex].name;
    } else if (state.currentSet + 1 < state.currentExercise.sets) {
      return 'Repetir ${state.currentExercise.name}';
    } else {
      return 'Fim do treino!';
    }
  }

  Widget _buildControls(BuildContext context, WorkoutInProgress state) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton.icon(
            onPressed: state.isActive
                ? () => context.read<ActiveWorkoutBloc>().add(PauseWorkout())
                : () => context.read<ActiveWorkoutBloc>().add(ResumeWorkout()),
            icon: Icon(state.isActive ? Icons.pause : Icons.play_arrow),
            label: Text(state.isActive ? 'Pausar' : 'Continuar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
            ),
          ),
          if (!state.isResting)
            ElevatedButton.icon(
              onPressed: () =>
                  context.read<ActiveWorkoutBloc>().add(CompleteExerciseSet()),
              icon: const Icon(Icons.done),
              label: const Text('Completar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          if (state.isResting)
            ElevatedButton.icon(
              onPressed: () =>
                  context.read<ActiveWorkoutBloc>().add(SkipRest()),
              icon: const Icon(Icons.skip_next),
              label: const Text('Pular'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showExitConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.backgroundColor,
        title: const Text(
          'Abandonar treino?',
          style: TextStyle(color: AppTheme.textColor),
        ),
        content: const Text(
          'Se você sair agora, seu progresso não será salvo.',
          style: TextStyle(color: AppTheme.subtitleColor),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Continuar treinando'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text(
              'Abandonar',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _showCompletionDialog(BuildContext context, WorkoutModel workout) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.backgroundColor,
        title: const Text(
          'Treino Completo!',
          style: TextStyle(color: AppTheme.textColor),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.emoji_events,
              color: Colors.amber,
              size: 60,
            ),
            const SizedBox(height: 16),
            Text(
              'Parabéns! Você completou o treino ${workout.name}.',
              style: const TextStyle(color: AppTheme.textColor),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              'Mantenha o ritmo e continue sua jornada fitness!',
              style: TextStyle(color: AppTheme.subtitleColor),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Voltar ao Dashboard'),
          ),
        ],
      ),
    );
  }
}
