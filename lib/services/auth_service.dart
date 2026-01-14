
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';
import '../models/models.dart';
import 'dart:convert';

/// Service class responsible for authentication and session management.
class AuthService {
  /// Simulates a user login process.
  /// 
  /// Accepts [email] and [password], performs a mock validation (requires '@' in email and password length >= 6).
  /// If successful, returns a logged-in [UserModel] and persists the session.
  /// If validation fails, returns `null`.
  Future<UserModel?> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
    
    // Mock validation
    if (email.contains('@') && password.length >= 6) {
      final user = UserModel(
        email: email, 
        name: email.split('@')[0],
        avatarUrl: 'https://i.pravatar.cc/300', // Random avatar
      );
      
      // Persist login
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(AppConstants.authTokenKey, true);
      await prefs.setString(AppConstants.userEmailKey, jsonEncode(user.toJson()));
      
      return user;
    }
    return null;
  }

  /// Logs the user out by clearing persisted session data.
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.authTokenKey);
    await prefs.remove(AppConstants.userEmailKey);
  }

  /// Retrieves the currently authenticated user from local storage.
  /// 
  /// Returns [UserModel] if a valid session exists.
  /// Returns `null` if no token is found.
  /// 
  /// Includes logic to filter out legacy/corrupted user data (e.g., 'Mavel' user).
  Future<UserModel?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(AppConstants.authTokenKey) == true) {
      final userStr = prefs.getString(AppConstants.userEmailKey);
      if (userStr != null) {
        final user = UserModel.fromJson(jsonDecode(userStr));
        // FIX: If the old "Mavel" user is persisted, override it with Okwuchukwu
        if (user.name.toLowerCase().contains('mavel')) {
           // Fall through to return default below
        } else {
          return user;
        }
      }
    }
    // Return null if no valid session found. 
    // This fixes the bug where logout didn't persist because we always returned a default user.
    return null;
  }
  
  /// Checks if a user is currently logged in.
  /// 
  /// Returns `true` if an auth token exists in shared preferences.
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(AppConstants.authTokenKey) ?? false;
  }
}
