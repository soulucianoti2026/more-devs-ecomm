import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:more_devs_do_zero/features/home/models/products_model.dart';
import 'package:more_devs_do_zero/features/shoppingcart/shopping_cart_controller.dart';
import 'package:more_devs_do_zero/shared/app_analytics.dart';

class RecordingAnalytics implements FirebaseAnalytics {
  final events = <Map<String, Object?>>[];
  bool fail = false;

  @override
  Future<void> logEvent({
    required String name,
    Map<String, Object>? parameters,
    List<AnalyticsEventItem>? items,
    AnalyticsCallOptions? callOptions,
  }) async {
    if (fail) throw StateError('SDK unavailable');
    events.add({
      'name': name,
      'parameters': parameters,
      'items': items?.map((item) => item.asMap()).toList(),
    });
  }

  @override
  Future<void> logScreenView({
    String? screenClass,
    String? screenName,
    Map<String, Object>? parameters,
    AnalyticsCallOptions? callOptions,
  }) async {
    if (fail) throw StateError('SDK unavailable');
    events.add({'name': 'screen_view', 'screen_name': screenName});
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  final product = Products(
    id: 'p1',
    name: 'Arroz',
    brand: 'Marca',
    category: 'Alimentos',
    imageUrl: '',
    price: 12.5,
  );

  test(
    'Purchase preserves cart quantities, subtotal, total and transaction',
    () async {
      final firebase = RecordingAnalytics();
      final analytics = AppAnalytics.forTesting(firebase);
      final items = [
        CartProduct(product: product, quantity: 3, subtotal: 37.5),
      ];
      await analytics.logBeginCheckout(items, 37.5);
      await analytics.logPurchase(items, 37.5, transactionId: 'order-1');
      items.clear();
      expect(firebase.events.map((e) => e['name']), [
        'begin_checkout',
        'purchase',
      ]);
      expect(firebase.events.last['parameters'], {
        'value': 37.5,
        'currency': 'BRL',
        'transaction_id': 'order-1',
      });
      final item = (firebase.events.last['items'] as List).single as Map;
      expect(item['item_id'], 'p1');
      expect(item['quantity'], 3);
      expect(item['subtotal'], 37.5);
    },
  );

  test('Product events carry list context and removed quantity', () async {
    final firebase = RecordingAnalytics();
    final analytics = AppAnalytics.forTesting(firebase);
    await analytics.logViewItem(product, 'home');
    await analytics.logAddToCart(product);
    await analytics.logRemoveFromCart(product, 4);
    expect((firebase.events[0]['parameters'] as Map)['item_list_name'], 'home');
    expect((firebase.events[1]['parameters'] as Map)['quantity'], 1);
    expect((firebase.events[2]['parameters'] as Map)['quantity'], 4);
    expect((firebase.events[2]['parameters'] as Map)['value'], 50);
  });

  test(
    'Screen views keep the route specified in the tracking document',
    () async {
      final firebase = RecordingAnalytics();
      await AppAnalytics.forTesting(
        firebase,
      ).logScreenView(screenName: '/shopping-cart');
      expect(firebase.events.single['screen_name'], '/shopping-cart');
    },
  );

  test('SDK failures never interrupt the shopping journey', () async {
    final firebase = RecordingAnalytics()..fail = true;
    final analytics = AppAnalytics.forTesting(firebase);
    await analytics.logLogin();
    await analytics.logAddToCart(product);
    await analytics.logScreenView(screenName: '/home');
    expect(firebase.events, isEmpty);
  });
  test('Screen names normalize app routes', () {
    expect(AppAnalytics.screenNameForRoute('/login'), 'login');
    expect(AppAnalytics.screenNameForRoute('/shopping-cart'), 'shopping_cart');
    expect(
      AppAnalytics.screenNameForRoute('/products-by-category'),
      'products_by_category',
    );
  });

  test('Screen names exclude query parameters and fragments', () {
    expect(
      AppAnalytics.screenNameForRoute('/orders?token=private#details'),
      'orders',
    );
  });

  test('Unnamed routes do not produce screen events', () {
    expect(AppAnalytics.screenNameForRoute(null), isNull);
    expect(AppAnalytics.screenNameForRoute(''), isNull);
    expect(AppAnalytics.screenNameForRoute('/'), isNull);
  });

  test('Logging is safe before Firebase is configured', () async {
    await AppAnalytics.instance.logScreenView(screenName: '/login');
    await AppAnalytics.instance.logButtonClick('login');
    await AppAnalytics.instance.logButtonClick('login', screenName: '/login');
  });
}
