import 'package:flutter_test/flutter_test.dart';
import 'package:capsule_time/features/recipients/data/models/recipient_model.dart';

void main() {
  group('Recipient', () {
    test('fromJson parses correctly', () {
      final json = {
        'id': 'rec123',
        'capsuleId': 'cap456',
        'email': 'recipient@example.com',
        'createdAt': '2024-01-01T00:00:00.000Z',
      };

      final recipient = Recipient.fromJson(json);

      expect(recipient.id, 'rec123');
      expect(recipient.capsuleId, 'cap456');
      expect(recipient.email, 'recipient@example.com');
      expect(recipient.createdAt, DateTime.utc(2024, 1, 1));
    });

    test('props includes all fields', () {
      final recipient = Recipient(
        id: 'rec123',
        capsuleId: 'cap456',
        email: 'test@example.com',
        createdAt: DateTime(2024),
      );

      expect(recipient.props, containsAll([
        recipient.id,
        recipient.capsuleId,
        recipient.email,
        recipient.createdAt,
      ]));
    });

    test('equality works correctly', () {
      final recipient1 = Recipient(
        id: 'rec123',
        capsuleId: 'cap456',
        email: 'test@example.com',
        createdAt: DateTime(2024),
      );
      final recipient2 = Recipient(
        id: 'rec123',
        capsuleId: 'cap456',
        email: 'test@example.com',
        createdAt: DateTime(2024),
      );

      expect(recipient1, equals(recipient2));
    });

    test('inequality works correctly', () {
      final recipient1 = Recipient(
        id: 'rec123',
        capsuleId: 'cap456',
        email: 'a@example.com',
        createdAt: DateTime(2024),
      );
      final recipient2 = Recipient(
        id: 'rec456',
        capsuleId: 'cap456',
        email: 'b@example.com',
        createdAt: DateTime(2024),
      );

      expect(recipient1, isNot(equals(recipient2)));
    });
  });
}
