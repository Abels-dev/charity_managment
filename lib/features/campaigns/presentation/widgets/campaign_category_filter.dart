import 'package:flutter/material.dart';

import 'package:charity_managment/models/campaign.dart';
import 'package:charity_managment/core/widgets/category_badge.dart';

class CampaignCategoryFilter extends StatelessWidget {
  const CampaignCategoryFilter({
    super.key,
    required this.selectedCategory,
    required this.onSelected,
  });

  final CampaignCategory? selectedCategory;
  final ValueChanged<CampaignCategory?> onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => onSelected(null),
              child: Opacity(
                opacity: selectedCategory == null ? 1.0 : 0.5,
                child: const CategoryBadge(category: 'all'),
              ),
            ),
          ),
          for (final category in CampaignCategory.values)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => onSelected(category),
                child: Opacity(
                  opacity: selectedCategory == category ? 1.0 : 0.5,
                  child: CategoryBadge(category: category.name),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
