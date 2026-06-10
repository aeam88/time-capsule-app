import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/errors/api_exception.dart';
import '../data/repositories/recipients_repository.dart';
import 'recipients_event.dart';
import 'recipients_state.dart';

class RecipientsBloc extends Bloc<RecipientsEvent, RecipientsState> {
  final RecipientsRepository repository;

  RecipientsBloc({required this.repository}) : super(const RecipientsInitial()) {
    on<LoadRecipients>(_onLoad);
    on<AddRecipients>(_onAdd);
    on<RemoveRecipient>(_onRemove);
    on<RemoveAllRecipients>(_onRemoveAll);
  }

  Future<void> _onLoad(
    LoadRecipients event,
    Emitter<RecipientsState> emit,
  ) async {
    emit(const RecipientsLoading());
    try {
      final recipients = await repository.getRecipients(event.capsuleId);
      emit(RecipientsLoaded(recipients: recipients));
    } on ApiException catch (e) {
      emit(RecipientsError(message: e.message));
    } catch (e) {
      emit(RecipientsError(message: 'Error inesperado: $e'));
    }
  }

  Future<void> _onAdd(
    AddRecipients event,
    Emitter<RecipientsState> emit,
  ) async {
    try {
      final result = await repository.addRecipients(
        capsuleId: event.capsuleId,
        emails: event.emails,
      );
      final allRecipients = await repository.getRecipients(event.capsuleId);
      final message = result.addedCount == event.emails.length
          ? '${result.addedCount} destinatario(s) agregado(s)'
          : '${result.addedCount} agregado(s), ${result.skippedCount} omitido(s)';
      emit(RecipientsOperationSuccess(
        message: message,
        recipients: allRecipients,
      ));
    } on ApiException catch (e) {
      emit(RecipientsError(message: e.message));
    } catch (e) {
      emit(RecipientsError(message: 'Error inesperado: $e'));
    }
  }

  Future<void> _onRemove(
    RemoveRecipient event,
    Emitter<RecipientsState> emit,
  ) async {
    try {
      await repository.removeRecipient(
        capsuleId: event.capsuleId,
        recipientId: event.recipientId,
      );
      final recipients = await repository.getRecipients(event.capsuleId);
      emit(RecipientsOperationSuccess(
        message: 'Destinatario eliminado',
        recipients: recipients,
      ));
    } on ApiException catch (e) {
      emit(RecipientsError(message: e.message));
    } catch (e) {
      emit(RecipientsError(message: 'Error inesperado: $e'));
    }
  }

  Future<void> _onRemoveAll(
    RemoveAllRecipients event,
    Emitter<RecipientsState> emit,
  ) async {
    try {
      await repository.removeAllRecipients(event.capsuleId);
      emit(const RecipientsOperationSuccess(
        message: 'Todos los destinatarios eliminados',
        recipients: [],
      ));
    } on ApiException catch (e) {
      emit(RecipientsError(message: e.message));
    } catch (e) {
      emit(RecipientsError(message: 'Error inesperado: $e'));
    }
  }
}
