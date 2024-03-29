// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ProductDTOImpl _$$ProductDTOImplFromJson(Map<String, dynamic> json) =>
    _$ProductDTOImpl(
      id: json['id'] as int,
      arrivalPharmacyId: json['arrival_pharmacy_id'] as int?,
      movingId: json['moving_id'] as int?,
      name: json['name'] as String?,
      image: json['image'] as String?,
      barcode: json['barcode'] as String?,
      status: json['status'] as int?,
      totalCount: json['total_count'] as int?,
      scanCount: (json['scan_count'] as num?)?.toDouble(),
      producer: json['producer'] as String?,
      series: json['series'] as String?,
      serialCode: json['serial_code'] as String?,
      defective: json['defective'] as int?,
      surplus: json['surplus'] as int?,
      underachievement: json['underachievement'] as int?,
      reSorting: json['re_sorting'] as int?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
      isReady: json['isReady'] as bool?,
      orderID: json['orderID'] as int?,
      overdue: json['overdue'] as int?,
      netovar: json['netovar'] as int?,
      refund: json['refund'] as int?,
      srok: json['wrong_time'] as int?,
    );

Map<String, dynamic> _$$ProductDTOImplToJson(_$ProductDTOImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'arrival_pharmacy_id': instance.arrivalPharmacyId,
      'moving_id': instance.movingId,
      'name': instance.name,
      'image': instance.image,
      'barcode': instance.barcode,
      'status': instance.status,
      'total_count': instance.totalCount,
      'scan_count': instance.scanCount,
      'producer': instance.producer,
      'series': instance.series,
      'serial_code': instance.serialCode,
      'defective': instance.defective,
      'surplus': instance.surplus,
      'underachievement': instance.underachievement,
      're_sorting': instance.reSorting,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
      'isReady': instance.isReady,
      'orderID': instance.orderID,
      'overdue': instance.overdue,
      'netovar': instance.netovar,
      'refund': instance.refund,
      'wrong_time': instance.srok,
    };
