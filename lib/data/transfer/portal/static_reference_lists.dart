import '../../../core/constants/reference_data.dart';
import '../../../domain/transfer/portal/portal_contracts.dart';

/// D-03 in V1 (plan PD-03): the static demo lists (A-03).
class StaticReferenceLists implements ReferenceLists {
  const StaticReferenceLists();

  static List<ReferenceItem> _items(List<ReferenceOption> options) =>
      [for (final o in options) ReferenceItem(o.id, o.label)];

  @override
  List<ReferenceItem> departments() => _items(ReferenceData.departments);

  @override
  List<ReferenceItem> locations() => _items(ReferenceData.locations);

  @override
  List<ReferenceItem> roles() => _items(ReferenceData.roles);
}
