import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/story_tokens.dart';
import '../../core/theme/story_text_styles.dart';
import '../../services/auth_service.dart';
import '../../widgets/backgrounds/grid_bg.dart';
import '../../widgets/backgrounds/mesh_blobs.dart';
import '../../services/restore_service.dart';

class AuthScreen extends StatefulWidget {
  final VoidCallback onSuccess;
  const AuthScreen({super.key, required this.onSuccess});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLogin = true;
  bool _loading = false;
  String? _error;

  final _emailCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _nameCtrl     = TextEditingController();
  bool _obscure       = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() { _loading = true; _error = null; });

    try {
      if (_isLogin) {
        await AuthService.signIn(
          email: _emailCtrl.text.trim(),
          password: _passwordCtrl.text.trim(),
        );
        // Restaurer les données depuis Supabase après login
        await RestoreService.restoreAll();
        await AuthService.syncProfileToLocal();
      } else {
        await AuthService.signUp(
          email: _emailCtrl.text.trim(),
          password: _passwordCtrl.text.trim(),
          name: _nameCtrl.text.trim().isEmpty ? 'Écrivain' : _nameCtrl.text.trim(),
        );
      }
      if (mounted) widget.onSuccess();
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _resetPassword() async {
    if (_emailCtrl.text.trim().isEmpty) {
      setState(() => _error = 'Entre ton email pour réinitialiser ton mot de passe.');
      return;
    }
    await AuthService.resetPassword(_emailCtrl.text.trim());
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Email de réinitialisation envoyé !',
              style: StoryText.sans(size: 13, color: C.text)),
          backgroundColor: C.surface,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const GridBg(opacity: 0.20),
        const MeshBlobs(),
        Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(28, 40, 28, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),

                  // Logo / titre
                  Text('✦', style: TextStyle(fontSize: 40, color: C.primary)),
                  const SizedBox(height: 16),
                  Text(
                    _isLogin ? 'Bon retour !' : 'Crée ton compte',
                    style: StoryText.serif(size: 32, weight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _isLogin
                        ? 'Connecte-toi pour accéder à ton atelier.'
                        : 'Rejoins StoryBlocks et commence à écrire.',
                    style: StoryText.sans(size: 14, color: C.textMuted, style: FontStyle.italic),
                  ),
                  const SizedBox(height: 40),

                  // Champ nom (inscription seulement)
                  if (!_isLogin) ...[
                    _Field(
                      controller: _nameCtrl,
                      label: 'Ton prénom',
                      hint: 'Écrivain...',
                      icon: Icons.person_outline_rounded,
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Email
                  _Field(
                    controller: _emailCtrl,
                    label: 'Email',
                    hint: 'ton@email.com',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),

                  // Mot de passe
                  _Field(
                    controller: _passwordCtrl,
                    label: 'Mot de passe',
                    hint: '••••••••',
                    icon: Icons.lock_outline_rounded,
                    obscure: _obscure,
                    suffix: IconButton(
                      icon: Icon(
                        _obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                        color: C.textMuted,
                        size: 20,
                      ),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),

                  // Mot de passe oublié
                  if (_isLogin) ...[
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _resetPassword,
                        child: Text('Mot de passe oublié ?',
                            style: StoryText.mono(size: 11, color: C.textMuted)),
                      ),
                    ),
                  ],

                  const SizedBox(height: 8),

                  // Erreur
                  if (_error != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.redAccent.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.redAccent.withValues(alpha: 0.30)),
                      ),
                      child: Text(_error!,
                          style: StoryText.sans(size: 12, color: Colors.redAccent)),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Bouton principal
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: C.primary,
                        foregroundColor: C.bg,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: const StadiumBorder(),
                      ),
                      onPressed: _loading ? null : _submit,
                      child: _loading
                          ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: C.bg),
                      )
                          : Text(
                        _isLogin ? 'SE CONNECTER' : 'CRÉER MON COMPTE',
                        style: StoryText.mono(size: 13, color: C.bg),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Switcher login/signup
                  Center(
                    child: GestureDetector(
                      onTap: () => setState(() {
                        _isLogin = !_isLogin;
                        _error = null;
                      }),
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: _isLogin
                                  ? 'Pas encore de compte ? '
                                  : 'Déjà un compte ? ',
                              style: StoryText.sans(size: 13, color: C.textMuted),
                            ),
                            TextSpan(
                              text: _isLogin ? 'S\'inscrire' : 'Se connecter',
                              style: StoryText.sans(
                                  size: 13,
                                  color: C.primary,
                                  weight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Mode invité
                  Center(
                    child: TextButton(
                      onPressed: widget.onSuccess,
                      child: Text(
                        'Continuer sans compte →',
                        style: StoryText.mono(size: 11, color: C.textDim),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final bool obscure;
  final TextInputType? keyboardType;
  final Widget? suffix;

  const _Field({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.obscure = false,
    this.keyboardType,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: StoryText.mono(size: 10, color: C.textMuted, letterSpacing: 1)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: obscure,
          keyboardType: keyboardType,
          style: StoryText.sans(size: 14, color: C.text),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: StoryText.sans(size: 14, color: C.textDim),
            prefixIcon: Icon(icon, color: C.textMuted, size: 20),
            suffixIcon: suffix,
            filled: true,
            fillColor: C.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: C.primary.withValues(alpha: 0.50)),
            ),
          ),
        ),
      ],
    );
  }
}