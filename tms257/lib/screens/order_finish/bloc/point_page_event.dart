part of 'point_page_bloc.dart';

@immutable
abstract class PointPageEvent {}

class PointPageEventLoadProducts extends PointPageEvent {
  final int pointId;

  PointPageEventLoadProducts({
    required this.pointId,
  });
}

class PointPageEventOrderCheck extends PointPageEvent {
  final int orderId;

  PointPageEventOrderCheck({
    required this.orderId,
  });
}

class PointPageEventProductFinish extends PointPageEvent {
  final int productId;
  final String code;

  PointPageEventProductFinish({
    required this.productId,
    required this.code,
  });
}

class PointPageEventFinishingPoint extends PointPageEvent {
  final int pointId;
  final List<ContainerDTO> containers;

  PointPageEventFinishingPoint({
    required this.pointId,
    required this.containers,
  });
}

class PointPageEventPhoneList extends PointPageEvent {
  final int pointId;

  PointPageEventPhoneList({
    required this.pointId,
  });
}

class PointPageEventScanBarcode extends PointPageEvent {
  final String code;

  PointPageEventScanBarcode({
    required this.code,
  });
}

class PointPageEventContainerAccept extends PointPageEvent {
  final int containerId;
  final String code;

  PointPageEventContainerAccept({
    required this.containerId,
    required this.code,
  });
}
