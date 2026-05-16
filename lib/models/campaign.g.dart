// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'campaign.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CampaignImpl _$$CampaignImplFromJson(Map<String, dynamic> json) =>
    _$CampaignImpl(
      id: json['id'] as String,
      title: json['title'] as String,
      summary: json['summary'] as String,
      organizationName: json['organizationName'] as String,
      goalAmount: (json['goalAmount'] as num).toDouble(),
      currentAmount: (json['currentAmount'] as num).toDouble(),
      endDateIso: json['endDateIso'] as String,
      isActive: json['isActive'] as bool,
      category: $enumDecode(
        _$CampaignCategoryEnumMap,
        json['category'],
        unknownValue: CampaignCategory.emergency,
      ),
      description: json['description'] as String?,
      location: json['location'] as String?,
      imageUrl: json['imageUrl'] as String?,
      donorCount: (json['donorCount'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$CampaignImplToJson(_$CampaignImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'summary': instance.summary,
      'organizationName': instance.organizationName,
      'goalAmount': instance.goalAmount,
      'currentAmount': instance.currentAmount,
      'endDateIso': instance.endDateIso,
      'isActive': instance.isActive,
      'category': _$CampaignCategoryEnumMap[instance.category]!,
      'description': instance.description,
      'location': instance.location,
      'imageUrl': instance.imageUrl,
      'donorCount': instance.donorCount,
    };

const _$CampaignCategoryEnumMap = {
  CampaignCategory.education: 'education',
  CampaignCategory.health: 'health',
  CampaignCategory.food: 'food',
  CampaignCategory.emergency: 'emergency',
  CampaignCategory.environment: 'environment',
};
