import 'package:flutter_test/flutter_test.dart';
import 'package:more_devs_do_zero/features/home/controllers/products_by_category_controller.dart';
import 'package:more_devs_do_zero/features/home/models/products_model.dart';
import 'package:more_devs_do_zero/shared/app_analytics.dart';
import 'package:more_devs_do_zero/shared/exceptions/auth_exeception.dart';
import 'package:more_devs_do_zero/shared/exceptions/signup_exception.dart';
import 'package:more_devs_do_zero/shared/services/auth_service.dart';
import 'package:more_devs_do_zero/shared/services/store_service.dart';
import 'app_analytics_test.dart' show RecordingAnalytics;

class Catalog extends StoreService {
  Catalog() : super(AuthService());
  @override
  Future<List<Products>> getProducts({
    String? categoryId,
    String? search,
    String? brand,
  }) async => [];
  @override
  Future<List<String>> getBrands(String categoryId) async => [];
}

void main() {
  testWidgets('Search emits only after one second and is cancelled on exit', (
    tester,
  ) async {
    final firebase = RecordingAnalytics();
    final api = Catalog();
    final controller = ProductsByCategoryController(
      api,
      analytics: AppAnalytics.forTesting(firebase),
    );
    await controller.getProductsByCategory('c1', listName: 'Frutas');
    expect(firebase.events.single['parameters'], {'item_list_name': 'Frutas'});
    firebase.events.clear();
    controller.searchProducts('ma');
    await tester.pump(const Duration(milliseconds: 700));
    controller.searchProducts('maca');
    await tester.pump(const Duration(milliseconds: 999));
    expect(firebase.events, isEmpty);
    await tester.pump(const Duration(milliseconds: 1));
    expect(firebase.events.single['name'], 'search');
    expect(firebase.events.single['parameters'], {
      'search_term': 'maca',
      'item_list_name': 'Frutas',
      'results_count': 0,
    });
    controller.searchProducts('banana');
    controller.cancelPendingSearch();
    await tester.pump(const Duration(seconds: 2));
    expect(firebase.events, hasLength(1));
    controller.dispose();
    api.auth.dispose();
  });

  test('Signup error retains UI message and exposes only a stable type', () {
    final error = SignupException.fromAuth(
      const AuthExeception('Email privado@example.com em uso', statusCode: 409),
    );
    expect(error.type, SignupExceptionType.emailAlreadyInUse);
    expect(error.message, 'Email privado@example.com em uso');
    expect(error.type.name, isNot(contains('@')));
  });
}
