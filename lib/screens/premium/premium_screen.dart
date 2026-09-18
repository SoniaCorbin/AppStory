import 'package:flutter/material.dart';
import '../../core/constants/story_tokens.dart';
import '../../core/theme/story_text_styles.dart';
import '../../services/billing_service.dart';
import '../../widgets/backgrounds/grid_bg.dart';
import '../../widgets/backgrounds/mesh_blobs.dart';

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  bool _loading = false;
  String? _error;

  Future<void> _buyPremium() async {
    setState(() { _loading = true; _error = null; });
    try {
      final success = await BillingService.buyPremium();
      if (!success && mounted) {
        setState(() => _error = 'Achat annulé ou indisponible.');
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _restore() async {
    setState(() { _loading = true; _error = null; });
    try {
      await BillingService.restorePurchases();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Achats restaurés !',
                style: StoryText.sans(size: 13, color: C.text)),
            backgroundColor: C.surface,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
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
          appBar: AppBar(
            backgroundColor: C.bg.withValues(alpha: 0.92),
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.close, color: C.text),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text('Premium', style: StoryText.serif(size: 17, weight: FontWeight.w700)),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(28, 32, 28, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Badge premium
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [C.accent, C.primary],
                    ),
                  ),
                  child: const Center(
                    child: Text('✦', style: TextStyle(fontSize: 36, color: Colors.white)),
                  ),
                ),
                const SizedBox(height: 24),

                Text('StoryBlocks Premium',
                    style: StoryText.serif(size: 26, weight: FontWeight.w700),
                    textAlign: TextAlign.center),
                const SizedBox(height: 8),
                Text('Libère tout ton potentiel créatif.',
                    style: StoryText.sans(size: 14, color: C.textMuted, style: FontStyle.italic),
                    textAlign: TextAlign.center),
                const SizedBox(height: 40),

                // Fonctionnalités
                _FeatureRow(icon: '✦', text: 'Générations IA illimitées'),
                _FeatureRow(icon: '💎', text: 'Sync cloud prioritaire'),
                _FeatureRow(icon: '📄', text: 'Pages et histoires illimitées'),
                _FeatureRow(icon: '🔥', text: 'Support prioritaire'),
                _FeatureRow(icon: '🚀', text: 'Accès aux nouvelles fonctionnalités en avant-première'),

                const SizedBox(height: 40),

                // Prix
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: C.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: C.accent.withValues(alpha: 0.30)),
                  ),
                  child: Column(
                    children: [
                      Text('2,99 \$',
                          style: StoryText.serif(size: 42, weight: FontWeight.w700, color: C.accent)),
                      Text('par mois · annulable en tout temps',
                          style: StoryText.mono(size: 11, color: C.textMuted)),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Erreur
                if (_error != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(_error!, style: StoryText.sans(size: 12, color: Colors.redAccent)),
                  ),
                  const SizedBox(height: 16),
                ],

                // Bouton acheter
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: C.accent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: const StadiumBorder(),
                    ),
                    onPressed: _loading ? null : _buyPremium,
                    child: _loading
                        ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                        : Text('PASSER AU PREMIUM',
                        style: StoryText.mono(size: 13, color: Colors.white)),
                  ),
                ),
                const SizedBox(height: 12),

                // Restaurer
                TextButton(
                  onPressed: _loading ? null : _restore,
                  child: Text('Restaurer mes achats',
                      style: StoryText.mono(size: 11, color: C.textMuted)),
                ),
                const SizedBox(height: 8),
                Text(
                  'L\'abonnement se renouvelle automatiquement. Annulable à tout moment depuis les paramètres Google Play.',
                  style: StoryText.sans(size: 10, color: C.textDim, style: FontStyle.italic),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final String icon;
  final String text;

  const _FeatureRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 14),
          Expanded(
            child: Text(text, style: StoryText.sans(size: 14, color: C.text)),
          ),
        ],
      ),
    );
  }
}