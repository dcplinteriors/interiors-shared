/// Storage object paths for an item's attachments (resolved to signed URLs on demand
/// via the backend `/uploads/download-url` endpoint — clients never touch Storage directly).
class Attachments {
  const Attachments({this.photos = const [], this.audio});

  factory Attachments.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const Attachments();
    return Attachments(
      photos: (json['photos'] as List?)?.map((e) => e as String).toList() ?? const [],
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

/// A material request — one requested item (mirrors the backend `materialRequests` model).
/// Several items submitted together share a `batchId`; each is reviewed independently.
/// `expectedDate`/`vendor`/`remarks` are filled by the admin on acceptance.
class MaterialRequest {
  const MaterialRequest({
    required this.id,
    required this.project,
    required this.orderBy,
    required this.poNumber,
    required this.jobNumber,
    required this.batchId,
    required this.particular,
    required this.make,
    required this.quantity,
    required this.unit,
    required this.status,
    required this.createdAt,
    this.size = '',
    this.attachments = const Attachments(),
    this.expectedDate,
    this.vendor,
    this.remarks,
    this.projectName,
    this.clientName,
    this.supervisorName,
  });

  factory MaterialRequest.fromJson(Map<String, dynamic> json) => MaterialRequest(
        id: json['id'] as String,
        project: json['project'] as String,
        orderBy: json['orderBy'] as String,
        poNumber: json['poNumber'] as String,
        jobNumber: json['jobNumber'] as String,
        batchId: json['batchId'] as String,
        particular: json['particular'] as String,
        make: json['make'] as String,
        quantity: json['quantity'] as num,
        unit: json['unit'] as String,
        status: json['status'] as String,
        createdAt: json['createdAt'] as String,
        size: json['size'] as String? ?? '',
        attachments: Attachments.fromJson(json['attachments'] as Map<String, dynamic>?),
        expectedDate: json['expectedDate'] as String?,
        vendor: json['vendor'] as String?,
        remarks: json['remarks'] as String?,
        projectName: json['projectName'] as String?,
        clientName: json['clientName'] as String?,
        supervisorName: json['supervisorName'] as String?,
      );

  final String id;
  final String project;
  final String orderBy;
  final String poNumber;
  final String jobNumber;
  final String batchId;
  final String particular;
  final String make;

  /// Material size / dimension (e.g. "12mm", "8x4 ft"). Defaults to '' for legacy records
  /// created before this field existed.
  final String size;

  final num quantity;
  final String unit;
  final String status; // requested | accepted | declined | cancelled
  final String createdAt;
  final Attachments attachments;
  final String? expectedDate;
  final String? vendor;
  final String? remarks;

  /// The project's name + client name and the ordering supervisor's name, resolved by
  /// the backend so clients don't look them up. Null when absent from the response.
  final String? projectName;
  final String? clientName;
  final String? supervisorName;

  /// Only `requested` items can be accepted/declined/cancelled; the rest are terminal.
  bool get isPending => status == 'requested';

  /// `5` not `5.0`; keeps a decimal only when present (e.g. `2.5`).
  String get quantityLabel =>
      quantity == quantity.truncate() ? quantity.toInt().toString() : quantity.toString();
}
