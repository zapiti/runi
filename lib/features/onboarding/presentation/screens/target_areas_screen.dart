import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/onboarding_bloc.dart';
import '../../../../core/theme/app_theme.dart';

class TargetAreasScreen extends StatelessWidget {
  const TargetAreasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'Áreas de Foco',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Selecione as áreas musculares que você quer priorizar.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 40),

          // Target area selection
          const Expanded(child: _TargetAreaSelector()),

          // Finish button
          BlocBuilder<OnboardingBloc, OnboardingState>(
            builder: (context, state) {
              final bool canFinish =
                  state is OnboardingInProgress && state.targetAreas.isNotEmpty;

              return SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: canFinish
                      ? () {
                          context
                              .read<OnboardingBloc>()
                              .add(CompleteOnboarding());
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    disabledBackgroundColor: AppTheme.surfaceColor,
                  ),
                  child: const Text(
                    'Finalizar',
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

class _TargetAreaSelector extends StatelessWidget {
  const _TargetAreaSelector();

  @override
  Widget build(BuildContext context) {
    final targetAreas = [
      {'name': 'core', 'title': 'Abdômen', 'icon': Icons.fitness_center},
      {'name': 'chest', 'title': 'Peito', 'icon': Icons.fitness_center},
      {'name': 'back', 'title': 'Costas', 'icon': Icons.fitness_center},
      {'name': 'arms', 'title': 'Braços', 'icon': Icons.fitness_center},
      {'name': 'shoulders', 'title': 'Ombros', 'icon': Icons.fitness_center},
      {'name': 'legs', 'title': 'Pernas', 'icon': Icons.fitness_center},
      {
        'name': 'fullBody',
        'title': 'Corpo Inteiro',
        'icon': Icons.accessibility_new
      },
      {'name': 'cardio', 'title': 'Cardio', 'icon': Icons.favorite},
      {
        'name': 'flexibility',
        'title': 'Flexibilidade',
        'icon': Icons.airline_seat_flat
      },
    ];

    return BlocBuilder<OnboardingBloc, OnboardingState>(
      builder: (context, state) {
        final selectedAreas =
            state is OnboardingInProgress ? state.targetAreas : <String>[];

        return GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 0.9,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: targetAreas.length,
          itemBuilder: (context, index) {
            final area = targetAreas[index];
            final isSelected = selectedAreas.contains(area['name']);

            return _TargetAreaCard(
              areaName: area['name'] as String,
              title: area['title'] as String,
              icon: area['icon'] as IconData,
              isSelected: isSelected,
              selectedAreas: selectedAreas,
            );
          },
        );
      },
    );
  }
}

class _TargetAreaCard extends StatelessWidget {
  final String areaName;
  final String title;
  final IconData icon;
  final bool isSelected;
  final List<String> selectedAreas;

  const _TargetAreaCard({
    required this.areaName,
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.selectedAreas,
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
          // Toggle this area
          final List<String> updatedAreas = List.from(selectedAreas);
          if (isSelected) {
            updatedAreas.remove(areaName);
          } else {
            updatedAreas.add(areaName);
          }

          context.read<OnboardingBloc>().add(
                UpdateTargetAreas(targetAreas: updatedAreas),
              );
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color:
                  isSelected ? AppTheme.primaryColor : AppTheme.subtitleColor,
              size: 36,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? AppTheme.primaryColor : AppTheme.textColor,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
