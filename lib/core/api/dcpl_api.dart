import 'package:dcpl_shared/core/api/api_client.dart';
import 'package:dcpl_shared/core/api/page.dart';
import 'package:dcpl_shared/models/models.dart';

/// Typed wrapper over the thin [ApiClient] — one method per backend endpoint, returning the
/// shared models. The single place endpoint paths + request/response shapes live, so both apps
/// reuse them. Errors surface as [ApiException] (normalized by [ApiClient]).
class DcplApi {
  DcplApi(ApiClient client)
    : me = MeApi(client),
      supervisors = SupervisorsApi(client),
      projects = ProjectsApi(client),
      workOrders = WorkOrdersApi(client),
      materialRequests = MaterialRequestsApi(client),
      uploads = UploadsApi(client);

  final MeApi me;
  final SupervisorsApi supervisors;
  final ProjectsApi projects;
  final WorkOrdersApi workOrders;
  final MaterialRequestsApi materialRequests;
  final UploadsApi uploads;
}

/// `/me` — the caller's own profile.
class MeApi {
  const MeApi(this._api);
  final ApiClient _api;

  Future<User> get() async =>
      User.fromJson(await _api.get('/me') as Map<String, dynamic>);

  /// Supervisor-only. At least one of [name]/[photoUrl] must be provided.
  Future<User> update({String? name, String? photoUrl}) async => User.fromJson(
    await _api.patch('/me', body: {'name': ?name, 'photoUrl': ?photoUrl})
        as Map<String, dynamic>,
  );
}

/// `/supervisors` (admin).
class SupervisorsApi {
  const SupervisorsApi(this._api);
  final ApiClient _api;

  Future<User> create({
    required String name,
    required String email,
    String? phone,
  }) async => User.fromJson(
    await _api.post(
          '/supervisors',
          body: {
            'name': name,
            'email': email,
            if (phone != null && phone.isNotEmpty) 'phone': phone,
          },
        )
        as Map<String, dynamic>,
  );

  Future<Page<User>> list({int? limit, String? cursor}) async => Page.fromJson(
    await _api.get(
      '/supervisors',
      query: _query(limit: limit, cursor: cursor),
    ),
    User.fromJson,
  );
}

/// `/projects` (admin).
class ProjectsApi {
  const ProjectsApi(this._api);
  final ApiClient _api;

  Future<Project> create({
    required String name,
    required String clientName,
    required String projectEngineer,
    required List<WorkOrderInput> workOrders,
  }) async => Project.fromJson(
    await _api.post(
          '/projects',
          body: {
            'name': name,
            'clientName': clientName,
            'projectEngineer': projectEngineer,
            'workOrders': workOrders.map((w) => w.toJson()).toList(),
          },
        )
        as Map<String, dynamic>,
  );

  Future<Page<Project>> list({int? limit, String? cursor}) async =>
      Page.fromJson(
        await _api.get(
          '/projects',
          query: _query(limit: limit, cursor: cursor),
        ),
        Project.fromJson,
      );

  Future<Project> get(String id) async =>
      Project.fromJson(await _api.get('/projects/$id') as Map<String, dynamic>);

  Future<Project> complete(String id) async => Project.fromJson(
    await _api.post('/projects/$id/complete') as Map<String, dynamic>,
  );

  Future<WorkOrder> addWorkOrder(
    String projectId,
    WorkOrderInput input,
  ) async => WorkOrder.fromJson(
    await _api.post('/projects/$projectId/work-orders', body: input.toJson())
        as Map<String, dynamic>,
  );
}

/// `/work-orders`.
class WorkOrdersApi {
  const WorkOrdersApi(this._api);
  final ApiClient _api;

  Future<Page<WorkOrder>> list({
    String? project,
    WorkOrderStatus? status,
    int? limit,
    String? cursor,
  }) async => Page.fromJson(
    await _api.get(
      '/work-orders',
      query: _query(
        limit: limit,
        cursor: cursor,
        extra: {'project': project, 'status': status?.wire},
      ),
    ),
    WorkOrder.fromJson,
  );

  Future<WorkOrder> get(String id) async => WorkOrder.fromJson(
    await _api.get('/work-orders/$id') as Map<String, dynamic>,
  );

  Future<WorkOrder> assign(String id, String supervisorId) async =>
      WorkOrder.fromJson(
        await _api.post(
              '/work-orders/$id/assign',
              body: {'supervisorId': supervisorId},
            )
            as Map<String, dynamic>,
      );

  Future<WorkOrder> unassign(String id) async => WorkOrder.fromJson(
    await _api.post('/work-orders/$id/unassign') as Map<String, dynamic>,
  );

  Future<WorkOrder> complete(String id) async => WorkOrder.fromJson(
    await _api.post('/work-orders/$id/complete') as Map<String, dynamic>,
  );

  Future<WorkOrder> cancel(String id) async => WorkOrder.fromJson(
    await _api.post('/work-orders/$id/cancel') as Map<String, dynamic>,
  );
}

/// `/material-requests`.
class MaterialRequestsApi {
  const MaterialRequestsApi(this._api);
  final ApiClient _api;

  /// Submit a multi-item request on an assigned work order → one record per item.
  Future<List<MaterialRequest>> submit(
    String workOrderId,
    List<MaterialRequestItemInput> items,
  ) async {
    final res = await _api.post(
      '/material-requests',
      body: {
        'workOrderId': workOrderId,
        'items': items.map((i) => i.toJson()).toList(),
      },
    );
    return (res as List)
        .map((e) => MaterialRequest.fromJson(e as Map<String, dynamic>))
        .toList(growable: false);
  }

  Future<Page<MaterialRequest>> list({
    MaterialRequestStatus? status,
    String? workOrder,
    String? project,
    int? limit,
    String? cursor,
  }) async => Page.fromJson(
    await _api.get(
      '/material-requests',
      query: _query(
        limit: limit,
        cursor: cursor,
        extra: {
          'status': status?.wire,
          'workOrder': workOrder,
          'project': project,
        },
      ),
    ),
    MaterialRequest.fromJson,
  );

  /// Count of matching items (no pagination) — drives the "to review" badge. Role-scoped by
  /// the backend (admin: all; supervisor: own visible items).
  ///
  /// Pass [statuses] to count several statuses in one call (sent as `statusIn`); it takes
  /// precedence over [status] server-side.
  Future<int> count({
    MaterialRequestStatus? status,
    List<MaterialRequestStatus>? statuses,
    String? workOrder,
    String? project,
  }) async {
    final res = await _api.get(
      '/material-requests/count',
      query: _query(
        extra: {
          'status': status?.wire,
          'statusIn': (statuses == null || statuses.isEmpty)
              ? null
              : statuses.map((s) => s.wire).join(','),
          'workOrder': workOrder,
          'project': project,
        },
      ),
    );
    return (res as Map<String, dynamic>)['count'] as int;
  }

  // Admin transitions.
  Future<MaterialRequest> accept(String id, {String? remarks}) async => _one(
    await _api.post(
      '/material-requests/$id/accept',
      body: {'remarks': ?remarks},
    ),
  );

  Future<MaterialRequest> assignVendor(
    String id, {
    required String expectedDate,
    required String vendor,
    String? poNumber,
    String? remarks,
  }) async => _one(
    await _api.post(
      '/material-requests/$id/assign-vendor',
      body: {
        'expectedDate': expectedDate,
        'vendor': vendor,
        if (poNumber != null && poNumber.isNotEmpty) 'poNumber': poNumber,
        if (remarks != null && remarks.isNotEmpty) 'remarks': remarks,
      },
    ),
  );

  Future<MaterialRequest> decline(String id, String remarks) async => _one(
    await _api.post(
      '/material-requests/$id/decline',
      body: {'remarks': remarks},
    ),
  );

  // Supervisor transitions.
  Future<MaterialRequest> cancel(String id) async =>
      _one(await _api.post('/material-requests/$id/cancel'));

  Future<MaterialRequest> close(
    String id, {
    required List<String> billImages,
    String? note,
  }) async => _one(
    await _api.post(
      '/material-requests/$id/close',
      body: {'billImages': billImages, 'note': ?note},
    ),
  );

  MaterialRequest _one(dynamic json) =>
      MaterialRequest.fromJson(json as Map<String, dynamic>);
}

/// `/uploads` — presigned URLs for attachments and profile images.
class UploadsApi {
  const UploadsApi(this._api);
  final ApiClient _api;

  /// [kind] = `'photo'` | `'audio'`; [scope] = `'attachment'` (default) | `'profile'` (photo only).
  /// Returns the signed PUT URL + the object path to persist.
  Future<SignedUpload> sign({
    required String kind,
    required String contentType,
    String? scope,
  }) async => SignedUpload.fromJson(
    await _api.post(
          '/uploads/sign',
          body: {'kind': kind, 'contentType': contentType, 'scope': ?scope},
        )
        as Map<String, dynamic>,
  );

  /// Resolve a stored object path to a short-lived signed read URL.
  Future<String> downloadUrl(String path) async {
    final res = await _api.post('/uploads/download-url', body: {'path': path});
    return (res as Map<String, dynamic>)['url'] as String;
  }
}

// ---- Request input types --------------------------------------------------------------------

/// One work order in the create-project / add-work-order flow.
class WorkOrderInput {
  const WorkOrderInput({
    required this.name,
    required this.date,
    this.description,
  });

  final String name;
  final String date; // YYYY-MM-DD
  final String? description;

  Map<String, dynamic> toJson() => {
    'name': name,
    'date': date,
    if (description != null && description!.isNotEmpty)
      'description': description,
  };
}

/// One item in a material-request submission.
class MaterialRequestItemInput {
  const MaterialRequestItemInput({
    required this.particular,
    required this.make,
    required this.size,
    required this.quantity,
    required this.unit,
    this.attachments = const Attachments(),
  });

  final String particular;
  final String make;
  final String size;
  final num quantity;
  final String unit;
  final Attachments attachments;

  Map<String, dynamic> toJson() => {
    'particular': particular,
    'make': make,
    'size': size,
    'quantity': quantity,
    'unit': unit,
    if (attachments.isNotEmpty) 'attachments': attachments.toJson(),
  };
}

/// Result of `POST /uploads/sign` — the signed PUT URL + the object path to persist.
class SignedUpload {
  const SignedUpload({required this.uploadUrl, required this.path});

  factory SignedUpload.fromJson(Map<String, dynamic> json) => SignedUpload(
    uploadUrl: json['uploadUrl'] as String,
    path: json['path'] as String,
  );

  final String uploadUrl;
  final String path;
}

/// Builds a query map from pagination + extra filters, dropping nulls; returns null when empty.
Map<String, dynamic>? _query({
  int? limit,
  String? cursor,
  Map<String, String?> extra = const {},
}) {
  final q = <String, dynamic>{};
  if (limit != null) q['limit'] = limit;
  if (cursor != null) q['cursor'] = cursor;
  extra.forEach((k, v) {
    if (v != null) q[k] = v;
  });
  return q.isEmpty ? null : q;
}
