import 'package:equatable/equatable.dart';

abstract class CapsulesEvent extends Equatable {
  const CapsulesEvent();

  @override
  List<Object?> get props => [];
}

class LoadCapsules extends CapsulesEvent {
  const LoadCapsules();
}

class LoadMoreCapsules extends CapsulesEvent {
  const LoadMoreCapsules();
}

class FilterCapsulesByStatus extends CapsulesEvent {
  final String? status;

  const FilterCapsulesByStatus({this.status});

  @override
  List<Object?> get props => [status];
}

class SearchCapsules extends CapsulesEvent {
  final String query;

  const SearchCapsules({required this.query});

  @override
  List<Object?> get props => [query];
}

class DeleteCapsule extends CapsulesEvent {
  final String capsuleId;

  const DeleteCapsule({required this.capsuleId});

  @override
  List<Object?> get props => [capsuleId];
}

class CreateCapsule extends CapsulesEvent {
  final String title;
  final String? description;
  final DateTime unlockDate;
  final bool isEncrypted;

  const CreateCapsule({
    required this.title,
    this.description,
    required this.unlockDate,
    this.isEncrypted = true,
  });

  @override
  List<Object?> get props => [title, description, unlockDate, isEncrypted];
}

class LoadCapsuleDetail extends CapsulesEvent {
  final String capsuleId;

  const LoadCapsuleDetail({required this.capsuleId});

  @override
  List<Object?> get props => [capsuleId];
}

class UpdateCapsule extends CapsulesEvent {
  final String capsuleId;
  final String? title;
  final String? description;
  final DateTime? unlockDate;

  const UpdateCapsule({
    required this.capsuleId,
    this.title,
    this.description,
    this.unlockDate,
  });

  @override
  List<Object?> get props => [capsuleId, title, description, unlockDate];
}

class LockCapsule extends CapsulesEvent {
  final String capsuleId;

  const LockCapsule({required this.capsuleId});

  @override
  List<Object?> get props => [capsuleId];
}

class UnlockCapsule extends CapsulesEvent {
  final String capsuleId;

  const UnlockCapsule({required this.capsuleId});

  @override
  List<Object?> get props => [capsuleId];
}

class ArchiveCapsule extends CapsulesEvent {
  final String capsuleId;

  const ArchiveCapsule({required this.capsuleId});

  @override
  List<Object?> get props => [capsuleId];
}

class LoadSharedCapsules extends CapsulesEvent {
  const LoadSharedCapsules();
}
