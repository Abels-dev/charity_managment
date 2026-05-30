import 'package:flutter/material.dart';

import 'package:charity_managment/core/theme/app_colors.dart';
import 'package:charity_managment/core/theme/app_text_styles.dart';
import 'package:charity_managment/core/theme/app_theme.dart';
import 'package:charity_managment/core/widgets/app_button.dart';
import 'package:charity_managment/core/widgets/app_card.dart';
import 'package:charity_managment/core/widgets/category_badge.dart';
import 'package:charity_managment/core/widgets/form_input.dart';

class CampaignForm extends StatefulWidget {
  const CampaignForm({
    super.key,
    required this.formKey,
    required this.titleController,
    required this.descriptionController,
    required this.targetAmountController,
    required this.selectedCategory,
    required this.startDate,
    required this.endDate,
    required this.onPickStartDate,
    required this.onPickEndDate,
    required this.onSubmit,
    required this.submitLabel,
    required this.isSubmitting,
    this.onCategoryChanged,
    this.readOnlyStartDate = false,
    this.isLocked = false,
    this.errorMessage,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final TextEditingController targetAmountController;
  final String selectedCategory;
  final ValueChanged<String>? onCategoryChanged;
  final DateTime? startDate;
  final DateTime? endDate;
  final VoidCallback onPickStartDate;
  final VoidCallback onPickEndDate;
  final VoidCallback onSubmit;
  final String submitLabel;
  final bool isSubmitting;
  final bool readOnlyStartDate;
  final bool isLocked;
  final String? errorMessage;

  static String dateText(DateTime? date) {
    if (date == null) return 'Select date';
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  @override
  State<CampaignForm> createState() => _CampaignFormState();
}

class _CampaignFormState extends State<CampaignForm> {
  static const _categoryOptions = [
    ('education', 'Education'),
    ('health', 'Health'),
    ('food', 'Food Support'),
    ('emergency', 'Emergency'),
    ('environment', 'Environment'),
  ];

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppTheme.spacing16),
      child: Form(
        key: widget.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.errorMessage != null) ...[
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(widget.errorMessage!),
              ),
            ],
            FormInput(
              controller: widget.titleController,
              label: 'Title',
              textInputAction: TextInputAction.next,
              validator: _required,
            ),
            const SizedBox(height: AppTheme.spacing16),
            FormInput(
              controller: widget.descriptionController,
              label: 'Description',
              minLines: 3,
              maxLines: 5,
              textInputAction: TextInputAction.newline,
              validator: _required,
            ),
            const SizedBox(height: AppTheme.spacing16),
            FormInput(
              controller: widget.targetAmountController,
              label: 'Target Amount (ETB)',
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.next,
              validator: _amount,
            ),
            const SizedBox(height: AppTheme.spacing16),
            Text(
              'Category',
              style: AppTextStyles.label.copyWith(color: AppColors.textPrimary),
            ),
            const SizedBox(height: AppTheme.spacing8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _categoryOptions.map((option) {
                  final catName = option.$1;
                  final catLabel = option.$2;
                  final isSelected = widget.selectedCategory == catName;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: GestureDetector(
                      onTap: widget.isLocked
                          ? null
                          : () => widget.onCategoryChanged?.call(catName),
                      child: Opacity(
                        opacity: isSelected ? 1.0 : 0.5,
                        child: CategoryBadge(category: catLabel),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: AppTheme.spacing16),
            FormInput(
              label: 'Start Date',
              controller: TextEditingController(text: CampaignForm.dateText(widget.startDate)),
              readOnly: true,
              onTap: (widget.readOnlyStartDate || widget.isLocked) ? null : widget.onPickStartDate,
              suffixIcon: const Icon(Icons.calendar_today, size: 18),
            ),
            const SizedBox(height: AppTheme.spacing16),
            FormInput(
              label: 'End Date',
              controller: TextEditingController(text: CampaignForm.dateText(widget.endDate)),
              readOnly: true,
              onTap: widget.isLocked ? null : widget.onPickEndDate,
              suffixIcon: const Icon(Icons.calendar_today, size: 18),
            ),
            const SizedBox(height: AppTheme.spacing24),
            AppButton(
              text: widget.submitLabel,
              isLoading: widget.isSubmitting,
              onPressed: widget.isLocked ? null : widget.onSubmit,
            ),
          ],
        ),
      ),
    );
  }

  String? _required(String? value) {
    if ((value ?? '').trim().isEmpty) return 'This field is required';
    return null;
  }

  String? _amount(String? value) {
    final text = (value ?? '').trim();
    if (text.isEmpty) return 'Target amount is required';
    final amount = double.tryParse(text);
    if (amount == null || amount <= 0) {
      return 'Enter a valid amount';
    }
    return null;
  }
}