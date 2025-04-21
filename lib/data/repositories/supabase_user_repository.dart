import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import 'user_repository.dart';

class SupabaseUserRepository implements UserRepository {
  final SupabaseClient _supabase;

  SupabaseUserRepository(this._supabase);

  @override
  Future<UserModel?> getCurrentUser() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return null;

    final response =
        await _supabase.from('users').select().eq('id', user.id).single();

    return UserModel.fromJson(response as Map<String, dynamic>);
  }

  @override
  Future<UserModel> getUserById(String id) async {
    final response =
        await _supabase.from('users').select().eq('id', id).single();
    return UserModel.fromJson(response as Map<String, dynamic>);
  }

  @override
  Future<UserModel> createUser({
    required String email,
    required String password,
    required String name,
  }) async {
    final response = await _supabase.auth.signUp(
      email: email,
      password: password,
    );

    if (response.user == null) {
      throw Exception('Failed to create user');
    }

    final user = UserModel(
      id: response.user!.id,
      email: email,
      name: name,
      registrationDate: DateTime.now(),
      lastLogin: DateTime.now(),
    );

    await _supabase.from('users').insert(user.toJson());
    return user;
  }

  @override
  Future<UserModel> loginWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final response = await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );

    if (response.user == null) {
      throw Exception('Failed to sign in');
    }

    final userData = await _supabase
        .from('users')
        .select()
        .eq('id', response.user!.id)
        .single();

    return UserModel.fromJson(userData as Map<String, dynamic>);
  }

  @override
  Future<void> logout() async {
    await _supabase.auth.signOut();
  }

  @override
  Future<UserModel> updateUserData(UserModel user) async {
    await _supabase.from('users').update(user.toJson()).eq('id', user.id);
    return user;
  }

  @override
  Future<UserModel> updateUserProfile({
    required String userId,
    String? name,
    double? height,
    double? weight,
    int? fitnessLevel,
    List<String>? targetAreas,
    String? profileImageUrl,
  }) async {
    final currentUser = await getUserById(userId);

    final updatedUser = currentUser.copyWith(
      name: name,
      height: height,
      weight: weight,
      fitnessLevel: fitnessLevel,
      targetAreas: targetAreas,
      profileImageUrl: profileImageUrl,
    );

    await _supabase.from('users').update(updatedUser.toJson()).eq('id', userId);
    return updatedUser;
  }

  @override
  Future<void> deleteUser(String userId) async {
    await _supabase.from('users').delete().eq('id', userId);
  }

  @override
  Future<bool> togglePremiumStatus(String userId, bool isPremium) async {
    await _supabase
        .from('users')
        .update({'is_premium': isPremium}).eq('id', userId);

    return isPremium;
  }

  @override
  Future<void> updateLastWorkout(String userId, DateTime lastWorkout) async {
    await _supabase.from('users').update(
        {'last_workout': lastWorkout.toIso8601String()}).eq('id', userId);
  }

  @override
  Stream<UserModel?> userStream(String userId) {
    return _supabase
        .from('users')
        .stream(primaryKey: ['id'])
        .eq('id', userId)
        .map((event) {
          if (event.isEmpty) return null;
          return UserModel.fromJson(event.first as Map<String, dynamic>);
        });
  }
}
