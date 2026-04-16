import 'package:firebase_remote_config/firebase_remote_config.dart';

class FeatureFlags {
  const FeatureFlags._();

  /// [bool] Maintenance mode — true = open [maintenanceUrl], false = enter game
  static const String maintenanceMode = 'maintenance_mode';

  /// [String] URL to open when maintenance mode is ON
  static const String maintenanceUrl = 'maintenance_url';

  /// [int] Minimum splash wait time in ms (0 = no artificial wait)
  static const String splashMinWaitMs = 'splash_min_wait_ms';

  /// [bool] Show explanation box after answering a question
  static const String showExplanation = 'show_explanation';
}

class RemoteConfigService {
  RemoteConfigService._();

  static RemoteConfigService? _instance;
  static RemoteConfigService get instance =>
      _instance ??= RemoteConfigService._();

  late final FirebaseRemoteConfig _rc;

  static const Map<String, dynamic> _defaults = {
    FeatureFlags.maintenanceMode: false,
    FeatureFlags.maintenanceUrl: 'https://cakhiafc.com/maintenance',
    FeatureFlags.splashMinWaitMs: 1500,
    FeatureFlags.showExplanation: true,
  };

  Future<void> initialize() async {
    _rc = FirebaseRemoteConfig.instance;

    await _rc.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: const Duration(seconds: 10),
      minimumFetchInterval: const Duration(hours: 1),
    ));

    await _rc.setDefaults(_defaults);

    try {
      await _rc.fetchAndActivate();
    } catch (_) {}
  }

  bool get maintenanceMode => _rc.getBool(FeatureFlags.maintenanceMode);
  String get maintenanceUrl => _rc.getString(FeatureFlags.maintenanceUrl);
  int get splashMinWaitMs => _rc.getInt(FeatureFlags.splashMinWaitMs);
  bool get showExplanation => _rc.getBool(FeatureFlags.showExplanation);
}
