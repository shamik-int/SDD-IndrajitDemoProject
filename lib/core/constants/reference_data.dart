/// Placeholder reference data for department/location/role selection.
///
/// There is no backend or HR master-data service in this project (ADR-0004)
/// — these static lists stand in for what would normally be fetched from
/// one. Replace with a real source (or wire a Plan-stage decision for one)
/// if this ever needs to reflect the organisation's actual structure.
class ReferenceOption {
  final String id;
  final String label;

  const ReferenceOption(this.id, this.label);
}

class ReferenceData {
  ReferenceData._();

  static const departments = [
    ReferenceOption('dept-eng', 'Engineering'),
    ReferenceOption('dept-sales', 'Sales'),
    ReferenceOption('dept-hr', 'Human Resources'),
    ReferenceOption('dept-fin', 'Finance'),
    ReferenceOption('dept-ops', 'Operations'),
  ];

  static const locations = [
    ReferenceOption('loc-blr', 'Bengaluru'),
    ReferenceOption('loc-mum', 'Mumbai'),
    ReferenceOption('loc-del', 'Delhi NCR'),
    ReferenceOption('loc-hyd', 'Hyderabad'),
    ReferenceOption('loc-pun', 'Pune'),
  ];

  static const roles = [
    ReferenceOption('role-swe', 'Software Engineer'),
    ReferenceOption('role-sse', 'Senior Software Engineer'),
    ReferenceOption('role-tl', 'Team Lead'),
    ReferenceOption('role-mgr', 'Manager'),
    ReferenceOption('role-analyst', 'Business Analyst'),
  ];
}
