import 'dart:developer';
import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:europharm_flutter/network/models/dto_models/response/error.dart';
import 'package:europharm_flutter/network/models/dto_models/response/signed.dart';
import 'package:europharm_flutter/network/models/order_documents.dart';
import 'package:europharm_flutter/network/models/order_documents_sign.dart';
import 'package:europharm_flutter/network/models/order_dto.dart';
import 'package:europharm_flutter/network/models/user_dto.dart';
import 'package:europharm_flutter/network/repository/global_repository.dart';
import 'package:meta/meta.dart';
import 'package:url_launcher/url_launcher.dart';

part 'file_signing_event.dart';
part 'file_signing_state.dart';

const _tag = 'order_documents_page.dart';

class FileSigningBloc extends Bloc<FileSigningEvent, FileSigningState> {
  FileSigningBloc({
    required this.repository,
    required this.orderId,
  }) : super(OrderDocumentsInitial()) {
    on<OrderDocumentsInitialEvent>(_getDocuments);
    on<OrderDocumentsReadFileEvent>(_readFile);
    on<OrderDocumentsSignEvent>(_signFile);
    on<FetchOrderIdAndUserIdEvent>(_fetchOrderIdAndUserId);
    add(OrderDocumentsInitialEvent());
  }

  final GlobalRepository repository;
  final int orderId;

  _getDocuments(
      OrderDocumentsInitialEvent event, Emitter<FileSigningState> emit) async {
    try {
      emit(OrderDocumentsIsLoadingState());
      final UserDTO profile = await repository.getProfile();
      List<OrderDocumentSign> document = await repository.getOrderDocumentSign(
        orderId: orderId,
        userId: profile.id,
      );
      final Signed signed =
          await repository.ttnOrderStatus(orderId, profile.id);
      emit(OrderDocumentsIsLoadedSignState(document: document, signed: signed));
    } on DioError catch (e) {
      log('$e', name: _tag);
      emit(
        OrderDocumentsLoadingErrorState(
          error: AppError(
            message: "${e.response?.data?['message']} (_getDocuments method)",
          ),
        ),
      );
    }
  }

  _readFile(
      OrderDocumentsReadFileEvent event, Emitter<FileSigningState> emit) async {
    launch(event.url);
  }

  _signFile(
      OrderDocumentsSignEvent event, Emitter<FileSigningState> emit) async {
    launch(event.url);
  }

  _fetchOrderIdAndUserId(
      FetchOrderIdAndUserIdEvent event, Emitter<FileSigningState> emit) async {
    try {
      final OrderDTO order =
          await repository.getOrderByOrderId(orderId: orderId);
      final UserDTO user = await repository.getProfile();

      // Отправляем полученные данные в новый стейт для обработки в UI
      emit(OrderIdAndUserIdLoadedState(orderId: order.id, userId: user.id));
    } catch (e) {
      // emit(FetchOrderIdAndUserIdErrorState());
    }
  }

  String _buildSigningUrl(int orderId, int userId) {
    final String baseUrl =
        'https://mgovsign.page.link/?link=https://api.sattiway.kz/api/v2/egov/ttn/mgovSign?order_id%3D$orderId%26user_id%3D$userId%26type_sign%3Dtms';
    final String iosUrl = '$baseUrl&isi=1476128386&ibi=kz.egov.mobile';
    final String androidUrl = '$baseUrl&apn=kz.mobile.mgov';
    return Platform.isIOS ? iosUrl : androidUrl;
  }
}
