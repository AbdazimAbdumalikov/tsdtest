import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:geolocator/geolocator.dart';
import 'package:pharmacy_arrival/core/error/excepteion.dart';
import 'package:pharmacy_arrival/core/error/failure.dart';
import 'package:pharmacy_arrival/core/platform/network_info.dart';
import 'package:pharmacy_arrival/data/datasource/local/accept_containers_local_ds.dart';
import 'package:pharmacy_arrival/data/datasource/local/auth_local_ds.dart';
import 'package:pharmacy_arrival/data/datasource/remote/accept_containers_remote_ds.dart';
import 'package:pharmacy_arrival/data/model/product_dto.dart';
import 'package:pharmacy_arrival/data/model/user.dart';
import 'package:pharmacy_arrival/data/model/warehouse_order_dto.dart';

//TODO Репо для прием контейнеров
abstract class AcceptContainersRepository {
  Future<Either<Failure, List<ProductDTO>>> getContainersByAng({
    required String number,
  });

  Future<Either<Failure, ProductDTO>> updateContainer({
    required String name,
    required int status,
  });

  Future<Either<Failure, String>> getContainerNumberFromCache();

  Future<Either<Failure, String>> saveContainerNumberToCache({
    required String containerNumber,
  });

  Future<Either<Failure, String>> deleteContainerNumberFromCache();

  Future<Either<Failure, String>> refundContainer({
    required List<String> names,
    required double latitude,
    required double longitude,
  });

  Future<AuthLocalDS> getAuthLocalDS();
}

class AcceptContainersRepositoryImpl extends AcceptContainersRepository {
  final AcceptContainersLocalDs acceptContainersLocalDs;
  final AcceptContainersRemoteDs acceptContainersRemoteDs;
  final AuthLocalDS authLocalDS;
  final NetworkInfo networkInfo;

  AcceptContainersRepositoryImpl({
    required this.acceptContainersLocalDs,
    required this.acceptContainersRemoteDs,
    required this.authLocalDS,
    required this.networkInfo,
  });

  @override
  Future<AuthLocalDS> getAuthLocalDS() async {
    return authLocalDS;
  }

  @override
  Future<Either<Failure, List<ProductDTO>>> getContainersByAng({
    required String number,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final User user = await authLocalDS.getUserFromCache();
        final List<ProductDTO> products =
        await acceptContainersRemoteDs.getContaiersByAng(
          accessToken: user.accessToken!,
          number: number,
        );
        log(products.length.toString());
        if (products.isEmpty) {
          return Left(
            ServerFailure(
              message: 'Данный контейнер пустой или такого контейнера нету',
            ),
          );
        } else {
          return Right(products);
        }
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      }
    } else {
      return Left(ServerFailure(message: 'Нет подключение к интернету!'));
    }
  }

  @override
  Future<Either<Failure, ProductDTO>> updateContainer({
    required String name,
    required int status,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final User user = await authLocalDS.getUserFromCache();
        final ProductDTO product =
            await acceptContainersRemoteDs.updateContainer(
          accessToken: user.accessToken!,
          status: status,
          name: name,
        );
        return Right(product);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      }
    } else {
      return Left(ServerFailure(message: 'Нет подключение к интернету!'));
    }
  }

  @override
  Future<Either<Failure, String>> deleteContainerNumberFromCache() async {
    try {
      await acceptContainersLocalDs.deleteContainerNumberFromCache();
      return const Right('Container Number Succesfully deleted from cache');
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, String>> getContainerNumberFromCache() async {
    try {
      return Right(await acceptContainersLocalDs.getContainerNumberFromCache());
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, String>> saveContainerNumberToCache({
    required String containerNumber,
  }) async {
    try {
      await acceptContainersLocalDs.saveContainerNumberToCache(
        containerNumber: containerNumber,
      );
      return const Right('Container Number Succesfully saved to cache');
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, String>> refundContainer({
    required List<String> names,
    required double latitude,
    required double longitude
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final User user = await authLocalDS.getUserFromCache();
        // Извлекаем цифры из warehouseName
        int? pharmacyNumber = extractNumber(user.warehouseName);
        final String result = await acceptContainersRemoteDs.refundContainer(
          accessToken: user.accessToken!,
          pharmacyNumber: pharmacyNumber != null ? pharmacyNumber.toString() : '',
          names: names,
          address: user.warehouseName!,
          from: user.warehouseName!,
          to: 'Aqniet Group',
          latitude: latitude,
          longitude: longitude,
        );
        return Right(result);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      }
    } else {
      return Left(ServerFailure(message: 'Нет подключение к интернету!'));
    }
  }

  int? extractNumber(String? input) {
    if (input == null) {
      return null;
    }

    RegExp regex = RegExp(r'\d+');
    Match? match = regex.firstMatch(input);

    return match != null ? int.tryParse(match.group(0)!) : null;
  }

  Future<Position> _getCurrentLocation() async {
    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );
    } catch (e) {
      throw ServerException(message: 'Ошибка при получении местоположения: $e');
    }
  }
}
