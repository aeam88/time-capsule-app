import 'package:equatable/equatable.dart';
import '../data/models/capsule_model.dart';

abstract class CapsulesState extends Equatable {
  const CapsulesState();

  @override
  List<Object?> get props => [];
}

class CapsulesInitial extends CapsulesState {
  const CapsulesInitial();
}

class CapsulesLoading extends CapsulesState {
  const CapsulesLoading();
}

class CapsulesLoaded extends CapsulesState {
  final List<Capsule> capsules;
  final bool hasMore;
  final String? currentFilter;
  final String? searchQuery;

  const CapsulesLoaded({
    required this.capsules,
    this.hasMore = true,
    this.currentFilter,
    this.searchQuery,
  });

  @override
  List<Object?> get props => [capsules, hasMore, currentFilter, searchQuery];
}

class CapsulesError extends CapsulesState {
  final String message;

  const CapsulesError({required this.message});

  @override
  List<Object?> get props => [message];
}

class CapsuleDetailLoaded extends CapsulesState {
  final Capsule capsule;

  const CapsuleDetailLoaded({required this.capsule});

  @override
  List<Object?> get props => [capsule];
}

class CapsuleOperationSuccess extends CapsulesState {
  final String message;
  final Capsule? capsule;

  const CapsuleOperationSuccess({
    required this.message,
    this.capsule,
  });

  @override
  List<Object?> get props => [message, capsule];
}
