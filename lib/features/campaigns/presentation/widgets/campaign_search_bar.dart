import 'package:flutter/material.dart';

class CampaignSearchBar extends StatelessWidget {
  const CampaignSearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: const InputDecoration(
        hintText: 'Search campaigns, organizations...',
        prefixIcon: Icon(Icons.search),
      ),
    );
  }
}
