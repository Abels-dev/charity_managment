import 'dart:io';
import 'package:flutter/material.dart';

import 'package:charity_managment/core/theme/app_colors.dart';
import 'package:charity_managment/core/theme/app_text_styles.dart';
import 'package:charity_managment/core/theme/app_theme.dart';
import 'package:charity_managment/core/widgets/app_button.dart';
import 'package:charity_managment/core/widgets/app_card.dart';
import 'package:charity_managment/core/widgets/category_badge.dart';
import 'package:charity_managment/core/widgets/dashed_card.dart';
import 'package:charity_managment/core/widgets/form_input.dart';
import 'package:charity_managment/models/campaign.dart';

class CampaignForm extends StatefulWidget {
  const CampaignForm({
    super.key,
    required this.formKey,
    required this.titleController,
    required this.descriptionController,
    required this.targetAmountController,
    required this.imageUrlController,
    required this.onPickImage,
    required this.startDate,
    required this.endDate,
    required this.onPickStartDate,
    required this.onPickEndDate,
    required this.onSubmit,
    required this.submitLabel,
    required this.isSubmitting,
    this.readOnlyStartDate = false,
    this.isLocked = false,
    this.errorMessage,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final TextEditingController targetAmountController;
  final TextEditingController imageUrlController;
  final VoidCallback onPickImage;
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
  String _selectedCategory = 'education';

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
              label: 'Target Amount (USD)',
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
                children: CampaignCategory.values.map((cat) {
                  final catName = cat.name.toLowerCase();
                  final isSelected = _selectedCategory == catName;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: GestureDetector(
                      onTap: widget.isLocked
                          ? null
                          : () {
                              setState(() => _selectedCategory = catName);
                            },
                      child: Opacity(
                        opacity: isSelected ? 1.0 : 0.5,
                        child: CategoryBadge(category: catName),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: AppTheme.spacing16),
            Text(
              'Campaign Image',
              style: AppTextStyles.label.copyWith(color: AppColors.textPrimary),
            ),
            const SizedBox(height: AppTheme.spacing8),
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: widget.imageUrlController,
              builder: (context, value, child) {
                final hasImage = value.text.isNotEmpty;
                return DashedCard(
                  onTap: widget.isLocked ? null : widget.onPickImage,
                  padding: hasImage ? EdgeInsets.zero : null,
                  child: SizedBox(
                    width: double.infinity,
                    height: 160,
                    child: hasImage
                        ? ClipRRect(
                            borderRadius: AppTheme.borderRadiusLg,
                            child: value.text.startsWith('http')
                                ? Image.network(value.text, fit: BoxFit.cover)
                                : Image.file(File(value.text), fit: BoxFit.cover),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.cloud_upload_outlined,
                                size: 40,
                                color: AppColors.primary,
                              ),
                              const SizedBox(height: AppTheme.spacing8),
                              Text(
                                'Tap to upload image',
                                style: AppTextStyles.body,
                              ),
                            ],
                          ),
                  ),
                );
              },
            ),
            // Hidden field to keep validation for URL
            Offstage(
              child: TextFormField(
                controller: widget.imageUrlController,
                validator: _url,
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

  String? _url(String? value) {
    final text = (value ?? '').trim();
    if (text.isEmpty) return 'Image URL is required';
    if (text.startsWith('/')) return null;
    final uri = Uri.tryParse(text);
    if (uri == null || (!uri.hasScheme || !uri.hasAuthority)) {
      return 'Enter a valid URL';
    }
    return null;
  }
}
