/// Response to a positive root/jailbreak/hook detection (plan PD-08):
/// warn in the UAT build, block in the PROD build. Detection itself stays
/// mandatory in both (ADR-0002).
class ThreatResponse {
  final String env;
  final void Function(String reason) warn;
  final void Function(String reason) block;

  const ThreatResponse({required this.env, required this.warn, required this.block});

  bool get blocks => env == 'prod';

  void onThreat(String reason) => blocks ? block(reason) : warn(reason);
}
