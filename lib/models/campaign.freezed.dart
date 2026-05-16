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
  String get title => throw _privateConstructorUsedError;
  String get summary => throw _privateConstructorUsedError;
  String get organizationName => throw _privateConstructorUsedError;
  double get goalAmount => throw _privateConstructorUsedError;
  double get currentAmount => throw _privateConstructorUsedError;
  String get endDateIso => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;
  @JsonKey(unknownEnumValue: CampaignCategory.emergency)
  CampaignCategory get category => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  String? get location => throw _privateConstructorUsedError;
  String? get imageUrl => throw _privateConstructorUsedError;
  int? get donorCount => throw _privateConstructorUsedError;

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
    String title,
    String summary,
    String organizationName,
    double goalAmount,
    double currentAmount,
    String endDateIso,
    bool isActive,
    @JsonKey(unknownEnumValue: CampaignCategory.emergency)
    CampaignCategory category,
    String? description,
    String? location,
    String? imageUrl,
    int? donorCount,
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
    Object? title = null,
    Object? summary = null,
    Object? organizationName = null,
    Object? goalAmount = null,
    Object? currentAmount = null,
    Object? endDateIso = null,
    Object? isActive = null,
    Object? category = null,
    Object? description = freezed,
    Object? location = freezed,
    Object? imageUrl = freezed,
    Object? donorCount = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            summary: null == summary
                ? _value.summary
                : summary // ignore: cast_nullable_to_non_nullable
                      as String,
            organizationName: null == organizationName
                ? _value.organizationName
                : organizationName // ignore: cast_nullable_to_non_nullable
                      as String,
            goalAmount: null == goalAmount
                ? _value.goalAmount
                : goalAmount // ignore: cast_nullable_to_non_nullable
                      as double,
            currentAmount: null == currentAmount
                ? _value.currentAmount
                : currentAmount // ignore: cast_nullable_to_non_nullable
                      as double,
            endDateIso: null == endDateIso
                ? _value.endDateIso
                : endDateIso // ignore: cast_nullable_to_non_nullable
                      as String,
            isActive: null == isActive
                ? _value.isActive
                : isActive // ignore: cast_nullable_to_non_nullable
                      as bool,
            category: null == category
                ? _value.category
                : category // ignore: cast_nullable_to_non_nullable
                      as CampaignCategory,
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
            location: freezed == location
                ? _value.location
                : location // ignore: cast_nullable_to_non_nullable
                      as String?,
            imageUrl: freezed == imageUrl
                ? _value.imageUrl
                : imageUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            donorCount: freezed == donorCount
                ? _value.donorCount
                : donorCount // ignore: cast_nullable_to_non_nullable
                      as int?,
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
    String title,
    String summary,
    String organizationName,
    double goalAmount,
    double currentAmount,
    String endDateIso,
    bool isActive,
    @JsonKey(unknownEnumValue: CampaignCategory.emergency)
    CampaignCategory category,
    String? description,
    String? location,
    String? imageUrl,
    int? donorCount,
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
    Object? title = null,
    Object? summary = null,
    Object? organizationName = null,
    Object? goalAmount = null,
    Object? currentAmount = null,
    Object? endDateIso = null,
    Object? isActive = null,
    Object? category = null,
    Object? description = freezed,
    Object? location = freezed,
    Object? imageUrl = freezed,
    Object? donorCount = freezed,
  }) {
    return _then(
      _$CampaignImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        summary: null == summary
            ? _value.summary
            : summary // ignore: cast_nullable_to_non_nullable
                  as String,
        organizationName: null == organizationName
            ? _value.organizationName
            : organizationName // ignore: cast_nullable_to_non_nullable
                  as String,
        goalAmount: null == goalAmount
            ? _value.goalAmount
            : goalAmount // ignore: cast_nullable_to_non_nullable
                  as double,
        currentAmount: null == currentAmount
            ? _value.currentAmount
            : currentAmount // ignore: cast_nullable_to_non_nullable
                  as double,
        endDateIso: null == endDateIso
            ? _value.endDateIso
            : endDateIso // ignore: cast_nullable_to_non_nullable
                  as String,
        isActive: null == isActive
            ? _value.isActive
            : isActive // ignore: cast_nullable_to_non_nullable
                  as bool,
        category: null == category
            ? _value.category
            : category // ignore: cast_nullable_to_non_nullable
                  as CampaignCategory,
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
        location: freezed == location
            ? _value.location
            : location // ignore: cast_nullable_to_non_nullable
                  as String?,
        imageUrl: freezed == imageUrl
            ? _value.imageUrl
            : imageUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        donorCount: freezed == donorCount
            ? _value.donorCount
            : donorCount // ignore: cast_nullable_to_non_nullable
                  as int?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CampaignImpl extends _Campaign {
  const _$CampaignImpl({
    required this.id,
    required this.title,
    required this.summary,
    required this.organizationName,
    required this.goalAmount,
    required this.currentAmount,
    required this.endDateIso,
    required this.isActive,
    @JsonKey(unknownEnumValue: CampaignCategory.emergency)
    required this.category,
    this.description,
    this.location,
    this.imageUrl,
    this.donorCount,
  }) : super._();

  factory _$CampaignImpl.fromJson(Map<String, dynamic> json) =>
      _$$CampaignImplFromJson(json);

  @override
  final String id;
  @override
  final String title;
  @override
  final String summary;
  @override
  final String organizationName;
  @override
  final double goalAmount;
  @override
  final double currentAmount;
  @override
  final String endDateIso;
  @override
  final bool isActive;
  @override
  @JsonKey(unknownEnumValue: CampaignCategory.emergency)
  final CampaignCategory category;
  @override
  final String? description;
  @override
  final String? location;
  @override
  final String? imageUrl;
  @override
  final int? donorCount;

  @override
  String toString() {
    return 'Campaign(id: $id, title: $title, summary: $summary, organizationName: $organizationName, goalAmount: $goalAmount, currentAmount: $currentAmount, endDateIso: $endDateIso, isActive: $isActive, category: $category, description: $description, location: $location, imageUrl: $imageUrl, donorCount: $donorCount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CampaignImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.summary, summary) || other.summary == summary) &&
            (identical(other.organizationName, organizationName) ||
                other.organizationName == organizationName) &&
            (identical(other.goalAmount, goalAmount) ||
                other.goalAmount == goalAmount) &&
            (identical(other.currentAmount, currentAmount) ||
                other.currentAmount == currentAmount) &&
            (identical(other.endDateIso, endDateIso) ||
                other.endDateIso == endDateIso) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.location, location) ||
                other.location == location) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.donorCount, donorCount) ||
                other.donorCount == donorCount));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    title,
    summary,
    organizationName,
    goalAmount,
    currentAmount,
    endDateIso,
    isActive,
    category,
    description,
    location,
    imageUrl,
    donorCount,
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
    required final String title,
    required final String summary,
    required final String organizationName,
    required final double goalAmount,
    required final double currentAmount,
    required final String endDateIso,
    required final bool isActive,
    @JsonKey(unknownEnumValue: CampaignCategory.emergency)
    required final CampaignCategory category,
    final String? description,
    final String? location,
    final String? imageUrl,
    final int? donorCount,
  }) = _$CampaignImpl;
  const _Campaign._() : super._();

  factory _Campaign.fromJson(Map<String, dynamic> json) =
      _$CampaignImpl.fromJson;

  @override
  String get id;
  @override
  String get title;
  @override
  String get summary;
  @override
  String get organizationName;
  @override
  double get goalAmount;
  @override
  double get currentAmount;
  @override
  String get endDateIso;
  @override
  bool get isActive;
  @override
  @JsonKey(unknownEnumValue: CampaignCategory.emergency)
  CampaignCategory get category;
  @override
  String? get description;
  @override
  String? get location;
  @override
  String? get imageUrl;
  @override
  int? get donorCount;

  /// Create a copy of Campaign
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CampaignImplCopyWith<_$CampaignImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
