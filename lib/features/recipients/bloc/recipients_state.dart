import 'package:equatable/equatable.dart';
import '../data/models/recipient_model.dart';

abstract class RecipientsState extends Equatable {
  const RecipientsState();

  @override
  List<Object?> get props => [];
}

class RecipientsInitial extends RecipientsState {
  const RecipientsInitial();
}

class RecipientsLoading extends RecipientsState {
  const RecipientsLoading();
}

class RecipientsLoaded extends RecipientsState {
  final List<Recipient> recipients;

  const RecipientsLoaded({required this.recipients});

  @override
  List<Object?> get props => [recipients];
}

class RecipientsError extends RecipientsState {
  final String message;

  const RecipientsError({required this.message});

  @override
  List<Object?> get props => [message];
}

class RecipientsOperationSuccess extends RecipientsState {
  final String message;
  final List<Recipient> recipients;

  const RecipientsOperationSuccess({
    required this.message,
    required this.recipients,
  });

  @override
  List<Object?> get props => [message, recipients];
}
