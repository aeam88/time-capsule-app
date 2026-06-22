import 'package:flutter_test/flutter_test.dart';
import 'package:capsule_time/features/capsules/data/models/capsule_model.dart';

void main() {
  group('Capsule', () {
    test('fromJson parses correctly', () {
      final json = {
        'id': '123',
        'title': 'Test Capsule',
        'description': 'A test description',
        'status': 'DRAFT',
        'unlockDate': '2025-12-25T00:00:00.000Z',
        'isEncrypted': true,
        'contents': [],
        'files': [],
        'recipients': [],
        'createdAt': '2024-01-01T00:00:00.000Z',
        'updatedAt': '2024-01-01T00:00:00.000Z',
      };

      final capsule = Capsule.fromJson(json);

      expect(capsule.id, '123');
      expect(capsule.title, 'Test Capsule');
      expect(capsule.description, 'A test description');
      expect(capsule.status, CapsuleStatus.draft);
      expect(capsule.isEncrypted, true);
      expect(capsule.fileCount, 0);
      expect(capsule.recipientCount, 0);
    });

    test('fromJson handles null description', () {
      final json = {
        'id': '123',
        'title': 'Test',
        'status': 'LOCKED',
        'unlockDate': '2025-12-25T00:00:00.000Z',
        'contents': [],
        'files': [],
        'recipients': [],
        'createdAt': '2024-01-01T00:00:00.000Z',
        'updatedAt': '2024-01-01T00:00:00.000Z',
      };

      final capsule = Capsule.fromJson(json);
      expect(capsule.description, isNull);
    });

    test('fromJson parses counts from nested arrays', () {
      final json = {
        'id': '123',
        'title': 'Test',
        'status': 'UNLOCKED',
        'unlockDate': '2025-12-25T00:00:00.000Z',
        'contents': [{'id': '1'}, {'id': '2'}],
        'files': [{'id': '1'}],
        'recipients': [{'id': '1'}, {'id': '2'}, {'id': '3'}],
        'createdAt': '2024-01-01T00:00:00.000Z',
        'updatedAt': '2024-01-01T00:00:00.000Z',
      };

      final capsule = Capsule.fromJson(json);
      expect(capsule.contentCount, 2);
      expect(capsule.fileCount, 1);
      expect(capsule.recipientCount, 3);
    });

    test('statusString returns correct string', () {
      final draftJson = _createCapsuleJson('DRAFT');
      final lockedJson = _createCapsuleJson('LOCKED');
      final unlockedJson = _createCapsuleJson('UNLOCKED');
      final archivedJson = _createCapsuleJson('ARCHIVED');

      expect(Capsule.fromJson(draftJson).statusString, 'DRAFT');
      expect(Capsule.fromJson(lockedJson).statusString, 'LOCKED');
      expect(Capsule.fromJson(unlockedJson).statusString, 'UNLOCKED');
      expect(Capsule.fromJson(archivedJson).statusString, 'ARCHIVED');
    });

    test('_parseStatus handles unknown status', () {
      final json = _createCapsuleJson('UNKNOWN');
      final capsule = Capsule.fromJson(json);
      expect(capsule.status, CapsuleStatus.draft);
    });

    test('props includes all fields for equality', () {
      final json = _createCapsuleJson('DRAFT');
      final capsule = Capsule.fromJson(json);

      expect(capsule.props, containsAll([
        capsule.id,
        capsule.title,
        capsule.description,
        capsule.status,
        capsule.unlockDate,
        capsule.isEncrypted,
      ]));
    });
  });
}

Map<String, dynamic> _createCapsuleJson(String status) {
  return {
    'id': '123',
    'title': 'Test',
    'status': status,
    'unlockDate': '2025-12-25T00:00:00.000Z',
    'contents': [],
    'files': [],
    'recipients': [],
    'createdAt': '2024-01-01T00:00:00.000Z',
    'updatedAt': '2024-01-01T00:00:00.000Z',
  };
}
