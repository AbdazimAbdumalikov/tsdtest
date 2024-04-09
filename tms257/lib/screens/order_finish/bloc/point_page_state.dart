part of 'point_page_bloc.dart';

@immutable
abstract class PointPageState {}

class PointPageStateLoading extends PointPageState {}

class PointPageStateLoaded extends PointPageState {
  final PointDTO orderPoint;
  final bool areAllFinished;

  PointPageStateLoaded({
    required this.orderPoint,
    this.areAllFinished = false,
  });
}

class PointPageStateCheckInProgress extends PointPageState {}

class PointPageStateCheckComplete extends PointPageState {
  final bool complete;

  PointPageStateCheckComplete({required this.complete});
}

class PointPagelStateCheckFailed extends PointPageState {
  final String errorMessage;

  PointPagelStateCheckFailed({required this.errorMessage});
}

class PointPageStateFinished extends PointPageState {}

class PointPageStatePhoneListLoaded extends PointPageState {
  final PhoneList phoneList;

  PointPageStatePhoneListLoaded({required this.phoneList});

  @override
  List<Object?> get props => [phoneList];
}

class PointPageStateContainerAccepted extends PointPageState {
  final String message;

  PointPageStateContainerAccepted({
    required this.message,
    required bool areAllFinished,
  });
}

class PointPageStateError extends PointPageState {
  final AppError error;

  PointPageStateError({
    required this.error,
  });
}
