// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'notification_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

NotificationDTO _$NotificationDTOFromJson(Map<String, dynamic> json) {
  return _NotificationDTO.fromJson(json);
}

/// @nodoc
mixin _$NotificationDTO {
  int get id => throw _privateConstructorUsedError;
  OrderDTO? get order => throw _privateConstructorUsedError;
  String? get reason => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $NotificationDTOCopyWith<NotificationDTO> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NotificationDTOCopyWith<$Res> {
  factory $NotificationDTOCopyWith(
          NotificationDTO value, $Res Function(NotificationDTO) then) =
      _$NotificationDTOCopyWithImpl<$Res, NotificationDTO>;
  @useResult
  $Res call({int id, OrderDTO? order, String? reason});

  $OrderDTOCopyWith<$Res>? get order;
}

/// @nodoc
class _$NotificationDTOCopyWithImpl<$Res, $Val extends NotificationDTO>
    implements $NotificationDTOCopyWith<$Res> {
  _$NotificationDTOCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? order = freezed,
    Object? reason = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      order: freezed == order
          ? _value.order
          : order // ignore: cast_nullable_to_non_nullable
              as OrderDTO?,
      reason: freezed == reason
          ? _value.reason
          : reason // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $OrderDTOCopyWith<$Res>? get order {
    if (_value.order == null) {
      return null;
    }

    return $OrderDTOCopyWith<$Res>(_value.order!, (value) {
      return _then(_value.copyWith(order: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$NotificationDTOImplCopyWith<$Res>
    implements $NotificationDTOCopyWith<$Res> {
  factory _$$NotificationDTOImplCopyWith(_$NotificationDTOImpl value,
          $Res Function(_$NotificationDTOImpl) then) =
      __$$NotificationDTOImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int id, OrderDTO? order, String? reason});

  @override
  $OrderDTOCopyWith<$Res>? get order;
}

/// @nodoc
class __$$NotificationDTOImplCopyWithImpl<$Res>
    extends _$NotificationDTOCopyWithImpl<$Res, _$NotificationDTOImpl>
    implements _$$NotificationDTOImplCopyWith<$Res> {
  __$$NotificationDTOImplCopyWithImpl(
      _$NotificationDTOImpl _value, $Res Function(_$NotificationDTOImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? order = freezed,
    Object? reason = freezed,
  }) {
    return _then(_$NotificationDTOImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      order: freezed == order
          ? _value.order
          : order // ignore: cast_nullable_to_non_nullable
              as OrderDTO?,
      reason: freezed == reason
          ? _value.reason
          : reason // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$NotificationDTOImpl implements _NotificationDTO {
  const _$NotificationDTOImpl({required this.id, this.order, this.reason});

  factory _$NotificationDTOImpl.fromJson(Map<String, dynamic> json) =>
      _$$NotificationDTOImplFromJson(json);

  @override
  final int id;
  @override
  final OrderDTO? order;
  @override
  final String? reason;

  @override
  String toString() {
    return 'NotificationDTO(id: $id, order: $order, reason: $reason)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NotificationDTOImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.order, order) || other.order == order) &&
            (identical(other.reason, reason) || other.reason == reason));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, order, reason);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$NotificationDTOImplCopyWith<_$NotificationDTOImpl> get copyWith =>
      __$$NotificationDTOImplCopyWithImpl<_$NotificationDTOImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$NotificationDTOImplToJson(
      this,
    );
  }
}

abstract class _NotificationDTO implements NotificationDTO {
  const factory _NotificationDTO(
      {required final int id,
      final OrderDTO? order,
      final String? reason}) = _$NotificationDTOImpl;

  factory _NotificationDTO.fromJson(Map<String, dynamic> json) =
      _$NotificationDTOImpl.fromJson;

  @override
  int get id;
  @override
  OrderDTO? get order;
  @override
  String? get reason;
  @override
  @JsonKey(ignore: true)
  _$$NotificationDTOImplCopyWith<_$NotificationDTOImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
