import 'package:dcpl_shared/models/statuses.dart';

/// Storage object paths for an item's attachments (resolved to signed URLs on demand
/// via the backend `/uploads/download-url` endpoint — clients never touch Storage directly).
class Attachments {
  const Attachments({this.photos = const [], this.audio});

  factory Attachments.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const Attachments();
    return Attachments(
      photos:
          (json['photos'] as List?)?.map((e) => e as String).toList() ??
          const [],
      audio: json['audio'] as String?,
    );
  }

  /// Up to 3 photo object paths.
  final List<String> photos;

  /// Optional single audio clip object path.
  final String? audio;

  bool get isEmpty => photos.isEmpty && audio == null;
  bool get isNotEmpty => !isEmpty;

  /// Serializes only the present fields — omits empty photos / null audio so a
  /// bare attachment block isn't sent on submit.
  Map<String, dynamic> toJson() => {
    if (photos.isNotEmpty) 'photos': photos,
    if (audio != null) 'audio': audio,
  };
}

/// A material request — one requested item under a **work order** (mirrors the backend
/// `materialRequests` view). Several items submitted together share a `batchId`; each is acted on
/// independently. The admin fills `expectedDate`/`vendor`/`poNumber?`/`remarks` when assigning the
/// vendor.
class MaterialRequest {
  const MaterialRequest({
    required this.id,
    required this.itemNumber,
    required this.workOrder,
    required this.project,
    required this.orderBy,
    required this.batchId,
    required this.particular,
    required this.make,
    required this.quantity,
    required this.unit,
    required this.status,
    required this.createdAt,
    this.size = '',
    this.supervisorId,
    this.attachments = const Attachments(),
    this.expectedDate,
    this.vendor,
    this.poNumber,
    this.remarks,
    this.closeNote,
    this.billImages = const [],
    this.workOrderName,
    this.workOrderNumber,
    this.projectName,
    this.projectNumber,
    this.clientName,
    this.supervisorName,
  });

  factory MaterialRequest.fromJson(Map<String, dynamic> json) =>
      MaterialRequest(
        id: json['id'] as String,
        itemNumber: json['itemNumber'] as String,
        workOrder: json['workOrder'] as String,
        project: json['project'] as String,
        orderBy: json['orderBy'] as String,
        batchId: json['batchId'] as String,
        particular: json['particular'] as String,
        make: json['make'] as String,
        quantity: json['quantity'] as num,
        unit: json['unit'] as String,
        status: MaterialRequestStatus.fromWire(json['status'] as String),
        createdAt: json['createdAt'] as String,
        size: json['size'] as String? ?? '',
        supervisorId: json['supervisorId'] as String?,
        attachments: Attachments.fromJson(
          json['attachments'] as Map<String, dynamic>?,
        ),
        expectedDate: json['expectedDate'] as String?,
        vendor: json['vendor'] as String?,
        poNumber: json['poNumber'] as String?,
        remarks: json['remarks'] as String?,
        closeNote: json['closeNote'] as String?,
        billImages:
            (json['billImages'] as List<dynamic>?)?.cast<String>() ??
            const [],
        workOrderName: json['workOrderName'] as String?,
        workOrderNumber: json['workOrderNumber'] as String?,
        projectName: json['projectName'] as String?,
        projectNumber: json['projectNumber'] as String?,
        clientName: json['clientName'] as String?,
        supervisorName: json['supervisorName'] as String?,
      );

  final String id;

  /// System-generated per item, e.g. `26-27_0001/0001/0001`.
  final String itemNumber;
  final String workOrder;
  final String project;

  /// uid of the supervisor who raised the item (audit; never changes).
  final String orderBy;

  /// uid of the work order's current assigned supervisor (visibility key); null when unassigned.
  final String? supervisorId;
  final String batchId;
  final String particular;
  final String make;

  /// Material size / dimension (e.g. "12mm", "8x4 ft").
  final String size;

  final num quantity;
  final String unit;
  final MaterialRequestStatus status;
  final String createdAt;
  final Attachments attachments;

  // Admin, when assigning the vendor / on decline.
  final String? expectedDate;
  final String? vendor;

  /// Optional, plain manual PO reference the admin types when assigning the vendor.
  final String? poNumber;
  final String? remarks;

  // Supervisor, on close.
  /// Optional note the supervisor adds when closing. Separate from admin `remarks`.
  final String? closeNote;

  /// Storage paths of the bill image(s) attached on close (at least one).
  final List<String> billImages;

  // Denormalized for display (resolved by the backend).
  final String? workOrderName;
  final String? workOrderNumber;
  final String? projectName;
  final String? projectNumber;
  final String? clientName;
  final String? supervisorName;

  /// The supervisor may cancel only while `requested`.
  bool get canCancel => status == MaterialRequestStatus.requested;

  /// The supervisor may close only an `accepted` (delivered) item.
  bool get canClose => status == MaterialRequestStatus.accepted;

  /// `5` not `5.0`; keeps a decimal only when present (e.g. `2.5`).
  String get quantityLabel => quantity == quantity.truncate()
      ? quantity.toInt().toString()
      : quantity.toString();
}
