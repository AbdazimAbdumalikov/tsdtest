import 'dart:async';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:europharm_flutter/network/models/dto_models/response/error.dart';
import 'package:europharm_flutter/network/models/dto_models/response/signed.dart';
import 'package:europharm_flutter/network/models/dto_models/response/wms_document_file.dart';
import 'package:europharm_flutter/network/models/order_dto.dart';
import 'package:europharm_flutter/network/models/point_dto.dart';
import 'package:europharm_flutter/network/models/user_dto.dart';
import 'package:europharm_flutter/network/repository/global_repository.dart';
import 'package:europharm_flutter/screens/order_card/ui/accident_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:meta/meta.dart';
import 'package:geolocator/geolocator.dart';

part 'order_detail_event.dart';

part 'order_detail_state.dart';

const _tag = 'bloc_order_card.dart';

class OrderDetailBloc extends Bloc<OrderDetailEvent, OrderDetailState> {
  OrderDetailBloc({
    required this.repository,
    // required this.currentOrder,
  }) : super(OrderDetailStateLoading()) {
    on<OrderDetailEventInitial>(_read);
    on<OrderDetailEventStop>(_stop);
    on<OrderDetailEventAccident>(_sendAccidentReport);
    on<OrderDetailEventDeviation>(_sendDeviationReport);
    on<OrderDetailEventStart>(_start);
    on<OrderDetailEventResume>(_resume);
    on<OrderDetailRefreshEvent>(_refresh);
    on<OrderDetailSignEvent>(_sign);
    on<OrderDetailEventReset>(_dispose);
    on<OrderDetailEventOrderDecline>(_orderDecline);
    on<OrderWmsDocumentsInitialEvent>(_getWmsDocuments);
    on<OrderDetailEventFinishOrder>(_finishOrder);
  }

  final GlobalRepository repository;
  late OrderDTO currentOrder;
  late PointDTO pointDTO;
  int? orderId;
  int? pointId;

  ///
  ///
  /// METHODS
  ///
  ///
  void getCurrentOrder(OrderDTO ord) {
    currentOrder = ord;
  }

  void _dispose(
    OrderDetailEventReset event,
    Emitter<OrderDetailState> emit,
  ) {
    emit(OrderDetailStateLoading());
  }

  Future<void> _read(
    OrderDetailEventInitial event,
    Emitter<OrderDetailState> emit,
  ) async {
    try {
      emit(OrderDetailStateLoading());

      if (currentOrder.status == "stopped") {
        if (currentOrder.orderStatus == null ||
            currentOrder.orderStatus!.stopTimer == null) {
          emit(
            OrderDetailStateError(
              error: AppError(
                message:
                    "orderDetails.orderStatus - ${currentOrder.orderStatus}",
              ),
            ),
          );
          return; // Ранний выход в случае нулевых значений
        }

        if (currentOrder.orderStatus?.stopReason == "") {
          String? otherTimeStart =
              await repository.getOtherReasonTimer(orderId: orderId!);
          if (otherTimeStart == null || otherTimeStart == "") {
            otherTimeStart = DateTime.now().toString();
          }
          emit(OrderDetailStateShowTimer(
              startTimer: DateTime.parse(otherTimeStart), isForth: true));
        } else {
          DateTime? stopTimer = currentOrder.orderStatus!.stopTimer;
          if (stopTimer != null) {
            emit(OrderDetailStateShowTimer(
                startTimer: stopTimer, isForth: false));
          }
        }
      }

      final List<PointDTO> response =
          await repository.orderPoints(event.orderId);
      orderId = event.orderId;
      final bool signed = await repository.ttnStatus(orderId: event.orderId);
      print('TTN status checked: $signed');
      emit(OrderDetailStateLoaded(orderPoints: response, order: currentOrder));
    } catch (e) {
      log('READ: $e', name: _tag);
      emit(
        OrderDetailStateError(
          error: const AppError(message: "Что-то пошло не так 1"),
        ),
      );
    }

    bool signed = await repository.ttnStatus(orderId: event.orderId);
    print('TTN status checked: $signed');
    if (signed == false) {
      emit(OrderDetailStateButtonSign());
      print('Показал false');
    } else if (signed == true) {
      emit(OrderDetailStateButtonTrue());
      print('Показал true');
    } else {
      print('Ошибка');
    }
  }

  Future<void> _resume(
    OrderDetailEventResume event,
    Emitter<OrderDetailState> emit,
  ) async {
    emit(OrderDetailStateLoading());

    try {
      final OrderDTO result = await repository.resumeOrder(orderId!);
      currentOrder = result.copyWith(isCurrent: true);
      // if(orderDetails.status == "stopped"){
      //   emit(StateShowTimerInitial(startTimer: orderDetails.orderStatus!.stopTimer!));
      // }
      emit(OrderDetailStateResumeSuccess());
      // add(EventInitialOrderCard(orderId!));
    } catch (e) {
      emit(
        OrderDetailStateError(
          error: const AppError(message: "Что то пошло не так 2"),
        ),
      );
    }
  }

  Future<void> _start(
    OrderDetailEventStart event,
    Emitter<OrderDetailState> emit,
  ) async {
    emit(OrderDetailStateLoading());

    try {
      emit(OrderDetailStateLoading());
      final currentPosition = await Geolocator.getCurrentPosition();
      final lat = currentPosition.latitude;
      final lng = currentPosition.longitude;
      final result = await repository.acceptOrder(orderId!, lat, lng);
      currentOrder = result.copyWith(isCurrent: true);
      // currentOrder.isCurrent = true;
      emit(OrderDetailStateStartSuccess());
      // add(EventInitialOrderCard(orderId!));
    } catch (e) {
      if (e is DioError && e.response!.statusCode == 500) {
        emit(OrderDetailStateStartSuccess());
        // add(EventInitialOrderCard(orderId!));
      } else {
        emit(
          OrderDetailStateError(
            error: const AppError(message: "Что то пошло не так 3"),
          ),
        );
      }
    }
  }

  Future<void> _stop(
    OrderDetailEventStop event,
    Emitter<OrderDetailState> emit,
  ) async {
    emit(OrderDetailStateLoading());

    try {
      if (event.cause == 'change_driver') {
        final OrderDTO result = await repository.stopOrderAndChangeDriver(
          orderId: orderId!,
          cause: event.cause,
          emptyDriver: event.emptyDriver,
        );
        // result.isCurrent = true;
        currentOrder = result.copyWith(isCurrent: true);
      } else {
        if (event.cause == 'other') {
          repository.saveOtherReasonTimer(orderId: orderId!);
        }
        final result = await repository.stopOrder(
          orderId: orderId!,
          pointId: event.pointId,
          cause: event.cause,
          emptyDriver: event.emptyDriver,
        );
        // result.isCurrent = true;
        currentOrder = result.copyWith(isCurrent: true);
      }
      // if (event is OrderDetailEventAccident) { // Проверка на событие "accident"
      //   await _sendAccidentReport(event as OrderDetailEventAccident, emit);
      // } else {
      //   emit(OrderDetailStateStopSuccess());
      //   // add(EventInitialOrderCard(orderId!));
      // }
      // if(orderDetails.status == "stopped"){
      //   emit(StateShowTimerInitial(startTimer: orderDetails.orderStatus!.stopTimer!));
      // }
      if (event.cause == 'change_driver') {
        emit(OrderDetailStateChangedDriverOrderCard());
      } else {
        emit(OrderDetailStateStopSuccess());
        // add(EventInitialOrderCard(orderId!));
      }
    } catch (e) {
      emit(
        OrderDetailStateError(
          error: const AppError(message: "Что то пошло не так (_stop method)"),
        ),
      );
    }
  }

  Future<void> _sendAccidentReport(
    OrderDetailEventAccident event,
    Emitter<OrderDetailState> emit,
  ) async {
    emit(OrderDetailStateLoading());

    try {
      final currentPosition = await Geolocator.getCurrentPosition();
      final lat = currentPosition.latitude;
      final lng = currentPosition.longitude;

      // Замените OrderRepository на ваш репозиторий для работы с заказами
      final response = await repository.reportAccident(
        orderId: orderId!,
        message: event.message,
        lat: lat,
        lng: lng,
      );

      print('Данные отправлены на сервер:');
      print('Номер заказа: ${orderId}');
      print('Сообщение: ${event.message}');
      print('Координаты (lat, lng): ($lat, $lng)');
      print('Статус кода ответа: ${response.statusCode}');

      // Проверьте успешность отправки отчета
      if (response.statusCode == 200) {
        emit(OrderDetailStateStopSuccess());
      } else {
        emit(
          OrderDetailStateError(
            error: AppError(message: "Ошибка при отправке отчета о ДТП"),
          ),
        ); // Отправьте состояние ошибки в случае неудачи
      }
    } catch (e) {
      emit(
        OrderDetailStateError(
          error: AppError(message: "Ошибка при отправке отчета о ДТП"),
        ),
      ); // Обработайте ошибку и отправьте соответствующее состояние
    }
  }

  Future<void> _sendDeviationReport(
    OrderDetailEventDeviation event,
    Emitter<OrderDetailState> emit,
  ) async {
    emit(OrderDetailStateLoading());

    try {
      final currentPosition = await Geolocator.getCurrentPosition();

      final response = await repository.reportDeviation(
        orderId: event.orderId,
        pointId: event.pointId,
        // message: event.message,
        lat: currentPosition.latitude,
        lng: currentPosition.longitude,
      );

      print('Данные отправлены на сервер:');
      print('Номер заказа: ${event.orderId}');
      print('Номер точки: ${event.pointId}');
      // print('Сообщение: ${event.message}');
      print(
          'Координаты (lat, lng): (${currentPosition.latitude}, ${currentPosition.longitude})');
      print('Статус кода ответа: ${response.statusCode}');

      if (response.statusCode == 200) {
        emit(OrderDetailStateDeviationSuccess());
      } else {
        emit(
          OrderDetailStateError(
            error: AppError(message: "Ошибка при отправке отчета о девиации"),
          ),
        );
      }
    } catch (e) {
      emit(
        OrderDetailStateError(
          error: AppError(message: "Ошибка при отправке отчета о девиации"),
        ),
      );
    }
  }

  Future<void> _refresh(
    OrderDetailRefreshEvent event,
    Emitter<OrderDetailState> emit,
  ) async {
    try {
      emit(OrderDetailStateLoading());
      //bool isFinished = true;
      final OrderDTO refreshedOrder = await repository.getOrderByOrderId(
        orderId: event.orderId,
      );
      final UserDTO users = await repository.getProfile();
      currentOrder = refreshedOrder;
      orderId = event.orderId;
      log('message 1');

      if (currentOrder.status == "stopped") {
        if (currentOrder.orderStatus == null ||
            currentOrder.orderStatus!.stopTimer == null) {
          emit(
            OrderDetailStateError(
              error: AppError(
                message:
                    "orderDetails.orderStatus - ${currentOrder.orderStatus}",
              ),
            ),
          );
        } else {
          log('message 2');
          if (currentOrder.orderStatus!.stopReason == "") {
            String otherTimeStart =
                await repository.getOtherReasonTimer(orderId: orderId!);
            if (otherTimeStart == null || otherTimeStart == "") {
              otherTimeStart = DateTime.now().toString();
            }
            emit(OrderDetailStateShowTimer(
                startTimer: DateTime.parse(otherTimeStart), isForth: true));
          } else {
            emit(OrderDetailStateShowTimer(
                startTimer: currentOrder.orderStatus!.stopTimer!,
                isForth: false));
          }
        }
      }

      final List<PointDTO> points = await repository.orderPoints(event.orderId);
      emit(
        OrderDetailStateLoaded(
          orderPoints: points,
          order: currentOrder.copyWith(
            isCurrent: currentOrder.status == 'accepted' ||
                currentOrder.status == 'in_process' ||
                currentOrder.status == 'stopped',
          ),
        ),
      );
      // bool signed = await repository.ttnStatus(orderId: event.orderId);
      // print('TTN status checked: $signed');

      // if (signed == false) {
      //   emit(OrderDetailStateButtonFalse());
      //   print('Показал false');
      // }

      // if (signed == true) {
      //   emit(OrderDetailStateButtonTrue());
      //   print('Показал true');
      // }
    } catch (e) {
      log('_refresh::: $e', name: _tag);
      emit(
        OrderDetailStateError(
          error:
              const AppError(message: "Что то пошло не так (_refresh method)"),
        ),
      );
    }
  }

  Future<void> _sign(
    OrderDetailSignEvent event,
    Emitter<OrderDetailState> emit,
  ) async {
    try {
      emit(OrderDetailStateLoading());
      bool signed = await repository.ttnStatus(orderId: event.orderId);
      print('TTN status checked: $signed');
      if (signed == false) {
        emit(OrderDetailStateButtonSign());
        print('Показал false');
      } else if (signed == true) {
        emit(OrderDetailStateButtonTrue());
        print('Показал true');
      } else {
        print('Ошибка');
      }
    } catch (e) {
      log('_sign::: $e', name: _tag);
      emit(
        OrderDetailStateError(
          error: const AppError(message: "Что-то пошло не так (_sign method)"),
        ),
      );
    }
  }

  Future<void> _orderDecline(
    OrderDetailEventOrderDecline event,
    Emitter<OrderDetailState> emit,
  ) async {
    emit(OrderDetailStateLoading());

    try {
      String message = await repository.orderDecline(orderId: event.orderId);
      emit(OrderDetailStateChangedDriverOrderCard());
    } on DioError catch (e) {
      log('$e', name: _tag);
      emit(
        OrderDetailStateError(
          error: AppError(
              message: "${e.response?.data?['message']} (_finishOrder method)"),
        ),
      );
      add(OrderDetailRefreshEvent(orderId: event.orderId));
    }
  }

  _getWmsDocuments(OrderWmsDocumentsInitialEvent event,
      Emitter<OrderDetailState> emit) async {
    try {
      emit(OrderDetailStateLoading());
      List<WmsDocument> document = await repository.getWmsDocuments(
        orderId: event.orderId,
      );
      emit(OrdeWmsDocumentsIsLoadedSignState(document: document));
    } on DioError catch (e) {
      log('$e', name: _tag);
      emit(
        OrderWmsDocumentsLoadingErrorState(
          error: AppError(
            message: "${e.response?.data?['message']} (_getDocuments method)",
          ),
        ),
      );
    }
  }

  Future<void> _finishOrder(
    OrderDetailEventFinishOrder event,
    Emitter<OrderDetailState> emit,
  ) async {
    emit(OrderDetailStateLoading());

    try {
      String message = await repository.orderFinish(orderId: event.orderId);
      emit(OrderDetailStateChangedDriverOrderCard());
      print("complete = true Все успешно закрыли заказ!");
      // if (currentOrder.orderType == 1) {
      //   String message = await repository.orderFinish(orderId: event.orderId);
      //   print("Обратились к orderType = 1");
      //   emit(OrderDetailStateChangedDriverOrderCard());
      //   print("orderType = 1 выполнено успешно");
      // } else if (currentOrder.orderType == 2) {
      //   print("Распознаем что orderType = 2");
      //   emit(OrderDetailStateCheckInProgress());
      //   final orderCheckResponse = await repository.orderCheck(event.orderId);
      //   print("Обратились к апи");
      //   if (orderCheckResponse.data!.complete = true) {
      //     print("complete = true");
      //     String message = await repository.orderFinish(orderId: event.orderId);
      //     emit(OrderDetailStateChangedDriverOrderCard());
      //     print("complete = true Все успешно закрыли заказ!");
      //   } else {
      //     // Невозможно завершить заказ в данный момент
      //     emit(OrderDetailStateCheckComplete(complete: false));
      //     print("complete = false Невозможно закрыть заказ!");
      //   }
      // }
    } on DioError catch (e) {
      log('$e', name: _tag);
      emit(
        OrderDetailStateError(
          error: AppError(
              message: "${e.response?.data?['message']} (_finishOrder method)"),
        ),
      );
      add(OrderDetailRefreshEvent(
        orderId: event.orderId,
      ));
    }
  }
}
