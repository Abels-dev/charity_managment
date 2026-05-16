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
        CampaignCategory.food => 'Food',
        CampaignCategory.emergency => 'Emergency',
        CampaignCategory.environment => 'Environment',
      };
}

@freezed
class Campaign with _$Campaign {
  const Campaign._();

  const factory Campaign({
    required String id,
    required String title,
    required String summary,
    required String organizationName,
    required double goalAmount,
    required double currentAmount,
    required String endDateIso,
    required bool isActive,
    required CampaignCategory category,
    String? description,
    String? location,
    String? imageUrl,
    int? donorCount,
  }) = _Campaign;

  factory Campaign.fromJson(Map<String, dynamic> json) =>
      _$CampaignFromJson(json);

  double get progress {
    if (goalAmount <= 0) return 0;
    return (currentAmount / goalAmount).clamp(0, 1);
  }

  double get remainingAmount =>
      (goalAmount - currentAmount).clamp(0, goalAmount);
}
