/// Response to a positive root/jailbreak/hook detection (plan PD-08):
/// warn in the UAT build, block in the PROD build. Detection itself stays
/// mandatory in both (ADR-0002).
///
/// Detection starts before the app can navigate, so a threat reported early
/// is held until [markReady] and handled then (G2-08).
class ThreatResponse {
  final String env;
  final void Function(String reason) warn;
  final void Function(String reason) block;

  ThreatResponse({required this.env, required this.warn, required this.block});

  bool _ready = false;
  final List<String> _held = [];

  bool get blocks => env == 'prod';

  /// The build's environment. An explicit `--dart-define=ENV=...` wins. A
  /// release build without one is `prod`, so a missing define fails closed
  /// (blocks) rather than open (warns).
  static String resolveEnv(String defined, {required bool releaseMode}) =>
      defined.isNotEmpty ? defined : (releaseMode ? 'prod' : 'uat');

  void onThreat(String reason) {
    if (!_ready) {
      _held.add(reason);
      return;
    }
    blocks ? block(reason) : warn(reason);
  }

  /// Called once the app can navigate and show messages.
  void markReady() {
    _ready = true;
    final held = [..._held];
    _held.clear();
    held.forEach(onThreat);
  }
}
