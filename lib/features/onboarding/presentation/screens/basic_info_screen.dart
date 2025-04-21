import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/onboarding_bloc.dart';
import '../../../../core/theme/app_theme.dart';

class BasicInfoScreen extends StatefulWidget {
  const BasicInfoScreen({super.key});

  @override
  State<BasicInfoScreen> createState() => _BasicInfoScreenState();
}

class _BasicInfoScreenState extends State<BasicInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  double? _height;
  double? _weight;

  @override
  void dispose() {
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate() &&
        _height != null &&
        _weight != null) {
      context.read<OnboardingBloc>().add(
            UpdateBasicInfo(
              height: _height!,
              weight: _weight!,
            ),
          );

      // Move to next page (handled by parent widget's next button)
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'Informações Básicas',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Precisamos saber um pouco sobre você para personalizar seu plano.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 40),

            // Height field
            TextFormField(
              controller: _heightController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Altura (cm)',
                prefixIcon: Icon(Icons.height),
                hintText: 'Ex: 175',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, insira sua altura';
                }

                final height = double.tryParse(value);
                if (height == null) {
                  return 'Insira um número válido';
                }

                if (height < 100 || height > 250) {
                  return 'Insira uma altura entre 100 e 250 cm';
                }

                setState(() {
                  _height = height;
                });

                return null;
              },
            ),
            const SizedBox(height: 16),

            // Weight field
            TextFormField(
              controller: _weightController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Peso (kg)',
                prefixIcon: Icon(Icons.monitor_weight),
                hintText: 'Ex: 70',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, insira seu peso';
                }

                final weight = double.tryParse(value);
                if (weight == null) {
                  return 'Insira um número válido';
                }

                if (weight < 30 || weight > 300) {
                  return 'Insira um peso entre 30 e 300 kg';
                }

                setState(() {
                  _weight = weight;
                });

                return null;
              },
            ),
            const SizedBox(height: 32),

            // Submit button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 12),
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
            ),
          ],
        ),
      ),
    );
  }
}
