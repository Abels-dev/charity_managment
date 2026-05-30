import 'package:freezed_annotation/freezed_annotation.dart';

part 'campaign.freezed.dart';
part 'campaign.g.dart';

@JsonEnum(alwaysCreate: true)
enum CampaignCategory {
  @JsonValue('education')
  education,
  @JsonValue('health')
  health,
  @JsonValue('food')
  food,
  @JsonValue('emergency')
  emergency,
  @JsonValue('environment')
  environment;

  String get label => switch (this) {
        CampaignCategory.education => 'Education',
        CampaignCategory.health => 'Health',
      CampaignCategory.food => 'Food Support',
        CampaignCategory.emergency => 'Emergency',
        CampaignCategory.environment => 'Environment',
      };
}

@JsonEnum(alwaysCreate: true)
enum CampaignStatus {
  @JsonValue('ACTIVE')
  active,
  @JsonValue('CLOSED')
  closed,
  @JsonValue('DRAFT')
  draft;

  String get label => switch (this) {
        CampaignStatus.active => 'ACTIVE',
        CampaignStatus.closed => 'CLOSED',
        CampaignStatus.draft => 'DRAFT',
      };
}

@freezed
class Campaign with _$Campaign {
  const Campaign._();

  const factory Campaign({
    required String id,
    required String charityId,
    required String charityName,
    required String title,
    required String description,
    required String imageUrl,
    required double targetAmount,
    required double currentAmount,
    required int donorCount,
    required DateTime startDate,
    required DateTime endDate,
    required DateTime createdAt,
    required DateTime updatedAt,
    required CampaignStatus status,
    required CampaignCategory category,
    String? location,
  }) = _Campaign;

  factory Campaign.fromJson(Map<String, dynamic> json) =>
      _$CampaignFromJson(json);

  String get summary {
    final trimmed = description.trim();
    if (trimmed.length <= 88) return trimmed;
    return '${trimmed.substring(0, 88)}...';
  }

  String get organizationName => charityName;
  double get goalAmount => targetAmount;
  String get endDateIso => endDate.toIso8601String();
  bool get isActive => status == CampaignStatus.active;

  bool get isEditable => status != CampaignStatus.closed;

  double get progress {
    if (targetAmount <= 0) return 0;
    return (currentAmount / targetAmount).clamp(0, 1);
  }

  double get remainingAmount =>
      (targetAmount - currentAmount).clamp(0, targetAmount);
}
