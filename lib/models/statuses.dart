/// Per-item lifecycle status (mirrors the backend `materialRequests.status`).
/// `requested` / `processing` / `accepted` are **open** (not finalized); the rest are terminal.
enum MaterialRequestStatus {
  requested,
  processing,
  accepted,
  closed,
  declined,
  cancelled;

  /// Parses the backend wire value — the enum name matches it 1:1.
  static MaterialRequestStatus fromWire(String value) => values.byName(value);

  String get wire => name;

  bool get isOpen =>
      this == requested || this == processing || this == accepted;
  bool get isTerminal => !isOpen;
}

/// Work-order status (mirrors the backend `workOrders.status`).
/// `completed` / `cancelled` are terminal.
enum WorkOrderStatus {
  pending,
  active,
  completed,
  cancelled;

  static WorkOrderStatus fromWire(String value) => values.byName(value);

  String get wire => name;

  bool get isTerminal => this == completed || this == cancelled;
}

/// Project status (mirrors the backend `projects.status`).
enum ProjectStatus {
  active,
  completed;

  static ProjectStatus fromWire(String value) => values.byName(value);

  String get wire => name;
}
