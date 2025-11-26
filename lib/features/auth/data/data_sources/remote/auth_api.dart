import 'package:flutter/widgets.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/user_model.dart';

class AuthApi {
  final SupabaseClient client;

  AuthApi(this.client);

  //login
  Future<UserModel> loginWithEmail({
    required String email,
    required String password,
  }) async {
    final res = await client.auth.signInWithPassword(
      email: email,
      password: password,
    );

    final user = res.user;
    if (user == null) {
      throw Exception('Login failed');
    }
    return UserModel.fromSupabaseUser(user);
  }

  //register
  Future<void> registerWithEmail({
    required String email,
    required String password,
  }) async {
    debugPrint("signup");

    try {
      await client.auth.signUp(email: email, password: password);
    } catch (e) {
      throw Exception("SignUp failed");
    }
    // final user = res.user;
  }

  Future<void> logout() async {
    await client.auth.signOut();
  }

  Future<UserModel?> getCurrentUser() async {
    final user = client.auth.currentUser;
    if (user == null) return null;
    return UserModel.fromSupabaseUser(user);
  }
}
