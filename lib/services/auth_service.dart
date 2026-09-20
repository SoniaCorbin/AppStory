import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';

class AuthService {
  static final _client = Supabase.instance.client;

  // Utilisateur courant
  static User? get currentUser => _client.auth.currentUser;
  static bool get isLoggedIn => currentUser != null;

  // Inscription
  static Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
      data: {'name': name},
    );

    // Mettre à jour le profil avec le nom
    if (response.user != null) {
      await _client.from('profiles').upsert({
        'id': response.user!.id,
        'name': name,
      });
    }

    return response;
  }

  // Connexion
  static Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  // Déconnexion
  static Future<void> signOut() async {
    await _client.auth.signOut();
  }

  // Réinitialisation mot de passe
  static Future<void> resetPassword(String email) async {
    await _client.auth.resetPasswordForEmail(email);
  }

  // Profil utilisateur
  static Future<Map<String, dynamic>?> getProfile() async {
    if (currentUser == null) return null;
    final response = await _client
        .from('profiles')
        .select()
        .eq('id', currentUser!.id)
        .single();
    return response;
  }

   // Sync le nom du profil Supabase → Hive local
  static Future<void> syncProfileToLocal() async {
    try {
      final profile = await getProfile();
      if (profile != null && profile['name'] != null) {
        final box = Hive.box('settings');
        await box.put('profile_name', profile['name']);
      }
    } catch (_) {}
  }
  // Mettre à jour le nom
  static Future<void> updateName(String name) async {
    if (currentUser == null) return;
    await _client.from('profiles').update({'name': name}).eq(
        'id', currentUser!.id);
  }

  // Compteur de générations IA
  static Future<int> getGenerationCount() async {
    if (currentUser == null) return 0;
    final now = DateTime.now();
    final firstOfMonth = DateTime(now.year, now.month, 1).toIso8601String();
    final response = await _client
        .from('ai_generations')
        .select()
        .eq('user_id', currentUser!.id)
        .gte('created_at', firstOfMonth);
    return (response as List).length;
  }

  // Enregistrer une génération
  static Future<void> recordGeneration() async {
    if (currentUser == null) return;
    await _client.from('ai_generations').insert({
      'user_id': currentUser!.id,
    });
  }

  // Vérifier si l'utilisateur peut générer (max 5/mois gratuit)
  static Future<bool> canGenerate({bool isPremium = false}) async {
    if (isPremium) return true;
    final count = await getGenerationCount();
    return count < 5;
  }
}