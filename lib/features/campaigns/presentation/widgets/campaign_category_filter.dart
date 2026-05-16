import 'package:flutter/material.dart';

import 'package:charity_managment/models/campaign.dart';

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
            child: ChoiceChip(
              label: const Text('All'),
              selected: selectedCategory == null,
              onSelected: (_) => onSelected(null),
            ),
          ),
          for (final category in CampaignCategory.values)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(category.label),
                selected: selectedCategory == category,
                onSelected: (_) => onSelected(category),
              ),
            ),
        ],
      ),
    );
  }
}
