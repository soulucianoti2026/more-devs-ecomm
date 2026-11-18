import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:more_devs_do_zero/features/home/models/products_model.dart';
import 'package:more_devs_do_zero/features/shoppingcart/shopping_cart_controller.dart';

class AppAnalytics {
  AppAnalytics._();

  static final AppAnalytics instance = AppAnalytics._();

  FirebaseAnalytics? _firebase;
  FirebaseAnalyticsObserver? observer;

  @visibleForTesting
  AppAnalytics.forTesting(FirebaseAnalytics firebase) : _firebase = firebase;

  Future<void> _event(
    String name, [
    Map<String, Object>? parameters,
    List<AnalyticsEventItem>? items,
  ]) async {
    try {
      await _firebase?.logEvent(
        name: name,
        parameters: parameters,
        items: items,
      );
    } catch (_) {
      _debugLog('Falha ao registrar $name');
    }
  }

  Future<void> logLogin() => _event('login', {'method': 'email'});
  Future<void> logLoginFailed(String reason) =>
      _event('login_failed', {'reason': reason});
  Future<void> logPasswordResetRequest() => _event('password_reset_request');
  Future<void> logSignUp() => _event('sign_up', {'method': 'email'});
  Future<void> logSignUpFailed(String type) =>
      _event('sign_up_failed', {'error_type': type});
  Future<void> logViewItemList(String listName) =>
      _event('view_item_list', {'item_list_name': listName});
  Future<void> logSearch(String term, String listName, int count) => _event(
    'search',
    {'search_term': term, 'item_list_name': listName, 'results_count': count},
  );
  Future<void> logFilterBrand(String brand, String listName, int count) =>
      _event('filter_brand', {
        'item_brand': brand,
        'item_list_name': listName,
        'results_count': count,
      });
  Future<void> logLoadError(String section) =>
      _event('load_error', {'section': section});

  Map<String, Object> _product(Products product) => {
    'item_name': product.name,
    'item_brand': product.brand,
    'item_category': product.category,
    'price': product.price,
    'currency': 'BRL',
  };

  AnalyticsEventItem _item(Products product, int quantity) =>
      AnalyticsEventItem(
        itemId: product.id.isEmpty ? product.name : product.id,
        itemName: product.name,
        itemBrand: product.brand,
        itemCategory: product.category,
        price: product.price,
        quantity: quantity,
        parameters: {'subtotal': product.price * quantity},
      );

  Future<void> logViewItem(Products product, String listName) => _event(
    'view_item',
    {..._product(product), 'item_list_name': listName},
    [_item(product, 1)],
  );
  Future<void> logAddToCart(Products product) => _event(
    'add_to_cart',
    {..._product(product), 'quantity': 1, 'value': product.price},
    [_item(product, 1)],
  );
  Future<void> logRemoveFromCart(Products product, int quantity) => _event(
    'remove_from_cart',
    {
      ..._product(product),
      'quantity': quantity,
      'value': product.price * quantity,
    },
    [_item(product, quantity)],
  );
  Future<void> logViewCart(List<CartProduct> items, double total) =>
      _cartEvent('view_cart', items, total);
  Future<void> logBeginCheckout(List<CartProduct> items, double total) =>
      _cartEvent('begin_checkout', items, total);
  Future<void> logPurchase(
    List<CartProduct> items,
    double total, {
    required String transactionId,
  }) => _cartEvent('purchase', items, total, transactionId: transactionId);

  Future<void> _cartEvent(
    String name,
    List<CartProduct> items,
    double total, {
    String? transactionId,
  }) => _event(name, {
    'value': total,
    'currency': 'BRL',
    'transaction_id': ?transactionId,
  }, items.map((item) => _item(item, item.quantity)).toList());

  Future<void> initialize() async {
    if (_firebase != null) return;
    try {
      if (Firebase.apps.isEmpty) await Firebase.initializeApp();
      final analytics = FirebaseAnalytics.instance;
      observer = FirebaseAnalyticsObserver(
        analytics: analytics,
        nameExtractor: (settings) => screenNameForRoute(settings.name),
      );
      _firebase = analytics;
    } catch (error) {
      // Analytics must not prevent startup when Firebase is not configured.
      _debugLog('Firebase Analytics indisponível: $error');
    }
  }

  static String? screenNameForRoute(String? routeName) {
    if (routeName == null) return null;
    final screenName = Uri.parse(routeName).path
        .split('/')
        .where((segment) => segment.isNotEmpty)
        .join('_')
        .replaceAll('-', '_');
    return screenName.isEmpty ? null : screenName;
  }

  Future<void> logScreenView({required String screenName}) async {
    if (screenName.isEmpty) return;
    try {
      await _firebase?.logScreenView(screenName: screenName);
    } catch (_) {
      _debugLog('Falha ao registrar screen_view');
    }
  }

  Future<void> logButtonClick(String buttonName, {String? screenName}) async {
    final name = screenNameForRoute(screenName);
    final parameters = <String, Object>{
      'button_name': buttonName,
      'screen_name': ?name,
    };
    _debugLog('Button click: $parameters');
    await _event('button_click', parameters);
  }

  void _debugLog(String message) {
    if (kDebugMode) debugPrint('[AppAnalytics] $message');
  }
}
