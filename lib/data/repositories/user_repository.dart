import '../models/user_model.dart';

abstract class UserRepository {
  Future<UserModel?> getCurrentUser();

  Future<UserModel> getUserById(String id);

  Future<UserModel> createUser({
    required String email,
    required String password,
    required String name,
  });

  Future<UserModel> loginWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<void> logout();

  Future<UserModel> updateUserData(UserModel user);

  Future<UserModel> updateUserProfile({
    required String userId,
    String? name,
    double? height,
    double? weight,
    int? fitnessLevel,
    List<String>? targetAreas,
    String? profileImageUrl,
  });

  Future<void> deleteUser(String userId);

  Future<bool> togglePremiumStatus(String userId, bool isPremium);

  Future<void> updateLastWorkout(String userId, DateTime lastWorkout);

  Stream<UserModel?> userStream(String userId);
}
