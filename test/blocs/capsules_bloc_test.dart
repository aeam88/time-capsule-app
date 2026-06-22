import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:capsule_time/features/capsules/bloc/capsules_bloc.dart';
import 'package:capsule_time/features/capsules/bloc/capsules_event.dart';
import 'package:capsule_time/features/capsules/bloc/capsules_state.dart';
import 'package:capsule_time/features/capsules/data/repositories/capsules_repository.dart';
import 'package:capsule_time/features/capsules/data/models/capsule_model.dart';
import 'package:capsule_time/core/errors/api_exception.dart';

class MockCapsulesRepository extends Mock implements CapsulesRepository {}

void main() {
  late MockCapsulesRepository mockRepository;
  late CapsulesBloc bloc;

  setUp(() {
    mockRepository = MockCapsulesRepository();
    bloc = CapsulesBloc(repository: mockRepository);
  });

  tearDown(() {
    bloc.close();
  });

  final testCapsule = Capsule(
    id: '1',
    title: 'Test Capsule',
    status: CapsuleStatus.draft,
    unlockDate: DateTime(2025, 12, 25),
    isEncrypted: true,
    createdAt: DateTime(2024, 1, 1),
    updatedAt: DateTime(2024, 1, 1),
  );

  group('LoadCapsules', () {
    blocTest<CapsulesBloc, CapsulesState>(
      'emits [CapsulesLoading, CapsulesLoaded] when successful',
      build: () {
        when(() => mockRepository.getCapsules(
          status: any(named: 'status'),
          search: any(named: 'search'),
        )).thenAnswer((_) async => CapsulesResult(
          capsules: [testCapsule],
          hasMore: false,
        ));
        return bloc;
      },
      act: (bloc) => bloc.add(const LoadCapsules()),
      expect: () => [
        const CapsulesLoading(),
        isA<CapsulesLoaded>(),
      ],
    );

    blocTest<CapsulesBloc, CapsulesState>(
      'emits [CapsulesLoading, CapsulesError] when repository throws',
      build: () {
        when(() => mockRepository.getCapsules(
          status: any(named: 'status'),
          search: any(named: 'search'),
        )).thenThrow(ApiException(message: 'Error loading'));
        return bloc;
      },
      act: (bloc) => bloc.add(const LoadCapsules()),
      expect: () => [
        const CapsulesLoading(),
        const CapsulesError(message: 'Error loading'),
      ],
    );
  });

  group('CreateCapsule', () {
    blocTest<CapsulesBloc, CapsulesState>(
      'emits [CapsulesLoading, CapsuleOperationSuccess, CapsulesLoading, CapsulesLoaded] when successful',
      build: () {
        when(() => mockRepository.createCapsule(
          title: any(named: 'title'),
          description: any(named: 'description'),
          unlockDate: any(named: 'unlockDate'),
          isEncrypted: any(named: 'isEncrypted'),
        )).thenAnswer((_) async => testCapsule);
        when(() => mockRepository.getCapsules(
          status: any(named: 'status'),
          search: any(named: 'search'),
        )).thenAnswer((_) async => CapsulesResult(
          capsules: [testCapsule],
          hasMore: false,
        ));
        return bloc;
      },
      act: (bloc) => bloc.add(CreateCapsule(
        title: 'New Capsule',
        unlockDate: DateTime(2025, 12, 25),
      )),
      expect: () => [
        const CapsulesLoading(),
        isA<CapsuleOperationSuccess>(),
        const CapsulesLoading(),
        isA<CapsulesLoaded>(),
      ],
    );
  });

  group('DeleteCapsule', () {
    blocTest<CapsulesBloc, CapsulesState>(
      'emits [CapsulesLoading, CapsulesLoaded] after successful deletion',
      build: () {
        when(() => mockRepository.deleteCapsule('1'))
            .thenAnswer((_) async {});
        when(() => mockRepository.getCapsules(
          status: any(named: 'status'),
          search: any(named: 'search'),
        )).thenAnswer((_) async => const CapsulesResult(
          capsules: [],
          hasMore: false,
        ));
        return bloc;
      },
      act: (bloc) => bloc.add(const DeleteCapsule(capsuleId: '1')),
      expect: () => [
        const CapsulesLoading(),
        isA<CapsulesLoaded>(),
      ],
    );
  });

  group('LockCapsule', () {
    blocTest<CapsulesBloc, CapsulesState>(
      'emits [CapsulesLoading, CapsuleOperationSuccess] when successful',
      build: () {
        final lockedCapsule = Capsule(
          id: '1',
          title: 'Test Capsule',
          status: CapsuleStatus.locked,
          unlockDate: DateTime(2025, 12, 25),
          isEncrypted: true,
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 1),
        );
        when(() => mockRepository.lockCapsule('1'))
            .thenAnswer((_) async => lockedCapsule);
        return bloc;
      },
      act: (bloc) => bloc.add(const LockCapsule(capsuleId: '1')),
      expect: () => [
        const CapsulesLoading(),
        isA<CapsuleOperationSuccess>(),
      ],
    );
  });

  group('ArchiveCapsule', () {
    blocTest<CapsulesBloc, CapsulesState>(
      'emits [CapsuleOperationSuccess] when successful',
      build: () {
        final archivedCapsule = Capsule(
          id: '1',
          title: 'Test Capsule',
          status: CapsuleStatus.archived,
          unlockDate: DateTime(2025, 12, 25),
          isEncrypted: true,
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 1),
        );
        when(() => mockRepository.updateCapsule(
          id: '1',
          status: 'ARCHIVED',
        )).thenAnswer((_) async => archivedCapsule);
        return bloc;
      },
      act: (bloc) => bloc.add(const ArchiveCapsule(capsuleId: '1')),
      expect: () => [
        isA<CapsuleOperationSuccess>(),
      ],
    );
  });
}
