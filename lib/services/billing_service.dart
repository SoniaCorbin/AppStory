import 'dart:async';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'auth_service.dart';

class BillingService {
  static const _premiumId = 'storyblocks_premium_monthly';
  static final _iap = InAppPurchase.instance;

  static StreamSubscription<List<PurchaseDetails>>? _subscription;
  static bool _isPremium = false;

  static bool get isPremium => _isPremium;

  /// Initialise le service billing — à appeler dans main.dart
  static Future<void> init() async {
    final available = await _iap.isAvailable();
    if (!available) return;

    _subscription = _iap.purchaseStream.listen(
      _onPurchaseUpdate,
      onDone: () => _subscription?.cancel(),
      onError: (_) {},
    );

    await _checkExistingPurchases();
  }

  static Future<void> _checkExistingPurchases() async {
    await _iap.restorePurchases();
  }

  static void _onPurchaseUpdate(List<PurchaseDetails> purchases) {
    for (final purchase in purchases) {
      if (purchase.productID == _premiumId) {
        if (purchase.status == PurchaseStatus.purchased ||
            purchase.status == PurchaseStatus.restored) {
          _isPremium = true;
          _iap.completePurchase(purchase);
        } else if (purchase.status == PurchaseStatus.error) {
          _isPremium = false;
        }
      }
    }
  }

  /// Lance l'achat de l'abonnement premium
  static Future<bool> buyPremium() async {
    final available = await _iap.isAvailable();
    if (!available) return false;

    final response = await _iap.queryProductDetails({_premiumId});
    if (response.productDetails.isEmpty) return false;

    final product = response.productDetails.first;
    final param = PurchaseParam(productDetails: product);
    return await _iap.buyNonConsumable(purchaseParam: param);
  }

  /// Restaure les achats existants
  static Future<void> restorePurchases() async {
    await _iap.restorePurchases();
  }

  /// Dispose — à appeler quand l'app se ferme
  static void dispose() {
    _subscription?.cancel();
  }
}