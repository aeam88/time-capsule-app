import 'package:equatable/equatable.dart';

abstract class RecipientsEvent extends Equatable {
  const RecipientsEvent();

  @override
  List<Object?> get props => [];
}

class LoadRecipients extends RecipientsEvent {
  final String capsuleId;

  const LoadRecipients({required this.capsuleId});

  @override
  List<Object?> get props => [capsuleId];
}

class AddRecipients extends RecipientsEvent {
  final String capsuleId;
  final List<String> emails;

  const AddRecipients({required this.capsuleId, required this.emails});

  @override
  List<Object?> get props => [capsuleId, emails];
}

class RemoveRecipient extends RecipientsEvent {
  final String capsuleId;
  final String recipientId;

  const RemoveRecipient({required this.capsuleId, required this.recipientId});

  @override
  List<Object?> get props => [capsuleId, recipientId];
}

class RemoveAllRecipients extends RecipientsEvent {
  final String capsuleId;

  const RemoveAllRecipients({required this.capsuleId});

  @override
  List<Object?> get props => [capsuleId];
}
