// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'campaign.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Campaign _$CampaignFromJson(Map<String, dynamic> json) {
  return _Campaign.fromJson(json);
}

/// @nodoc
mixin _$Campaign {
  String get id => throw _privateConstructorUsedError;
  String get charityId => throw _privateConstructorUsedError;
  String get charityName => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  String get imageUrl => throw _privateConstructorUsedError;
  double get targetAmount => throw _privateConstructorUsedError;
  double get currentAmount => throw _privateConstructorUsedError;
  int get donorCount => throw _privateConstructorUsedError;
  DateTime get startDate => throw _privateConstructorUsedError;
  DateTime get endDate => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;
  CampaignStatus get status => throw _privateConstructorUsedError;
  CampaignCategory get category => throw _privateConstructorUsedError;
  String? get location => throw _privateConstructorUsedError;

  /// Serializes this Campaign to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Campaign
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CampaignCopyWith<Campaign> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CampaignCopyWith<$Res> {
  factory $CampaignCopyWith(Campaign value, $Res Function(Campaign) then) =
      _$CampaignCopyWithImpl<$Res, Campaign>;
  @useResult
  $Res call({
    String id,
    String charityId,
    String charityName,
    String title,
    String description,
    String imageUrl,
    double targetAmount,
    double currentAmount,
    int donorCount,
    DateTime startDate,
    DateTime endDate,
    DateTime createdAt,
    DateTime updatedAt,
    CampaignStatus status,
    CampaignCategory category,
    String? location,
  });
}

/// @nodoc
class _$CampaignCopyWithImpl<$Res, $Val extends Campaign>
    implements $CampaignCopyWith<$Res> {
  _$CampaignCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Campaign
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? charityId = null,
    Object? charityName = null,
    Object? title = null,
    Object? description = null,
    Object? imageUrl = null,
    Object? targetAmount = null,
    Object? currentAmount = null,
    Object? donorCount = null,
    Object? startDate = null,
    Object? endDate = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? status = null,
    Object? category = null,
    Object? location = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            charityId: null == charityId
                ? _value.charityId
                : charityId // ignore: cast_nullable_to_non_nullable
                      as String,
            charityName: null == charityName
                ? _value.charityName
                : charityName // ignore: cast_nullable_to_non_nullable
                      as String,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            description: null == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String,
            imageUrl: null == imageUrl
                ? _value.imageUrl
                : imageUrl // ignore: cast_nullable_to_non_nullable
                      as String,
            targetAmount: null == targetAmount
                ? _value.targetAmount
                : targetAmount // ignore: cast_nullable_to_non_nullable
                      as double,
            currentAmount: null == currentAmount
                ? _value.currentAmount
                : currentAmount // ignore: cast_nullable_to_non_nullable
                      as double,
            donorCount: null == donorCount
                ? _value.donorCount
                : donorCount // ignore: cast_nullable_to_non_nullable
                      as int,
            startDate: null == startDate
                ? _value.startDate
                : startDate // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            endDate: null == endDate
                ? _value.endDate
                : endDate // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            updatedAt: null == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as CampaignStatus,
            category: null == category
                ? _value.category
                : category // ignore: cast_nullable_to_non_nullable
                      as CampaignCategory,
            location: freezed == location
                ? _value.location
                : location // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CampaignImplCopyWith<$Res>
    implements $CampaignCopyWith<$Res> {
  factory _$$CampaignImplCopyWith(
    _$CampaignImpl value,
    $Res Function(_$CampaignImpl) then,
  ) = __$$CampaignImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String charityId,
    String charityName,
    String title,
    String description,
    String imageUrl,
    double targetAmount,
    double currentAmount,
    int donorCount,
    DateTime startDate,
    DateTime endDate,
    DateTime createdAt,
    DateTime updatedAt,
    CampaignStatus status,
    CampaignCategory category,
    String? location,
  });
}

/// @nodoc
class __$$CampaignImplCopyWithImpl<$Res>
    extends _$CampaignCopyWithImpl<$Res, _$CampaignImpl>
    implements _$$CampaignImplCopyWith<$Res> {
  __$$CampaignImplCopyWithImpl(
    _$CampaignImpl _value,
    $Res Function(_$CampaignImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Campaign
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? charityId = null,
    Object? charityName = null,
    Object? title = null,
    Object? description = null,
    Object? imageUrl = null,
    Object? targetAmount = null,
    Object? currentAmount = null,
    Object? donorCount = null,
    Object? startDate = null,
    Object? endDate = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? status = null,
    Object? category = null,
    Object? location = freezed,
  }) {
    return _then(
      _$CampaignImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        charityId: null == charityId
            ? _value.charityId
            : charityId // ignore: cast_nullable_to_non_nullable
                  as String,
        charityName: null == charityName
            ? _value.charityName
            : charityName // ignore: cast_nullable_to_non_nullable
                  as String,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        description: null == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String,
        imageUrl: null == imageUrl
            ? _value.imageUrl
            : imageUrl // ignore: cast_nullable_to_non_nullable
                  as String,
        targetAmount: null == targetAmount
            ? _value.targetAmount
            : targetAmount // ignore: cast_nullable_to_non_nullable
                  as double,
        currentAmount: null == currentAmount
            ? _value.currentAmount
            : currentAmount // ignore: cast_nullable_to_non_nullable
                  as double,
        donorCount: null == donorCount
            ? _value.donorCount
            : donorCount // ignore: cast_nullable_to_non_nullable
                  as int,
        startDate: null == startDate
            ? _value.startDate
            : startDate // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        endDate: null == endDate
            ? _value.endDate
            : endDate // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        updatedAt: null == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as CampaignStatus,
        category: null == category
            ? _value.category
            : category // ignore: cast_nullable_to_non_nullable
                  as CampaignCategory,
        location: freezed == location
            ? _value.location
            : location // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CampaignImpl extends _Campaign {
  const _$CampaignImpl({
    required this.id,
    required this.charityId,
    required this.charityName,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.targetAmount,
    required this.currentAmount,
    required this.donorCount,
    required this.startDate,
    required this.endDate,
    required this.createdAt,
    required this.updatedAt,
    required this.status,
    required this.category,
    this.location,
  }) : super._();

  factory _$CampaignImpl.fromJson(Map<String, dynamic> json) =>
      _$$CampaignImplFromJson(json);

  @override
  final String id;
  @override
  final String charityId;
  @override
  final String charityName;
  @override
  final String title;
  @override
  final String description;
  @override
  final String imageUrl;
  @override
  final double targetAmount;
  @override
  final double currentAmount;
  @override
  final int donorCount;
  @override
  final DateTime startDate;
  @override
  final DateTime endDate;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final CampaignStatus status;
  @override
  final CampaignCategory category;
  @override
  final String? location;

  @override
  String toString() {
    return 'Campaign(id: $id, charityId: $charityId, charityName: $charityName, title: $title, description: $description, imageUrl: $imageUrl, targetAmount: $targetAmount, currentAmount: $currentAmount, donorCount: $donorCount, startDate: $startDate, endDate: $endDate, createdAt: $createdAt, updatedAt: $updatedAt, status: $status, category: $category, location: $location)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CampaignImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.charityId, charityId) ||
                other.charityId == charityId) &&
            (identical(other.charityName, charityName) ||
                other.charityName == charityName) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.targetAmount, targetAmount) ||
                other.targetAmount == targetAmount) &&
            (identical(other.currentAmount, currentAmount) ||
                other.currentAmount == currentAmount) &&
            (identical(other.donorCount, donorCount) ||
                other.donorCount == donorCount) &&
            (identical(other.startDate, startDate) ||
                other.startDate == startDate) &&
            (identical(other.endDate, endDate) || other.endDate == endDate) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.location, location) ||
                other.location == location));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    charityId,
    charityName,
    title,
    description,
    imageUrl,
    targetAmount,
    currentAmount,
    donorCount,
    startDate,
    endDate,
    createdAt,
    updatedAt,
    status,
    category,
    location,
  );

  /// Create a copy of Campaign
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CampaignImplCopyWith<_$CampaignImpl> get copyWith =>
      __$$CampaignImplCopyWithImpl<_$CampaignImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CampaignImplToJson(this);
  }
}

abstract class _Campaign extends Campaign {
  const factory _Campaign({
    required final String id,
    required final String charityId,
    required final String charityName,
    required final String title,
    required final String description,
    required final String imageUrl,
    required final double targetAmount,
    required final double currentAmount,
    required final int donorCount,
    required final DateTime startDate,
    required final DateTime endDate,
    required final DateTime createdAt,
    required final DateTime updatedAt,
    required final CampaignStatus status,
    required final CampaignCategory category,
    final String? location,
  }) = _$CampaignImpl;
  const _Campaign._() : super._();

  factory _Campaign.fromJson(Map<String, dynamic> json) =
      _$CampaignImpl.fromJson;

  @override
  String get id;
  @override
  String get charityId;
  @override
  String get charityName;
  @override
  String get title;
  @override
  String get description;
  @override
  String get imageUrl;
  @override
  double get targetAmount;
  @override
  double get currentAmount;
  @override
  int get donorCount;
  @override
  DateTime get startDate;
  @override
  DateTime get endDate;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;
  @override
  CampaignStatus get status;
  @override
  CampaignCategory get category;
  @override
  String? get location;

  /// Create a copy of Campaign
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CampaignImplCopyWith<_$CampaignImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
