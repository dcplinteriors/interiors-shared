import 'package:dcpl_shared/dcpl_shared.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Project.fromJson', () {
    test('list shape carries workOrderCount, no work orders', () {
      final p = Project.fromJson({
        'id': 'p1',
        'number': '26-27_0001',
        'name': 'Lobby',
        'clientName': 'Acme',
        'projectEngineer': 'Eng',
        'status': 'active',
        'createdAt': 't',
        'workOrderCount': 3,
      });
      expect(p.number, '26-27_0001');
      expect(p.status, ProjectStatus.active);
      expect(p.workOrderCount, 3);
      expect(p.workOrders, isEmpty);
    });

    test('detail shape parses nested work orders', () {
      final p = Project.fromJson({
        'id': 'p1',
        'number': '26-27_0001',
        'name': 'Lobby',
        'clientName': 'Acme',
        'projectEngineer': 'Eng',
        'status': 'completed',
        'workOrders': [
          {
            'id': 'w1',
            'project': 'p1',
            'number': '26-27_0001/0001',
            'name': 'WO',
            'date': '2026-06-10',
            'status': 'pending',
          },
        ],
      });
      expect(p.status, ProjectStatus.completed);
      expect(p.workOrders, hasLength(1));
      expect(p.workOrders.first.status, WorkOrderStatus.pending);
    });
  });

  test('WorkOrder.fromJson with denormalized names', () {
    final w = WorkOrder.fromJson({
      'id': 'w1',
      'project': 'p1',
      'number': '26-27_0001/0001',
      'name': 'Civil',
      'date': '2026-06-10',
      'status': 'active',
      'supervisorId': 'sup1',
      'projectName': 'Lobby',
      'clientName': 'Acme',
      'supervisorName': 'Ravi',
    });
    expect(w.status, WorkOrderStatus.active);
    expect(w.isAssigned, isTrue);
    expect(w.supervisorName, 'Ravi');
  });

  test('MaterialRequest.fromJson — new fields, nullable supervisorId', () {
    final m = MaterialRequest.fromJson({
      'id': 'mr1',
      'itemNumber': '26-27_0001/0001/0001',
      'workOrder': 'w1',
      'project': 'p1',
      'orderBy': 'sup1',
      'supervisorId': null,
      'batchId': 'b1',
      'particular': 'Hinges',
      'make': 'Hettich',
      'size': '4 inch',
      'quantity': 2.5,
      'unit': 'KG',
      'status': 'processing',
      'createdAt': 't',
      'attachments': {
        'photos': ['a.jpg'],
        'audio': null,
      },
      'workOrderNumber': '26-27_0001/0001',
    });
    expect(m.itemNumber, '26-27_0001/0001/0001');
    expect(m.status, MaterialRequestStatus.processing);
    expect(m.status.isOpen, isTrue);
    expect(m.supervisorId, isNull);
    expect(m.canCancel, isFalse);
    expect(m.canClose, isFalse);
    expect(m.quantityLabel, '2.5');
    expect(m.attachments.photos, ['a.jpg']);
  });

  test('User.fromJson — /me (admin, no name) and supervisor shapes', () {
    final me = User.fromJson({
      'uid': 'u1',
      'email': 'a@x.test',
      'role': 'admin',
      'name': null,
      'photoUrl': null,
    });
    expect(me.isAdmin, isTrue);
    expect(me.name, '');
    expect(me.mustChangePassword, isFalse);

    final sup = User.fromJson({
      'uid': 's1',
      'role': 'supervisor',
      'name': 'Ravi',
      'mustChangePassword': true,
      'workOrders': ['WO A', 'WO B'],
    });
    expect(sup.isSupervisor, isTrue);
    expect(sup.workOrders, ['WO A', 'WO B']);
    expect(sup.mustChangePassword, isTrue);
  });

  test('Page.fromJson parses items + nextCursor', () {
    final page = Page.fromJson({
      'items': [
        {'uid': 's1', 'role': 'supervisor', 'name': 'R'},
      ],
      'nextCursor': 'abc',
    }, User.fromJson);
    expect(page.items, hasLength(1));
    expect(page.hasMore, isTrue);
    expect(page.nextCursor, 'abc');
  });

  group('request inputs toJson', () {
    test('WorkOrderInput omits empty description', () {
      expect(const WorkOrderInput(name: 'WO', date: '2026-06-10').toJson(), {
        'name': 'WO',
        'date': '2026-06-10',
      });
      expect(
        const WorkOrderInput(
          name: 'WO',
          date: '2026-06-10',
          description: 'd',
        ).toJson()['description'],
        'd',
      );
    });

    test(
      'MaterialRequestItemInput omits empty attachments, includes present ones',
      () {
        final bare = const MaterialRequestItemInput(
          particular: 'P',
          make: 'M',
          size: 'S',
          quantity: 1,
          unit: 'PCS',
        ).toJson();
        expect(bare.containsKey('attachments'), isFalse);

        final withAtt = const MaterialRequestItemInput(
          particular: 'P',
          make: 'M',
          size: 'S',
          quantity: 1,
          unit: 'PCS',
          attachments: Attachments(photos: ['a.jpg']),
        ).toJson();
        expect(withAtt['attachments'], {
          'photos': ['a.jpg'],
        });
      },
    );
  });

  test('SignedUpload.fromJson', () {
    final s = SignedUpload.fromJson({
      'uploadUrl': 'http://up',
      'path': 'profiles/u1/x.jpg',
    });
    expect(s.uploadUrl, 'http://up');
    expect(s.path, 'profiles/u1/x.jpg');
  });
}
