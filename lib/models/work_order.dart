import 'package:dcpl_shared/models/statuses.dart';

/// A work order under a project (mirrors the backend `workOrders` view). The supervisor is
/// assigned here, not on the project. The parent project's name/number + client name and the
/// assigned supervisor's name are resolved (denormalized) by the backend.
class WorkOrder {
  const WorkOrder({
    required this.id,
    required this.project,
    required this.number,
    required this.name,
    required this.date,
    required this.status,
    this.description,
    this.supervisorId,
    this.createdAt,
    this.projectName,
    this.projectNumber,
    this.clientName,
    this.supervisorName,
  });

  factory WorkOrder.fromJson(Map<String, dynamic> json) => WorkOrder(
    id: json['id'] as String,
    project: json['project'] as String,
    number: json['number'] as String,
    name: json['name'] as String,
    date: json['date'] as String,
    status: WorkOrderStatus.fromWire(json['status'] as String),
    description: json['description'] as String?,
    supervisorId: json['supervisorId'] as String?,
    createdAt: json['createdAt'] as String?,
    projectName: json['projectName'] as String?,
    projectNumber: json['projectNumber'] as String?,
    clientName: json['clientName'] as String?,
    supervisorName: json['supervisorName'] as String?,
  );

  final String id;
  final String project;
  final String number;
  final String name;
  final String date;
  final WorkOrderStatus status;
  final String? description;

  /// Assigned supervisor's uid, or null until assigned.
  final String? supervisorId;
  final String? createdAt;

  // Denormalized for display (resolved by the backend).
  final String? projectName;
  final String? projectNumber;
  final String? clientName;
  final String? supervisorName;

  bool get isAssigned => supervisorId != null;
}
