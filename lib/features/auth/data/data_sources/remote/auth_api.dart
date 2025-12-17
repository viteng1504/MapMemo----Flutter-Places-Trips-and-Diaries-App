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

  Future<void> registerWithEmail({
    required String email,
    required String username,
    required String password,
  }) async {
    final res = await client.auth.signUp(email: email, password: password);

    final user = res.user;
    if (user == null) {
      throw Exception('Sign up failed');
    }

    // insert username vào profiles
    await client.from('profiles').insert({'id': user.id, 'username': username});
  }

  Future<void> logout() async {
    await client.auth.signOut();
  }

  Future<UserModel?> getCurrentUser() async {
    final User? user = client.auth.currentUser;
    if (user == null) return null;
    return UserModel.fromSupabaseUser(user);
  }

  Future<String?> getUsername() async {
    final user = client.auth.currentUser;
    if (user == null) return null;

    final data = await client
        .from('profiles')
        .select('username')
        .eq('id', user.id)
        .single();

    return data['username'];
  }
}
