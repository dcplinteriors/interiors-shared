import 'package:dcpl_shared/models/statuses.dart';
import 'package:dcpl_shared/models/work_order.dart';

/// A project (mirrors the backend `projects` view). Created by an admin together with its work
/// orders. Supervisors are assigned at the work-order level, not here, so a project has no
/// supervisor of its own.
///
/// `workOrderCount` is present in the list response; `workOrders` in the detail / create response.
class Project {
  const Project({
    required this.id,
    required this.number,
    required this.name,
    required this.clientName,
    required this.projectEngineer,
    required this.status,
    this.createdAt,
    this.workOrderCount,
    this.workOrders = const [],
  });

  factory Project.fromJson(Map<String, dynamic> json) => Project(
    id: json['id'] as String,
    number: json['number'] as String,
    name: json['name'] as String,
    clientName: json['clientName'] as String,
    projectEngineer: json['projectEngineer'] as String,
    status: ProjectStatus.fromWire(json['status'] as String),
    createdAt: json['createdAt'] as String?,
    workOrderCount: json['workOrderCount'] as int?,
    workOrders:
        (json['workOrders'] as List?)
            ?.map((e) => WorkOrder.fromJson(e as Map<String, dynamic>))
            .toList() ??
        const [],
  );

  final String id;
  final String number;
  final String name;
  final String clientName;
  final String projectEngineer;
  final ProjectStatus status;
  final String? createdAt;

  /// Count of the project's work orders (list response only).
  final int? workOrderCount;

  /// The project's work orders (detail / create response).
  final List<WorkOrder> workOrders;
}
