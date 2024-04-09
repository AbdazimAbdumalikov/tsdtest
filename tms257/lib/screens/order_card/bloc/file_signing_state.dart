part of 'file_signing_bloc.dart';

@immutable
abstract class FileSigningState {}

class OrderDocumentsInitial extends FileSigningState {}

class OrderDocumentsIsLoadingState extends FileSigningState {}

class OrderDocumentsIsLoadedState extends FileSigningState {
  final List<OrderDocumentSign?> documents;

  OrderDocumentsIsLoadedState({required this.documents});
}

class OrderDocumentsIsLoadedSignState extends FileSigningState {
  final List<OrderDocumentSign?> document;
  final Signed signed;

  OrderDocumentsIsLoadedSignState(
      {required this.document, required this.signed});
}

class OrderDocumentsLoadingErrorState extends FileSigningState {
  final AppError error;

  OrderDocumentsLoadingErrorState({
    required this.error,
  });
}

class OrderIdAndUserIdLoadedState extends FileSigningState {
  final int orderId;
  final int userId;

  OrderIdAndUserIdLoadedState({required this.orderId, required this.userId});
}

class TTNOrderStatusLoading extends FileSigningState {}

class TTNOrderStatusLoaded extends FileSigningState {
  final Signed signed;

  TTNOrderStatusLoaded(this.signed);
}

class TTNOrderStatusError extends FileSigningState {}
