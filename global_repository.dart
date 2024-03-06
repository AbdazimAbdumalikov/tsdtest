import 'package:europharm_flutter/network/models/dto_models/response/cars_response.dart';
import 'package:europharm_flutter/network/models/dto_models/response/cities_response.dart';
import 'package:europharm_flutter/network/models/dto_models/response/container_accept.dart';
import 'package:europharm_flutter/network/models/dto_models/response/deviation_model.dart';
import 'package:europharm_flutter/network/models/dto_models/response/login_response.dart';
import 'package:europharm_flutter/network/models/dto_models/response/marks_response.dart';
import 'package:europharm_flutter/network/models/dto_models/response/order_accident.dart';
import 'package:europharm_flutter/network/models/dto_models/response/order_history_response.dart';
import 'package:europharm_flutter/network/models/dto_models/response/phone_code_register_response.dart';
import 'package:europharm_flutter/network/models/dto_models/response/phone_register_response.dart';
import 'package:europharm_flutter/network/models/dto_models/response/positions_response.dart';
import 'package:europharm_flutter/network/models/dto_models/response/signed.dart';
import 'package:europharm_flutter/network/models/dto_models/response/wms_document_file.dart';
import 'package:europharm_flutter/network/models/notification_dto.dart';
import 'package:europharm_flutter/network/models/order_documents.dart';
import 'package:europharm_flutter/network/models/order_documents_sign.dart';
import 'package:europharm_flutter/network/models/order_dto.dart';
import 'package:europharm_flutter/network/models/point_dto.dart';
import 'package:europharm_flutter/network/models/repairs.dart';
import 'package:europharm_flutter/network/models/user_dto.dart';
import 'package:europharm_flutter/network/repository/hive_repository.dart';
import 'package:europharm_flutter/network/services/network_service.dart';
import 'package:europharm_flutter/screens/personal_data_screen/ui/widgets/_vmodel.dart';
import 'package:europharm_flutter/screens/user_confirmation/ui/_vmodel.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GlobalRepository {
  late final NetworkService _networkService;

  void init(NetworkService networkService, HiveRepository hiveRepository) {
    _networkService = networkService;
  }

  Future<LoginResponse> login(String phone, String password) async =>
      _networkService.login(phone, password);

  Future<void> deleteAccount(int userId) async =>
      _networkService.deleteAccount(userId);

  Future<PhoneRegisterResponse> registerPhone(String phone) async =>
      _networkService.registerPhone(phone);

  Future<PhoneCodeRegisterResponse> registerPhoneCode(
    String phone,
    String code,
  ) async =>
      _networkService.registerPhoneCode(phone, code);

  Future<PhoneCodeRegisterResponse> registerConfirm(
    String password,
    String registerToken,
    String deviceOs,
    String deviceToken,
  ) async =>
      _networkService.registerConfirm(
        password,
        registerToken,
        deviceOs,
        deviceToken,
      );

  Future<UserDTO> getProfile() async => _networkService.getProfile();

  Future<CarsResponse> getCars() async => _networkService.getCars();

  Future<MarksResponse> getMarks() async => _networkService.getMarks();

  Future<CitiesResponse> getCities() async => _networkService.getCities();

  Future<List<OrderDTO>> acceptedOrders() async =>
      _networkService.acceptedOrders();

  Future<List<OrderDTO>> getOrdersByCities({
    String? cityId,
  }) async =>
      _networkService.getOrdersByCities(cityId: cityId);

  Future<void> verify(PersonalInfoVModel vModel) async =>
      _networkService.verify(vModel);

  Future<OrderDTO> acceptOrder(int orderId) async =>
      _networkService.acceptOrder(orderId);

  Future<List<PointDTO>> orderPoints(int orderId) async =>
      _networkService.orderPoints(orderId);

  Future<String> sendContainers(List<ContainerDTO> containers) async {
    return _networkService.sendContainers(containers);
  }

  Future<PointDTO> orderPointProducts(int pointId) async =>
      _networkService.orderPointProducts(pointId);

  Future<PointDTO> orderProductFinish(int productId, String code) async =>
      _networkService.orderProductFinish(productId, code);

  Future<PointDTO> orderPointFinish({
    required int pointId,
  }) async =>
      _networkService.orderPointFinish(pointId: pointId);

  Future<OrderDTO> stopOrder({
    required int orderId,
    required int pointId,
    required String cause,
    UserDTO? emptyDriver,
  }) async =>
      _networkService.stopOrder(
        orderId: orderId,
        pointId: pointId,
        cause: cause,
        emptyDriver: emptyDriver,
      );

  Future<OrderAccident> orderAccident({
    required OrderDTO order,
    required String message,
    required double lat,
    required double lng,
  }) async =>
      _networkService.orderAccident(
        orderId: order.id,
        message: message,
        lat: lat,
        lng: lng,
      );

  Future<OrderDTO> stopOrderAndChangeDriver({
    required int orderId,
    required String cause,
    UserDTO? emptyDriver,
  }) async =>
      _networkService.stopOrderAndChangeDriver(
        orderId: orderId,
        cause: cause,
        emptyDriver: emptyDriver,
      );

  Future<OrderDTO> resumeOrder(int orderId) async =>
      _networkService.resumeOrder(orderId);

  Future<OrderHistoryResponse> orderHistory(
    String startDate,
    String endDate,
  ) async =>
      _networkService.orderHistory(startDate, endDate);

  Future<PositionsResponse> getPositions() async =>
      _networkService.getPositions();

  Future<void> editProfile(
    PersonalDataVModel vModel,
  ) async =>
      _networkService.editProfile(vModel);

  Future<ContainerAcceptTap> acceptContainerOrder(
      int containerId, String code) async {
    try {
      final response =
          await _networkService.acceptContainerOrder(containerId, code);
      // Здесь дополнительная обработка успешного ответа
      return response;
    } catch (e) {
      // Здесь обработка ошибки
      print("Error accepting container order: $e");
      rethrow; // Повторное выбрасывание ошибки для дальнейшей обработки в коде вызывающем метод
    }
  }

  Future<ContainerAcceptTap> acceptContainerOrderScan(String code) async {
    try {
      final response = await _networkService.acceptContainerOrderScan(code);
      // Здесь дополнительная обработка успешного ответа
      return response;
    } catch (e) {
      // Здесь обработка ошибки
      print("Error accepting container order: $e");
      rethrow; // Повторное выбрасывание ошибки для дальнейшей обработки в коде вызывающем метод
    }
  }

  Future<OrderAccident> reportAccident(
      {required int orderId,
      required String message,
      required double lat,
      required double lng
      // Add any other required parameters like orderId, pointId, lat, lng if needed.
      }) async {
    try {
      final response = await _networkService.reportAccident(
        orderId: orderId,
        message: message,
        lat: lat,
        lng: lng,
      );

      // Check if the response indicates success.
      if (response.success == true) {
        // The accident report was successful. You can perform additional actions here.
        // For example, you can log the success message.
        print(
            "Accident reported successfully: ${response.message}, ${response.statusCode}, ${response.success}, ${response.data}");

        // You can also return some meaningful data if needed.
        return response;
      } else {
        // Handle the case where the response indicates failure.
        // You can log the error message or perform other actions.
        print("Accident report failed: ${response.message}");
        // You can choose to throw an exception or return an appropriate value based on your application's logic.
        throw Exception("Accident report failed: ${response.message}");
      }
    } catch (e) {
      // Handle the error, e.g., log it or perform other actions.
      print("Error reporting accident: $e");
      rethrow; // Re-throw the error for further handling in the calling code.
    }
  }

  Future<Deviation> reportDeviation(
      {required int orderId,
      required int pointId,
      // required String message,
      required double lat,
      required double lng
      // Add any other required parameters like orderId, pointId, lat, lng if needed.
      }) async {
    try {
      final response = await _networkService.reportDeviation(
        orderId: orderId,
        pointId: pointId,
        // message: message,
        lat: lat,
        lng: lng,
      );

      // Check if the response indicates success.
      if (response.success == true) {
        // The accident report was successful. You can perform additional actions here.
        // For example, you can log the success message.
        print(
            "Accident reported successfully: ${response.message}, ${response.statusCode}, ${response.success}, ${response.data}");

        // You can also return some meaningful data if needed.
        return response;
      } else {
        // Handle the case where the response indicates failure.
        // You can log the error message or perform other actions.
        print("Accident report failed: ${response.message}");
        // You can choose to throw an exception or return an appropriate value based on your application's logic.
        throw Exception("Accident report failed: ${response.message}");
      }
    } catch (e) {
      // Handle the error, e.g., log it or perform other actions.
      print("Error reporting accident: $e");
      rethrow; // Re-throw the error for further handling in the calling code.
    }
  }

  Future<void> sendDeviceToken(String deviceToken) async =>
      _networkService.sendDeviceToken(deviceToken: deviceToken);

  Future<void> logout() async => _networkService.logout();

  Future<List<NotificationDTO>> getNotifications() async =>
      _networkService.getNotifications();

  Future<List<UserDTO>> getEmptyDrivers() async =>
      _networkService.getEmptyDrivers();

  Future<List<PointDTO>> getPointsByDate({
    required String fromDate,
    required String toDate,
  }) async =>
      _networkService.getPointsByDate(
        fromDate: fromDate,
        toDate: toDate,
      );

  Future<OrderDTO> getOrderByOrderId({
    required int orderId,
  }) async =>
      _networkService.getOrderByOrderId(
        orderId: orderId,
      );

  Future<String> orderDecline({
    required int orderId,
  }) async =>
      _networkService.orderDecline(
        orderId: orderId,
      );

  Future<String> orderFinish({
    required int orderId,
  }) async =>
      _networkService.orderFinish(
        orderId: orderId,
      );

  Future<List<OrderDTO>> getOrdersByDate({
    required String startDate,
    required String endDate,
  }) async =>
      _networkService.getOrdersByDate(
        startDate: startDate,
        endDate: endDate,
      );

  Future<void> saveOtherReasonTimer({
    required int orderId,
  }) async {
    final SharedPreferences _preferences =
        await SharedPreferences.getInstance();
    _preferences.setString('$orderId OTHERTIME', DateTime.now().toString());
  }

  Future<String> getOtherReasonTimer({
    required int orderId,
  }) async {
    final SharedPreferences _preferences =
        await SharedPreferences.getInstance();
    return _preferences.getString('$orderId OTHERTIME') as String;
  }

  Future<List<OrderDocuments>> getOrderDocuments(
          {required int orderId, required int userId}) async =>
      _networkService.getOrderDocuments(orderId: orderId, userId: userId);

  Future<List<OrderDocumentSign>> getOrderDocumentSign(
          {required int orderId, required int userId}) async =>
      _networkService.getOrderDocumentSign(orderId: orderId, userId: userId);

  Future<List<WmsDocument>> getWmsDocuments({required int orderId}) async =>
      _networkService.getWmsDocuments(orderId: orderId);

  Future<List<Repairs>> getRepairs() async => _networkService.getRepairs();

  Future<bool> ttnStatus({required orderId}) async {
    try {
      final bool isSigned = await _networkService.ttnStatus(orderId);
      return isSigned;
    } catch (e) {
      // Обработка ошибок при вызове метода checkTTNStatus
      print("Error checking TTN status: $e");
      return false;
    }
  }
}
