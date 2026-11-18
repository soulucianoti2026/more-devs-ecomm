import 'dart:async';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:more_devs_do_zero/shared/services/remote_config_service.dart';

class FakeRemoteConfig implements FirebaseRemoteConfig {
  final values = <String, dynamic>{};
  final updates = StreamController<RemoteConfigUpdate>.broadcast();
  Map<String, dynamic> remote = {};
  bool offline = false;
  @override
  late RemoteConfigSettings settings;

  @override
  Future<void> setConfigSettings(RemoteConfigSettings value) async {
    settings = value;
  }

  @override
  Future<void> setDefaults(Map<String, dynamic> defaults) async {
    defaults.forEach((key, value) => values.putIfAbsent(key, () => value));
  }

  @override
  Future<bool> fetchAndActivate() async {
    if (offline) throw StateError('offline');
    values.addAll(remote);
    return true;
  }

  @override
  Future<bool> activate() async {
    values.addAll(remote);
    return true;
  }

  @override
  Stream<RemoteConfigUpdate> get onConfigUpdated => updates.stream;
  @override
  String getString(String key) => values[key] as String;
  @override
  bool getBool(String key) => values[key] as bool;
  @override
  int getInt(String key) => values[key] as int;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  test('Offline first launch uses safe defaults and short timeout', () async {
    final sdk = FakeRemoteConfig()..offline = true;
    final service = RemoteConfigService.forTesting(sdk);
    await service.init();
    expect(service.welcomeMessage, 'Olá!');
    expect(service.newCheckoutEnabled, isFalse);
    expect(service.maxItems, 10);
    expect(sdk.settings.fetchTimeout, const Duration(seconds: 10));
    expect(sdk.settings.minimumFetchInterval, Duration.zero);
    service.dispose();
    await sdk.updates.close();
  });

  test(
    'Remote values survive failed refresh and flag can be disabled',
    () async {
      final sdk = FakeRemoteConfig()
        ..remote = {
          'welcome_message': 'Bem-vindo',
          'new_checkout_enabled': true,
          'max_items': 20,
        };
      final service = RemoteConfigService.forTesting(sdk);
      await service.init();
      expect(service.newCheckoutEnabled, isTrue);
      sdk.offline = true;
      await service.refresh();
      expect(service.welcomeMessage, 'Bem-vindo');
      expect(service.maxItems, 20);
      expect(service.newCheckoutEnabled, isTrue);
      sdk.offline = false;
      sdk.remote['new_checkout_enabled'] = false;
      await service.refresh();
      expect(service.newCheckoutEnabled, isFalse);
      service.dispose();
      await sdk.updates.close();
    },
  );

  test(
    'Real-time activation notifies UI and subscription is disposed',
    () async {
      final sdk = FakeRemoteConfig();
      final service = RemoteConfigService.forTesting(sdk);
      await service.init();
      var notifications = 0;
      service.addListener(() => notifications++);
      sdk.remote = {'welcome_message': 'Atualizado'};
      sdk.updates.add(RemoteConfigUpdate({'welcome_message'}));
      await Future<void>.delayed(Duration.zero);
      expect(service.welcomeMessage, 'Atualizado');
      expect(notifications, 1);
      service.dispose();
      expect(sdk.updates.hasListener, isFalse);
      await sdk.updates.close();
    },
  );
}
