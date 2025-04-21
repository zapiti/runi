import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../data/models/user_model.dart';
import '../../../../data/repositories/user_repository.dart';
import '../bloc/profile_bloc.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProfileBloc(
        userRepository: context.read<UserRepository>(),
      )..add(LoadProfile()),
      child: const ProfileView(),
    );
  }
}

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Meu Perfil'),
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Navigate to settings screen
            },
          ),
        ],
      ),
      body: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          if (state is ProfileLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ProfileError) {
            return Center(
              child: Text(
                'Erro ao carregar perfil: ${state.message}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          if (state is ProfileLoaded) {
            final user = state.user;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildProfileHeader(context, user),
                  const SizedBox(height: 24),
                  _buildUserInfo(context, user),
                  const SizedBox(height: 24),
                  _buildStatistics(context, user),
                  const SizedBox(height: 24),
                  _buildActions(context),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, UserModel user) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            CircleAvatar(
              radius: 60,
              backgroundColor: AppTheme.surfaceColor,
              backgroundImage: user.profileImageUrl != null &&
                      user.profileImageUrl!.isNotEmpty
                  ? NetworkImage(user.profileImageUrl!)
                  : null,
              child:
                  user.profileImageUrl == null || user.profileImageUrl!.isEmpty
                      ? const Icon(Icons.person,
                          size: 60, color: AppTheme.primaryColor)
                      : null,
            ),
            CircleAvatar(
              radius: 20,
              backgroundColor: AppTheme.primaryColor,
              child: IconButton(
                icon: const Icon(Icons.edit, size: 16, color: Colors.white),
                onPressed: () {
                  context.read<ProfileBloc>().add(ChangeProfilePhoto());
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          user.name,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppTheme.textColor,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          user.email,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.subtitleColor,
              ),
        ),
        if (user.isPremium)
          Chip(
            label: const Text(
              'Premium',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.amber,
            avatar: const Icon(Icons.star, color: Colors.white, size: 16),
          ),
      ],
    );
  }

  Widget _buildUserInfo(BuildContext context, UserModel user) {
    return Card(
      color: AppTheme.surfaceColor,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Informações Pessoais',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(color: AppTheme.textColor),
            ),
            const SizedBox(height: 16),
            _buildInfoItem(
                context,
                'Altura',
                user.height != null ? '${user.height} cm' : 'Não definido',
                Icons.height),
            _buildInfoItem(
                context,
                'Peso',
                user.weight != null ? '${user.weight} kg' : 'Não definido',
                Icons.monitor_weight),
            _buildInfoItem(
              context,
              'Nível de condicionamento',
              user.fitnessLevel != null
                  ? _getFitnessLevelText(user.fitnessLevel!)
                  : 'Não definido',
              Icons.fitness_center,
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                context.read<ProfileBloc>().add(EditProfile());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.secondaryColor,
                padding: const EdgeInsets.symmetric(vertical: 12),
                minimumSize: const Size(double.infinity, 0),
              ),
              child: const Text('Editar Informações'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(
      BuildContext context, String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.subtitleColor, size: 20),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.subtitleColor,
                    ),
              ),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppTheme.textColor,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatistics(BuildContext context, UserModel user) {
    return Card(
      color: AppTheme.surfaceColor,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Estatísticas',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(color: AppTheme.textColor),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Treinos',
                    user.totalWorkouts?.toString() ?? '0',
                    Icons.fitness_center,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Total de minutos',
                    user.totalMinutes?.toString() ?? '0',
                    Icons.timer,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Dias seguidos',
                    user.streakDays?.toString() ?? '0',
                    Icons.local_fire_department,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Calorias',
                    user.totalCaloriesBurned?.toString() ?? '0',
                    Icons.whatshot,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
      BuildContext context, String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppTheme.primaryColor, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppTheme.textColor,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.subtitleColor,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Card(
      color: AppTheme.surfaceColor,
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.star, color: Colors.amber),
            title: const Text('Obter Premium',
                style: TextStyle(color: AppTheme.textColor)),
            trailing:
                const Icon(Icons.chevron_right, color: AppTheme.subtitleColor),
            onTap: () {
              context.read<ProfileBloc>().add(SubscribeToPremium());
            },
          ),
          const Divider(color: AppTheme.surfaceColor),
          ListTile(
            leading:
                const Icon(Icons.help_outline, color: AppTheme.primaryColor),
            title: const Text('Ajuda e Suporte',
                style: TextStyle(color: AppTheme.textColor)),
            trailing:
                const Icon(Icons.chevron_right, color: AppTheme.subtitleColor),
            onTap: () {
              // Navigate to help and support
            },
          ),
          const Divider(color: AppTheme.surfaceColor),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title:
                const Text('Sair', style: TextStyle(color: AppTheme.textColor)),
            onTap: () {
              context.read<ProfileBloc>().add(LogoutRequested());
            },
          ),
        ],
      ),
    );
  }

  String _getFitnessLevelText(int level) {
    switch (level) {
      case 1:
        return 'Iniciante';
      case 2:
        return 'Intermediário';
      case 3:
        return 'Avançado';
      default:
        return 'Não definido';
    }
  }
}
