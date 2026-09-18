/// Matches the spec's Status Definitions
/// (`specs/employee-internal-transfer.spec.md`).
enum TransferRequestStatus {
  pendingManagerApproval,
  pendingHrValidation,
  pendingDownstreamUpdates,
  completed,
  rejectedByManager,
  rejectedByHr,
}

extension TransferRequestStatusX on TransferRequestStatus {
  /// Terminal states never count toward the single-in-flight-request rule
  /// (spec AC2) and never have a pending stakeholder.
  bool get isTerminal =>
      this == TransferRequestStatus.completed ||
      this == TransferRequestStatus.rejectedByManager ||
      this == TransferRequestStatus.rejectedByHr;

  bool get isNonTerminal => !isTerminal;
}
