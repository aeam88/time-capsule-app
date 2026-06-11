import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/errors/api_exception.dart';
import '../data/repositories/capsules_repository.dart';
import 'capsules_event.dart';
import 'capsules_state.dart';

class CapsulesBloc extends Bloc<CapsulesEvent, CapsulesState> {
  final CapsulesRepository repository;
  String? _currentFilter;
  String? _searchQuery;
  String? _nextCursor;

  CapsulesBloc({required this.repository})
      : super(const CapsulesInitial()) {
    on<LoadCapsules>(_onLoadCapsules);
    on<LoadMoreCapsules>(_onLoadMoreCapsules);
    on<FilterCapsulesByStatus>(_onFilterByStatus);
    on<SearchCapsules>(_onSearch);
    on<DeleteCapsule>(_onDeleteCapsule);
    on<CreateCapsule>(_onCreateCapsule);
    on<LoadCapsuleDetail>(_onLoadCapsuleDetail);
    on<UpdateCapsule>(_onUpdateCapsule);
    on<LockCapsule>(_onLockCapsule);
    on<UnlockCapsule>(_onUnlockCapsule);
    on<ArchiveCapsule>(_onArchiveCapsule);
  }

  Future<void> _onLoadCapsules(
    LoadCapsules event,
    Emitter<CapsulesState> emit,
  ) async {
    emit(const CapsulesLoading());
    try {
      final result = await repository.getCapsules(
        status: _currentFilter,
        search: _searchQuery,
      );
      _nextCursor = result.nextCursor;
      emit(CapsulesLoaded(
        capsules: result.capsules,
        hasMore: result.hasMore,
        currentFilter: _currentFilter,
        searchQuery: _searchQuery,
      ));
    } on ApiException catch (e) {
      emit(CapsulesError(message: e.message));
    } catch (e) {
      emit(CapsulesError(message: 'Error inesperado: $e'));
    }
  }

  Future<void> _onLoadMoreCapsules(
    LoadMoreCapsules event,
    Emitter<CapsulesState> emit,
  ) async {
    if (state is! CapsulesLoaded) return;
    final currentState = state as CapsulesLoaded;
    if (!currentState.hasMore) return;

    try {
      final result = await repository.getCapsules(
        status: _currentFilter,
        search: _searchQuery,
        cursor: _nextCursor,
      );
      _nextCursor = result.nextCursor;
      emit(CapsulesLoaded(
        capsules: [...currentState.capsules, ...result.capsules],
        hasMore: result.hasMore,
        currentFilter: _currentFilter,
        searchQuery: _searchQuery,
      ));
    } on ApiException catch (e) {
      emit(CapsulesError(message: e.message));
    } catch (e) {
      emit(CapsulesError(message: 'Error inesperado: $e'));
    }
  }

  Future<void> _onFilterByStatus(
    FilterCapsulesByStatus event,
    Emitter<CapsulesState> emit,
  ) async {
    _currentFilter = event.status;
    _nextCursor = null;
    add(const LoadCapsules());
  }

  Future<void> _onSearch(
    SearchCapsules event,
    Emitter<CapsulesState> emit,
  ) async {
    _searchQuery = event.query.isEmpty ? null : event.query;
    _nextCursor = null;
    add(const LoadCapsules());
  }

  Future<void> _onDeleteCapsule(
    DeleteCapsule event,
    Emitter<CapsulesState> emit,
  ) async {
    try {
      await repository.deleteCapsule(event.capsuleId);
      add(const LoadCapsules());
    } on ApiException catch (e) {
      emit(CapsulesError(message: e.message));
    } catch (e) {
      emit(CapsulesError(message: 'Error inesperado: $e'));
    }
  }

  Future<void> _onCreateCapsule(
    CreateCapsule event,
    Emitter<CapsulesState> emit,
  ) async {
    emit(const CapsulesLoading());
    try {
      final capsule = await repository.createCapsule(
        title: event.title,
        description: event.description,
        unlockDate: event.unlockDate,
        isEncrypted: event.isEncrypted,
      );
      emit(CapsuleOperationSuccess(
        message: 'Cápsula creada exitosamente',
        capsule: capsule,
      ));
      add(const LoadCapsules());
    } on ApiException catch (e) {
      emit(CapsulesError(message: e.message));
    } catch (e) {
      emit(CapsulesError(message: 'Error inesperado: $e'));
    }
  }

  Future<void> _onLoadCapsuleDetail(
    LoadCapsuleDetail event,
    Emitter<CapsulesState> emit,
  ) async {
    try {
      final capsule = await repository.getCapsuleById(event.capsuleId);
      emit(CapsuleDetailLoaded(capsule: capsule));
    } on ApiException catch (e) {
      emit(CapsulesError(message: e.message));
    } catch (e) {
      emit(CapsulesError(message: 'Error inesperado: $e'));
    }
  }

  Future<void> _onUpdateCapsule(
    UpdateCapsule event,
    Emitter<CapsulesState> emit,
  ) async {
    try {
      final capsule = await repository.updateCapsule(
        id: event.capsuleId,
        title: event.title,
        description: event.description,
        unlockDate: event.unlockDate,
      );
      emit(CapsuleOperationSuccess(
        message: 'Cápsula actualizada exitosamente',
        capsule: capsule,
      ));
    } on ApiException catch (e) {
      emit(CapsulesError(message: e.message));
    } catch (e) {
      emit(CapsulesError(message: 'Error inesperado: $e'));
    }
  }

  Future<void> _onLockCapsule(
    LockCapsule event,
    Emitter<CapsulesState> emit,
  ) async {
    emit(const CapsulesLoading());
    try {
      final capsule = await repository.lockCapsule(event.capsuleId);
      emit(CapsuleOperationSuccess(
        message: 'Cápsula bloqueada exitosamente',
        capsule: capsule,
      ));
    } on ApiException catch (e) {
      emit(CapsulesError(message: e.message));
    } catch (e) {
      emit(CapsulesError(message: 'Error inesperado: $e'));
    }
  }

  Future<void> _onUnlockCapsule(
    UnlockCapsule event,
    Emitter<CapsulesState> emit,
  ) async {
    emit(const CapsulesLoading());
    try {
      final capsule = await repository.unlockCapsule(event.capsuleId);
      emit(CapsuleOperationSuccess(
        message: 'Cápsula desbloqueada exitosamente',
        capsule: capsule,
      ));
    } on ApiException catch (e) {
      emit(CapsulesError(message: e.message));
    } catch (e) {
      emit(CapsulesError(message: 'Error inesperado: $e'));
    }
  }

  Future<void> _onArchiveCapsule(
    ArchiveCapsule event,
    Emitter<CapsulesState> emit,
  ) async {
    try {
      final capsule = await repository.updateCapsule(
        id: event.capsuleId,
        status: 'ARCHIVED',
      );
      emit(CapsuleOperationSuccess(
        message: 'Cápsula archivada exitosamente',
        capsule: capsule,
      ));
    } on ApiException catch (e) {
      emit(CapsulesError(message: e.message));
    } catch (e) {
      emit(CapsulesError(message: 'Error inesperado: $e'));
    }
  }
}
