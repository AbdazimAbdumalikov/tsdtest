// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'city_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

CityDTO _$CityDTOFromJson(Map<String, dynamic> json) {
  return _CityDTO.fromJson(json);
}

/// @nodoc
mixin _$CityDTO {
  int get id => throw _privateConstructorUsedError;
  String? get name => throw _privateConstructorUsedError;
  @JsonKey(name: 'region_id')
  int? get regionId => throw _privateConstructorUsedError;
  dynamic get lat => throw _privateConstructorUsedError; // FIXME
  dynamic get long => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $CityDTOCopyWith<CityDTO> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CityDTOCopyWith<$Res> {
  factory $CityDTOCopyWith(CityDTO value, $Res Function(CityDTO) then) =
      _$CityDTOCopyWithImpl<$Res, CityDTO>;
  @useResult
  $Res call(
      {int id,
      String? name,
      @JsonKey(name: 'region_id') int? regionId,
      dynamic lat,
      dynamic long});
}

/// @nodoc
class _$CityDTOCopyWithImpl<$Res, $Val extends CityDTO>
    implements $CityDTOCopyWith<$Res> {
  _$CityDTOCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = freezed,
    Object? regionId = freezed,
    Object? lat = freezed,
    Object? long = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
      regionId: freezed == regionId
          ? _value.regionId
          : regionId // ignore: cast_nullable_to_non_nullable
              as int?,
      lat: freezed == lat
          ? _value.lat
          : lat // ignore: cast_nullable_to_non_nullable
              as dynamic,
      long: freezed == long
          ? _value.long
          : long // ignore: cast_nullable_to_non_nullable
              as dynamic,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CityDTOImplCopyWith<$Res> implements $CityDTOCopyWith<$Res> {
  factory _$$CityDTOImplCopyWith(
          _$CityDTOImpl value, $Res Function(_$CityDTOImpl) then) =
      __$$CityDTOImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      String? name,
      @JsonKey(name: 'region_id') int? regionId,
      dynamic lat,
      dynamic long});
}

/// @nodoc
class __$$CityDTOImplCopyWithImpl<$Res>
    extends _$CityDTOCopyWithImpl<$Res, _$CityDTOImpl>
    implements _$$CityDTOImplCopyWith<$Res> {
  __$$CityDTOImplCopyWithImpl(
      _$CityDTOImpl _value, $Res Function(_$CityDTOImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = freezed,
    Object? regionId = freezed,
    Object? lat = freezed,
    Object? long = freezed,
  }) {
    return _then(_$CityDTOImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
      regionId: freezed == regionId
          ? _value.regionId
          : regionId // ignore: cast_nullable_to_non_nullable
              as int?,
      lat: freezed == lat
          ? _value.lat
          : lat // ignore: cast_nullable_to_non_nullable
              as dynamic,
      long: freezed == long
          ? _value.long
          : long // ignore: cast_nullable_to_non_nullable
              as dynamic,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CityDTOImpl implements _CityDTO {
  const _$CityDTOImpl(
      {required this.id,
      this.name,
      @JsonKey(name: 'region_id') this.regionId,
      this.lat,
      this.long});

  factory _$CityDTOImpl.fromJson(Map<String, dynamic> json) =>
      _$$CityDTOImplFromJson(json);

  @override
  final int id;
  @override
  final String? name;
  @override
  @JsonKey(name: 'region_id')
  final int? regionId;
  @override
  final dynamic lat;
// FIXME
  @override
  final dynamic long;

  @override
  String toString() {
    return 'CityDTO(id: $id, name: $name, regionId: $regionId, lat: $lat, long: $long)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CityDTOImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.regionId, regionId) ||
                other.regionId == regionId) &&
            const DeepCollectionEquality().equals(other.lat, lat) &&
            const DeepCollectionEquality().equals(other.long, long));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      name,
      regionId,
      const DeepCollectionEquality().hash(lat),
      const DeepCollectionEquality().hash(long));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CityDTOImplCopyWith<_$CityDTOImpl> get copyWith =>
      __$$CityDTOImplCopyWithImpl<_$CityDTOImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CityDTOImplToJson(
      this,
    );
  }
}

abstract class _CityDTO implements CityDTO {
  const factory _CityDTO(
      {required final int id,
      final String? name,
      @JsonKey(name: 'region_id') final int? regionId,
      final dynamic lat,
      final dynamic long}) = _$CityDTOImpl;

  factory _CityDTO.fromJson(Map<String, dynamic> json) = _$CityDTOImpl.fromJson;

  @override
  int get id;
  @override
  String? get name;
  @override
  @JsonKey(name: 'region_id')
  int? get regionId;
  @override
  dynamic get lat;
  @override // FIXME
  dynamic get long;
  @override
  @JsonKey(ignore: true)
  _$$CityDTOImplCopyWith<_$CityDTOImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
