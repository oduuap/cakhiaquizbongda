import 'package:firebase_remote_config/firebase_remote_config.dart';

/// Keys for all feature flags in Firebase Remote Config.
/// Set these in Firebase Console → Remote Config.
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

  /// [bool] Enable streak tracking on home screen
  static const String enableStreak = 'enable_streak';

  /// [bool] Enable accuracy % on home screen
  static const String enableAccuracy = 'enable_accuracy';

  /// [bool] Enable last game card on home screen
  static const String enableLastGame = 'enable_last_game';

  /// [bool] Show debug flag panel on splash screen
  static const String showFlagPanel = 'show_flag_panel';
}

class RemoteConfigService {
  RemoteConfigService._();

  static RemoteConfigService? _instance;
  static RemoteConfigService get instance =>
      _instance ??= RemoteConfigService._();

  late final FirebaseRemoteConfig _rc;

  /// Default values — used before Remote Config is fetched.
  static const Map<String, dynamic> _defaults = {
    FeatureFlags.maintenanceMode: false,
    FeatureFlags.maintenanceUrl: 'https://cakhiafc.com/maintenance',
    FeatureFlags.splashMinWaitMs: 1500,
    FeatureFlags.showExplanation: true,
    FeatureFlags.enableStreak: true,
    FeatureFlags.enableAccuracy: true,
    FeatureFlags.enableLastGame: true,
    FeatureFlags.showFlagPanel: false,
  };

  Future<void> initialize() async {
    _rc = FirebaseRemoteConfig.instance;

    await _rc.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: const Duration(seconds: 10),
      minimumFetchInterval: const Duration(hours: 1),
    ));

    await _rc.setDefaults(_defaults);

    // Fetch & activate — silent fail so app still works offline
    try {
      await _rc.fetchAndActivate();
    } catch (_) {}
  }

  // ── Typed getters ──────────────────────────────────────────────

  bool get maintenanceMode => _rc.getBool(FeatureFlags.maintenanceMode);
  String get maintenanceUrl => _rc.getString(FeatureFlags.maintenanceUrl);
  int get splashMinWaitMs => _rc.getInt(FeatureFlags.splashMinWaitMs);
  bool get showExplanation => _rc.getBool(FeatureFlags.showExplanation);
  bool get enableStreak => _rc.getBool(FeatureFlags.enableStreak);
  bool get enableAccuracy => _rc.getBool(FeatureFlags.enableAccuracy);
  bool get enableLastGame => _rc.getBool(FeatureFlags.enableLastGame);
  bool get showFlagPanel => _rc.getBool(FeatureFlags.showFlagPanel);

  /// Returns all flags as a list for display on splash panel.
  List<FlagInfo> allFlags() => [
        FlagInfo(
          label: '🔧 Maintenance mode',
          value: maintenanceMode ? 'BẬT → mở URL' : 'TẮT → vào game',
          enabled: maintenanceMode,
        ),
        FlagInfo(
          label: '⏱ Thời gian chờ splash',
          value: '${splashMinWaitMs}ms',
          enabled: splashMinWaitMs > 0,
        ),
        FlagInfo(
          label: '💬 Giải thích đáp án',
          value: showExplanation ? 'BẬT' : 'TẮT',
          enabled: showExplanation,
        ),
        FlagInfo(
          label: '🔥 Streak',
          value: enableStreak ? 'BẬT' : 'TẮT',
          enabled: enableStreak,
        ),
        FlagInfo(
          label: '🎯 Tỷ lệ chính xác',
          value: enableAccuracy ? 'BẬT' : 'TẮT',
          enabled: enableAccuracy,
        ),
        FlagInfo(
          label: '🏆 Trận gần nhất',
          value: enableLastGame ? 'BẬT' : 'TẮT',
          enabled: enableLastGame,
        ),
      ];
}

class FlagInfo {
  final String label;
  final String value;
  final bool enabled;

  const FlagInfo({
    required this.label,
    required this.value,
    required this.enabled,
  });
}
