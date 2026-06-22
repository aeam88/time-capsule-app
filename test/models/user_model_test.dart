import 'package:flutter_test/flutter_test.dart';
import 'package:capsule_time/features/auth/data/models/user_model.dart';

void main() {
  group('UserModel', () {
    test('fromJson parses correctly', () {
      final json = {
        'id': 'user123',
        'email': 'test@example.com',
        'firstName': 'John',
        'lastName': 'Doe',
      };

      final user = UserModel.fromJson(json);

      expect(user.id, 'user123');
      expect(user.email, 'test@example.com');
      expect(user.firstName, 'John');
      expect(user.lastName, 'Doe');
    });

    test('fromJson handles null names', () {
      final json = {
        'id': 'user123',
        'email': 'test@example.com',
      };

      final user = UserModel.fromJson(json);

      expect(user.firstName, isNull);
      expect(user.lastName, isNull);
    });

    test('toJson serializes correctly', () {
      final user = UserModel(
        id: 'user123',
        email: 'test@example.com',
        firstName: 'John',
        lastName: 'Doe',
      );

      final json = user.toJson();

      expect(json['id'], 'user123');
      expect(json['email'], 'test@example.com');
      expect(json['firstName'], 'John');
      expect(json['lastName'], 'Doe');
    });

    test('toJson handles null names', () {
      final user = UserModel(
        id: 'user123',
        email: 'test@example.com',
      );

      final json = user.toJson();

      expect(json['firstName'], isNull);
      expect(json['lastName'], isNull);
    });

    test('fromJson then toJson preserves data', () {
      final originalJson = {
        'id': 'user123',
        'email': 'test@example.com',
        'firstName': 'John',
        'lastName': 'Doe',
      };

      final user = UserModel.fromJson(originalJson);
      final resultJson = user.toJson();

      expect(resultJson['id'], originalJson['id']);
      expect(resultJson['email'], originalJson['email']);
      expect(resultJson['firstName'], originalJson['firstName']);
      expect(resultJson['lastName'], originalJson['lastName']);
    });
  });
}
