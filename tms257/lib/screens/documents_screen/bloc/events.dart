part of 'bloc_documents_screen.dart';

@immutable
abstract class EventBlocDocumentsScreen {}

class EventInitialDocumentsScreen extends EventBlocDocumentsScreen {}

class OrderTtnDocumentsInitialEvent extends EventBlocDocumentsScreen {
  final int orderId;

  OrderTtnDocumentsInitialEvent({required this.orderId});
}
