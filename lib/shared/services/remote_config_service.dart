import 'dart:async';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';

abstract class AppRemoteConfig extends ChangeNotifier {
  String get welcomeMessage;
  bool get newCheckoutEnabled;
  int get maxItems;
  Future<void> refresh();
}

class RemoteConfigService extends AppRemoteConfig {
  RemoteConfigService._();
  static final instance = RemoteConfigService._();

  @visibleForTesting
  RemoteConfigService.forTesting(FirebaseRemoteConfig remoteConfig)
    : _rc = remoteConfig;

  static const welcomeKey = 'welcome_message';
  static const newCheckoutKey = 'new_checkout_enabled';
  static const maxItemsKey = 'max_items';
  static const defaults = <String, Object>{
    welcomeKey: 'Olá!',
    newCheckoutKey: false,
    maxItemsKey: 10,
  };

  FirebaseRemoteConfig? _rc;
  StreamSubscription<RemoteConfigUpdate>? _subscription;
  Future<void>? _initialization;
  bool _disposed = false;

  Future<void> init() => _initialization ??= _initialize();

  Future<void> _initialize() async {
    try {
      final rc = _rc ??= FirebaseRemoteConfig.instance;
      await rc.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 10),
          minimumFetchInterval: kDebugMode
              ? Duration.zero
              : const Duration(hours: 1),
        ),
      );
      await rc.setDefaults(defaults);
      await refresh();
      if (!kIsWeb && !_disposed) {
        _subscription = rc.onConfigUpdated.listen(
          (_) => unawaited(_activate()),
          onError: (Object error) => _log(error),
        );
      }
    } catch (error) {
      _rc = null;
      _log(error);
    }
  }

  @override
  Future<void> refresh() async {
    try {
      await _rc?.fetchAndActivate();
    } catch (error) {
      _log(error);
    }
    if (!_disposed) notifyListeners();
  }

  Future<void> _activate() async {
    try {
      await _rc?.activate();
      if (!_disposed) notifyListeners();
    } catch (error) {
      _log(error);
    }
  }

  @override
  String get welcomeMessage =>
      _rc?.getString(welcomeKey) ?? defaults[welcomeKey] as String;
  @override
  bool get newCheckoutEnabled =>
      _rc?.getBool(newCheckoutKey) ?? defaults[newCheckoutKey] as bool;
  @override
  int get maxItems => _rc?.getInt(maxItemsKey) ?? defaults[maxItemsKey] as int;

  /// Distinguishes published values from local defaults during validation.
  void logDebugValues() {
    if (!kDebugMode) return;
    final rc = _rc;
    if (rc == null) {
      debugPrint('[RemoteConfig] Firebase indisponível; usando padrões locais.');
      return;
    }
    debugPrint('[RemoteConfig] fetchStatus=${rc.lastFetchStatus.name}');
    for (final key in defaults.keys) {
      final value = rc.getValue(key);
      debugPrint(
        '[RemoteConfig] $key=${value.asString()} source=${value.source.name}',
      );
    }
  }

  void _log(Object error) {
    if (kDebugMode) debugPrint('Remote Config indisponível: $error');
  }

  @override
  void dispose() {
    _disposed = true;
    unawaited(_subscription?.cancel());
    super.dispose();
  }
}
