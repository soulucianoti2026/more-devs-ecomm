import 'package:more_devs_do_zero/shared/app_analytics.dart';

/// Reune o contexto da tela e os metodos de analytics para uso nas paginas.
///
/// Utilize `with AnalyticsMixin` e implemente [screenName] com o nome ou a
/// rota da tela, preservada no parametro screen_name.
mixin AnalyticsMixin {
  String get screenName;

  AppAnalytics get analytics => AppAnalytics.instance;

  /// Chamar uma vez no initState, nunca no build.
  Future<void> logScreenView() {
    return analytics.logScreenView(screenName: screenName);
  }

  /// Associa o clique ao contexto da tela atual.
  Future<void> logButtonClick(String buttonName) {
    return analytics.logButtonClick(buttonName, screenName: screenName);
  }
}
