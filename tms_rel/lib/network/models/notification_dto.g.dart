// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$NotificationDTOImpl _$$NotificationDTOImplFromJson(
        Map<String, dynamic> json) =>
    _$NotificationDTOImpl(
      id: json['id'] as int,
      order: json['order'] == null
          ? null
          : OrderDTO.fromJson(json['order'] as Map<String, dynamic>),
      reason: json['reason'] as String?,
    );

Map<String, dynamic> _$$NotificationDTOImplToJson(
        _$NotificationDTOImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'order': instance.order,
      'reason': instance.reason,
    };
