import 'dart:convert';
import 'dart:typed_data';

import 'package:dcpl_shared/dcpl_shared.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

/// Captures the outgoing request and replies with a canned JSON body — so each
/// [DcplApi] method's verb / path / query / body / response-parsing is asserted
/// without a real network or Firebase.
class _CapturingAdapter implements HttpClientAdapter {
  RequestOptions? last;
  Object? capturedBody;

  /// The JSON value the next call replies with.
  Object? reply;
  int status = 200;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    last = options;
    capturedBody = null;
    if (requestStream != null) {
      final chunks = await requestStream.toList();
      final bytes = chunks.expand((c) => c).toList();
      if (bytes.isNotEmpty) capturedBody = jsonDecode(utf8.decode(bytes));
    }
    return ResponseBody.fromString(
      jsonEncode(reply),
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

class _FakeTokens implements TokenSource {
  @override
  Future<String?> idToken() async => 'test-token';
}

// ---- Canned response fragments ----------------------------------------------------------------

Map<String, dynamic> _projectJson({
  List<Map<String, dynamic>>? workOrders,
  int? count,
}) => {
  'id': 'p1',
  'number': '26-27_0001',
  'name': 'Lobby',
  'clientName': 'Acme',
  'projectEngineer': 'Eng',
  'status': 'active',
  'createdAt': 't',
  'workOrderCount': ?count,
  'workOrders': ?workOrders,
};

Map<String, dynamic> _workOrderJson() => {
  'id': 'w1',
  'project': 'p1',
  'number': '26-27_0001/0001',
  'name': 'Civil',
  'date': '2026-06-10',
  'status': 'active',
  'supervisorId': 's1',
};

Map<String, dynamic> _requestJson() => {
  'id': 'mr1',
  'itemNumber': '26-27_0001/0001/0001',
  'workOrder': 'w1',
  'project': 'p1',
  'orderBy': 's1',
  'supervisorId': 's1',
  'batchId': 'b1',
  'particular': 'Hinges',
  'make': 'Hettich',
  'size': '4 inch',
  'quantity': 2,
  'unit': 'PCS',
  'status': 'requested',
  'createdAt': 't',
  'attachments': {'photos': <String>[]},
};

Map<String, dynamic> _userJson({String role = 'supervisor'}) => {
  'uid': 's1',
  'role': role,
  'name': 'Ravi',
};

void main() {
  late _CapturingAdapter adapter;
  late DcplApi api;

  setUp(() {
    adapter = _CapturingAdapter();
    final dio = Dio(BaseOptions(baseUrl: 'https://api.test/api'))
      ..httpClientAdapter = adapter;
    api = DcplApi(ApiClient(_FakeTokens(), dio: dio));
  });

  group('me', () {
    test('get → GET /me, parses user', () async {
      adapter.reply = _userJson(role: 'admin');
      final u = await api.me.get();
      expect(adapter.last!.method, 'GET');
      expect(adapter.last!.path, '/me');
      expect(u.isAdmin, isTrue);
    });

    test('update → PATCH /me with only the provided fields', () async {
      adapter.reply = _userJson();
      await api.me.update(name: 'Ravi');
      expect(adapter.last!.method, 'PATCH');
      expect(adapter.last!.path, '/me');
      expect(adapter.capturedBody, {'name': 'Ravi'});
    });
  });

  group('supervisors', () {
    test('create → POST /supervisors, omits empty phone', () async {
      adapter.reply = _userJson();
      await api.supervisors.create(name: 'Ravi', email: 'r@x.test');
      expect(adapter.last!.method, 'POST');
      expect(adapter.last!.path, '/supervisors');
      expect(adapter.capturedBody, {'name': 'Ravi', 'email': 'r@x.test'});
    });

    test('list → GET /supervisors with pagination, parses Page', () async {
      adapter.reply = {
        'items': [_userJson()],
        'nextCursor': 'c2',
      };
      final page = await api.supervisors.list(limit: 10, cursor: 'c1');
      expect(adapter.last!.method, 'GET');
      expect(adapter.last!.path, '/supervisors');
      expect(adapter.last!.queryParameters, {'limit': 10, 'cursor': 'c1'});
      expect(page.items.single.name, 'Ravi');
      expect(page.hasMore, isTrue);
    });
  });

  group('projects', () {
    test('create → POST /projects with nested work orders', () async {
      adapter.reply = _projectJson(workOrders: [_workOrderJson()]);
      final p = await api.projects.create(
        name: 'Lobby',
        clientName: 'Acme',
        projectEngineer: 'Eng',
        workOrders: const [WorkOrderInput(name: 'Civil', date: '2026-06-10')],
      );
      expect(adapter.last!.method, 'POST');
      expect(adapter.last!.path, '/projects');
      final body = adapter.capturedBody as Map<String, dynamic>;
      expect(body['name'], 'Lobby');
      expect((body['workOrders'] as List).single, {
        'name': 'Civil',
        'date': '2026-06-10',
      });
      expect(p.workOrders.single.id, 'w1');
    });

    test('list → GET /projects, no query when unpaged', () async {
      adapter.reply = {
        'items': [_projectJson(count: 2)],
        'nextCursor': null,
      };
      final page = await api.projects.list();
      expect(adapter.last!.path, '/projects');
      expect(adapter.last!.queryParameters, isEmpty);
      expect(page.items.single.workOrderCount, 2);
      expect(page.hasMore, isFalse);
    });

    test('get → GET /projects/:id', () async {
      adapter.reply = _projectJson(workOrders: const []);
      await api.projects.get('p1');
      expect(adapter.last!.method, 'GET');
      expect(adapter.last!.path, '/projects/p1');
    });

    test('complete → POST /projects/:id/complete, no body', () async {
      adapter.reply = _projectJson();
      await api.projects.complete('p1');
      expect(adapter.last!.method, 'POST');
      expect(adapter.last!.path, '/projects/p1/complete');
      expect(adapter.capturedBody, isNull);
    });

    test('addWorkOrder → POST /projects/:id/work-orders', () async {
      adapter.reply = _workOrderJson();
      await api.projects.addWorkOrder(
        'p1',
        const WorkOrderInput(
          name: 'Civil',
          date: '2026-06-10',
          description: 'd',
        ),
      );
      expect(adapter.last!.path, '/projects/p1/work-orders');
      expect(adapter.capturedBody, {
        'name': 'Civil',
        'date': '2026-06-10',
        'description': 'd',
      });
    });
  });

  group('work-orders', () {
    test('list → GET /work-orders with project + status filters', () async {
      adapter.reply = {
        'items': [_workOrderJson()],
        'nextCursor': null,
      };
      await api.workOrders.list(
        project: 'p1',
        status: WorkOrderStatus.active,
        limit: 5,
      );
      expect(adapter.last!.path, '/work-orders');
      expect(adapter.last!.queryParameters, {
        'limit': 5,
        'project': 'p1',
        'status': 'active',
      });
    });

    test('assign → POST /work-orders/:id/assign with supervisorId', () async {
      adapter.reply = _workOrderJson();
      await api.workOrders.assign('w1', 's1');
      expect(adapter.last!.path, '/work-orders/w1/assign');
      expect(adapter.capturedBody, {'supervisorId': 's1'});
    });

    test('unassign → POST /work-orders/:id/unassign, no body', () async {
      adapter.reply = _workOrderJson();
      await api.workOrders.unassign('w1');
      expect(adapter.last!.path, '/work-orders/w1/unassign');
      expect(adapter.capturedBody, isNull);
    });

    test('cancel → POST /work-orders/:id/cancel', () async {
      adapter.reply = _workOrderJson();
      await api.workOrders.cancel('w1');
      expect(adapter.last!.path, '/work-orders/w1/cancel');
    });
  });

  group('material-requests', () {
    test('submit → POST /material-requests, returns a list', () async {
      adapter.reply = [_requestJson(), _requestJson()];
      final res = await api.materialRequests.submit('w1', const [
        MaterialRequestItemInput(
          particular: 'Hinges',
          make: 'Hettich',
          size: '4 inch',
          quantity: 2,
          unit: 'PCS',
        ),
      ]);
      expect(adapter.last!.method, 'POST');
      expect(adapter.last!.path, '/material-requests');
      final body = adapter.capturedBody as Map<String, dynamic>;
      expect(body['workOrderId'], 'w1');
      expect((body['items'] as List).single, {
        'particular': 'Hinges',
        'make': 'Hettich',
        'size': '4 inch',
        'quantity': 2,
        'unit': 'PCS',
      });
      expect(res, hasLength(2));
    });

    test('list → GET /material-requests with all filters', () async {
      adapter.reply = {'items': <Map<String, dynamic>>[], 'nextCursor': null};
      await api.materialRequests.list(
        status: MaterialRequestStatus.requested,
        workOrder: 'w1',
        project: 'p1',
      );
      expect(adapter.last!.path, '/material-requests');
      expect(adapter.last!.queryParameters, {
        'status': 'requested',
        'workOrder': 'w1',
        'project': 'p1',
      });
    });

    test('count → GET /material-requests/count, unwraps {count}', () async {
      adapter.reply = {'count': 7};
      final n = await api.materialRequests.count(
        status: MaterialRequestStatus.requested,
      );
      expect(adapter.last!.method, 'GET');
      expect(adapter.last!.path, '/material-requests/count');
      expect(adapter.last!.queryParameters, {'status': 'requested'});
      expect(n, 7);
    });

    test('count with statuses → statusIn comma-joined', () async {
      adapter.reply = {'count': 7};
      final n = await api.materialRequests.count(
        statuses: const [
          MaterialRequestStatus.requested,
          MaterialRequestStatus.processing,
        ],
      );
      expect(adapter.last!.path, '/material-requests/count');
      expect(adapter.last!.queryParameters, {
        'statusIn': 'requested,processing',
      });
      expect(n, 7);
    });

    test('accept with remarks → POST /:id/accept', () async {
      adapter.reply = _requestJson();
      await api.materialRequests.accept('mr1', remarks: 'ok');
      expect(adapter.last!.path, '/material-requests/mr1/accept');
      expect(adapter.capturedBody, {'remarks': 'ok'});
    });

    test('accept without remarks → empty body (null entry omitted)', () async {
      adapter.reply = _requestJson();
      await api.materialRequests.accept('mr1');
      expect(adapter.capturedBody, <String, dynamic>{});
    });

    test('assignVendor → POST /:id/assign-vendor', () async {
      adapter.reply = _requestJson();
      await api.materialRequests.assignVendor(
        'mr1',
        expectedDate: '2026-06-20',
        vendor: 'V Co',
        poNumber: 'PO-1',
      );
      expect(adapter.last!.path, '/material-requests/mr1/assign-vendor');
      expect(adapter.capturedBody, {
        'expectedDate': '2026-06-20',
        'vendor': 'V Co',
        'poNumber': 'PO-1',
      });
    });

    test('decline → POST /:id/decline with remarks', () async {
      adapter.reply = _requestJson();
      await api.materialRequests.decline('mr1', 'no stock');
      expect(adapter.last!.path, '/material-requests/mr1/decline');
      expect(adapter.capturedBody, {'remarks': 'no stock'});
    });

    test('cancel/close → POST /:id/cancel and /close, no body', () async {
      adapter.reply = _requestJson();
      await api.materialRequests.cancel('mr1');
      expect(adapter.last!.path, '/material-requests/mr1/cancel');
      expect(adapter.capturedBody, isNull);

      await api.materialRequests.close('mr1');
      expect(adapter.last!.path, '/material-requests/mr1/close');
    });

    test('returnItem → POST /:id/return with reason', () async {
      adapter.reply = _requestJson();
      await api.materialRequests.returnItem('mr1', 'damaged');
      expect(adapter.last!.path, '/material-requests/mr1/return');
      expect(adapter.capturedBody, {'reason': 'damaged'});
    });
  });

  group('uploads', () {
    test('sign → POST /uploads/sign, parses SignedUpload', () async {
      adapter.reply = {'uploadUrl': 'https://up', 'path': 'profiles/s1/x.jpg'};
      final s = await api.uploads.sign(
        kind: 'photo',
        contentType: 'image/jpeg',
        scope: 'profile',
      );
      expect(adapter.last!.path, '/uploads/sign');
      expect(adapter.capturedBody, {
        'kind': 'photo',
        'contentType': 'image/jpeg',
        'scope': 'profile',
      });
      expect(s.uploadUrl, 'https://up');
      expect(s.path, 'profiles/s1/x.jpg');
    });

    test('downloadUrl → POST /uploads/download-url, unwraps url', () async {
      adapter.reply = {'url': 'https://read'};
      final url = await api.uploads.downloadUrl('profiles/s1/x.jpg');
      expect(adapter.last!.path, '/uploads/download-url');
      expect(adapter.capturedBody, {'path': 'profiles/s1/x.jpg'});
      expect(url, 'https://read');
    });
  });

  test('auth token is attached as a bearer header', () async {
    adapter.reply = _userJson();
    await api.me.get();
    expect(adapter.last!.headers['Authorization'], 'Bearer test-token');
  });

  test(
    'backend { error: { message } } surfaces as ApiException.message',
    () async {
      adapter.status = 409;
      adapter.reply = {
        'error': {'message': 'Work order already assigned'},
      };
      await expectLater(
        api.workOrders.assign('w1', 's1'),
        throwsA(
          isA<ApiException>()
              .having((e) => e.statusCode, 'statusCode', 409)
              .having(
                (e) => e.message,
                'message',
                'Work order already assigned',
              ),
        ),
      );
    },
  );
}
