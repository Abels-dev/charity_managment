// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'campaign.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CampaignImpl _$$CampaignImplFromJson(Map<String, dynamic> json) =>
    _$CampaignImpl(
      id: json['id'] as String,
      charityId: json['charityId'] as String,
      charityName: json['charityName'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      imageUrl: json['imageUrl'] as String,
      targetAmount: (json['targetAmount'] as num).toDouble(),
      currentAmount: (json['currentAmount'] as num).toDouble(),
      donorCount: (json['donorCount'] as num).toInt(),
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      status: $enumDecode(_$CampaignStatusEnumMap, json['status']),
      category: $enumDecode(_$CampaignCategoryEnumMap, json['category']),
      location: json['location'] as String?,
    );

Map<String, dynamic> _$$CampaignImplToJson(_$CampaignImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'charityId': instance.charityId,
      'charityName': instance.charityName,
      'title': instance.title,
      'description': instance.description,
      'imageUrl': instance.imageUrl,
      'targetAmount': instance.targetAmount,
      'currentAmount': instance.currentAmount,
      'donorCount': instance.donorCount,
      'startDate': instance.startDate.toIso8601String(),
      'endDate': instance.endDate.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'status': _$CampaignStatusEnumMap[instance.status]!,
      'category': _$CampaignCategoryEnumMap[instance.category]!,
      'location': instance.location,
    };

const _$CampaignStatusEnumMap = {
  CampaignStatus.active: 'ACTIVE',
  CampaignStatus.closed: 'CLOSED',
  CampaignStatus.draft: 'DRAFT',
};

const _$CampaignCategoryEnumMap = {
  CampaignCategory.education: 'education',
  CampaignCategory.health: 'health',
  CampaignCategory.food: 'food',
  CampaignCategory.emergency: 'emergency',
  CampaignCategory.environment: 'environment',
};
