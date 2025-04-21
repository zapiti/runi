import '../models/user_model.dart';
import 'user_repository.dart';

class MockUserRepository implements UserRepository {
  bool _isAuthenticated = true; // Default to true for demo purposes

  final _mockUser = UserModel(
    id: 'user123',
    email: 'demo@example.com',
    name: 'Nathan Oliveira',
    height: 178,
    weight: 75,
    fitnessLevel: 2,
    targetAreas: ['core', 'chest', 'back'],
    isPremium: false,
    profileImageUrl: 'https://i.pravatar.cc/150?img=4',
    registrationDate: DateTime.now().subtract(const Duration(days: 30)),
    lastLogin: DateTime.now(),
  );

  @override
  Future<UserModel> createUser({
    required String email,
    required String password,
    required String name,
  }) async {
    await Future.delayed(
        const Duration(milliseconds: 1000)); // Simulate network delay
    _isAuthenticated = true;
    return _mockUser;
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    await Future.delayed(
        const Duration(milliseconds: 500)); // Simulate network delay

    if (_isAuthenticated) {
      return _mockUser;
    }

    return null;
  }

  @override
  Future<UserModel> getUserById(String id) async {
    await Future.delayed(
        const Duration(milliseconds: 500)); // Simulate network delay
    return _mockUser;
  }

  @override
  Future<UserModel> loginWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    await Future.delayed(
        const Duration(milliseconds: 800)); // Simulate network delay
    _isAuthenticated = true;
    return _mockUser;
  }

  @override
  Future<void> logout() async {
    await Future.delayed(
        const Duration(milliseconds: 500)); // Simulate network delay
    _isAuthenticated = false;
  }

  @override
  Future<UserModel> updateUserData(UserModel user) async {
    await Future.delayed(
        const Duration(milliseconds: 700)); // Simulate network delay
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
    await Future.delayed(
        const Duration(milliseconds: 800)); // Simulate network delay

    return UserModel(
      id: _mockUser.id,
      email: _mockUser.email,
      name: name ?? _mockUser.name,
      height: height ?? _mockUser.height,
      weight: weight ?? _mockUser.weight,
      fitnessLevel: fitnessLevel ?? _mockUser.fitnessLevel,
      targetAreas: targetAreas ?? _mockUser.targetAreas,
      isPremium: _mockUser.isPremium,
      profileImageUrl: profileImageUrl ?? _mockUser.profileImageUrl,
      registrationDate: _mockUser.registrationDate,
      lastLogin: _mockUser.lastLogin,
    );
  }

  @override
  Future<void> deleteUser(String userId) async {
    await Future.delayed(
        const Duration(milliseconds: 700)); // Simulate network delay
    _isAuthenticated = false;
  }

  @override
  Future<bool> togglePremiumStatus(String userId, bool isPremium) async {
    await Future.delayed(
        const Duration(milliseconds: 600)); // Simulate network delay
    return isPremium;
  }

  @override
  Future<void> updateLastWorkout(String userId, DateTime lastWorkout) async {
    await Future.delayed(
        const Duration(milliseconds: 500)); // Simulate network delay
    // In a real app, we'd update the user model
  }

  @override
  Stream<UserModel?> userStream(String userId) {
    // Return a stream that emits the mock user
    return Stream.value(_isAuthenticated ? _mockUser : null);
  }
}
