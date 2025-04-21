import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/onboarding_bloc.dart';
import '../../../../core/theme/app_theme.dart';

class GoalsScreen extends StatelessWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'Seu Nível de Fitness',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Como você se classifica em termos de condicionamento físico?',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 40),

          // Fitness level selection
          const _FitnessLevelSelector(),

          const SizedBox(height: 24),

          // Continue button
          BlocBuilder<OnboardingBloc, OnboardingState>(
            builder: (context, state) {
              final bool canContinue =
                  state is OnboardingInProgress && state.fitnessLevel != null;

              return SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: canContinue
                      ? () {
                          // Move to next page (handled by parent widget's next button)
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    disabledBackgroundColor: AppTheme.surfaceColor,
                  ),
                  child: const Text(
                    'Continuar',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _FitnessLevelSelector extends StatelessWidget {
  const _FitnessLevelSelector();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OnboardingBloc, OnboardingState>(
      builder: (context, state) {
        final selectedLevel =
            state is OnboardingInProgress ? state.fitnessLevel : null;

        return Column(
          children: [
            _FitnessLevelCard(
              level: 1,
              title: 'Iniciante',
              description:
                  'Estou começando agora ou retomando após muito tempo.',
              isSelected: selectedLevel == 1,
            ),
            const SizedBox(height: 12),
            _FitnessLevelCard(
              level: 2,
              title: 'Intermediário',
              description: 'Eu me exercito regularmente há algum tempo.',
              isSelected: selectedLevel == 2,
            ),
            const SizedBox(height: 12),
            _FitnessLevelCard(
              level: 3,
              title: 'Avançado',
              description: 'Tenho muita experiência e busco desafios intensos.',
              isSelected: selectedLevel == 3,
            ),
          ],
        );
      },
    );
  }
}

class _FitnessLevelCard extends StatelessWidget {
  final int level;
  final String title;
  final String description;
  final bool isSelected;

  const _FitnessLevelCard({
    required this.level,
    required this.title,
    required this.description,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: isSelected
          ? AppTheme.primaryColor.withOpacity(0.1)
          : AppTheme.surfaceColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? AppTheme.primaryColor : Colors.transparent,
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: () {
          context.read<OnboardingBloc>().add(
                UpdateFitnessGoals(fitnessLevel: level),
              );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.primaryColor
                      : AppTheme.surfaceColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? AppTheme.primaryColor
                        : AppTheme.subtitleColor,
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? const Icon(Icons.check, color: Colors.white)
                    : Center(
                        child: Text('$level',
                            style:
                                const TextStyle(fontWeight: FontWeight.bold))),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
