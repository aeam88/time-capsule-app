import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dio/dio.dart';
import 'package:capsule_time/features/capsules/data/repositories/capsules_repository.dart';
import 'package:capsule_time/core/errors/api_exception.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late MockDio mockDio;
  late CapsulesRepository repository;

  setUp(() {
    mockDio = MockDio();
    repository = CapsulesRepository(dio: mockDio);
  });

  group('getCapsules', () {
    test('returns list of capsules on success', () async {
      when(() => mockDio.get(
        any(),
        queryParameters: any(named: 'queryParameters'),
      )).thenAnswer((_) async => Response(
        data: {
          'data': [
            {
              'id': '1',
              'title': 'Test',
              'status': 'DRAFT',
              'unlockDate': '2025-12-25T00:00:00.000Z',
              'contents': [],
              'files': [],
              'recipients': [],
              'createdAt': '2024-01-01T00:00:00.000Z',
              'updatedAt': '2024-01-01T00:00:00.000Z',
            }
          ],
          'nextCursor': null,
          'hasMore': false,
        },
        statusCode: 200,
        requestOptions: RequestOptions(path: '/capsules'),
      ));

      final result = await repository.getCapsules();

      expect(result.capsules.length, 1);
      expect(result.capsules.first.title, 'Test');
      expect(result.hasMore, false);
    });

    test('throws ApiException on DioException', () async {
      when(() => mockDio.get(
        any(),
        queryParameters: any(named: 'queryParameters'),
      )).thenThrow(DioException(
        requestOptions: RequestOptions(path: '/capsules'),
        response: Response(
          statusCode: 500,
          data: {'message': 'Server error'},
          requestOptions: RequestOptions(path: '/capsules'),
        ),
      ));

      expect(
        () => repository.getCapsules(),
        throwsA(isA<ApiException>()),
      );
    });
  });

  group('createCapsule', () {
    test('returns capsule on success', () async {
      when(() => mockDio.post(
        any(),
        data: any(named: 'data'),
      )).thenAnswer((_) async => Response(
        data: {
          'id': '1',
          'title': 'New Capsule',
          'status': 'DRAFT',
          'unlockDate': '2025-12-25T00:00:00.000Z',
          'contents': [],
          'files': [],
          'recipients': [],
          'createdAt': '2024-01-01T00:00:00.000Z',
          'updatedAt': '2024-01-01T00:00:00.000Z',
        },
        statusCode: 201,
        requestOptions: RequestOptions(path: '/capsules'),
      ));

      final capsule = await repository.createCapsule(
        title: 'New Capsule',
        unlockDate: DateTime(2025, 12, 25),
      );

      expect(capsule.title, 'New Capsule');
    });
  });

  group('deleteCapsule', () {
    test('completes successfully', () async {
      when(() => mockDio.delete(any()))
          .thenAnswer((_) async => Response(
        statusCode: 204,
        requestOptions: RequestOptions(path: '/capsules/1'),
      ));

      await repository.deleteCapsule('1');

      verify(() => mockDio.delete(any())).called(1);
    });
  });

  group('getSharedCapsules', () {
    test('returns list of shared capsules', () async {
      when(() => mockDio.get(any())).thenAnswer((_) async => Response(
        data: [
          {
            'id': '1',
            'title': 'Shared Capsule',
            'status': 'UNLOCKED',
            'unlockDate': '2024-01-01T00:00:00.000Z',
            'contents': [],
            'files': [],
            'recipients': [],
            'createdAt': '2024-01-01T00:00:00.000Z',
            'updatedAt': '2024-01-01T00:00:00.000Z',
          }
        ],
        statusCode: 200,
        requestOptions: RequestOptions(path: '/capsules/shared'),
      ));

      final capsules = await repository.getSharedCapsules();

      expect(capsules.length, 1);
      expect(capsules.first.title, 'Shared Capsule');
    });
  });
}
