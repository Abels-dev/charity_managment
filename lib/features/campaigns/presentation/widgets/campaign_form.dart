import 'package:flutter/material.dart';

import 'package:charity_managment/features/authentication/presentation/widgets/auth_primary_button.dart';
import 'package:charity_managment/features/authentication/presentation/widgets/auth_text_field.dart';

class CampaignForm extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          if (errorMessage != null) ...[
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(errorMessage!),
            ),
          ],
          AuthTextField(
            controller: titleController,
            label: 'Title',
            textInputAction: TextInputAction.next,
            validator: _required,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: descriptionController,
            minLines: 3,
            maxLines: 5,
            textInputAction: TextInputAction.newline,
            decoration: const InputDecoration(labelText: 'Description'),
            validator: _required,
          ),
          const SizedBox(height: 12),
          AuthTextField(
            controller: targetAmountController,
            label: 'Target Amount (USD)',
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.next,
            validator: _amount,
          ),
          const SizedBox(height: 12),
          AuthTextField(
            controller: imageUrlController,
            label: 'Image path or URL',
            textInputAction: TextInputAction.next,
            validator: _url,
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              onPressed: onPickImage,
              icon: const Icon(Icons.image_outlined),
              label: const Text('Choose image'),
            ),
          ),
          const SizedBox(height: 12),
          _DateButton(
            label: 'Start Date',
            value: dateText(startDate),
            onTap: (readOnlyStartDate || isLocked) ? null : onPickStartDate,
          ),
          const SizedBox(height: 10),
          _DateButton(
            label: 'End Date',
            value: dateText(endDate),
            onTap: isLocked ? null : onPickEndDate,
          ),
          const SizedBox(height: 18),
          AuthPrimaryButton(
            label: submitLabel,
            isLoading: isSubmitting,
            onPressed: isLocked ? null : onSubmit,
          ),
        ],
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

class _DateButton extends StatelessWidget {
  const _DateButton({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      child: Row(
        children: [
          Expanded(
            child: Text('$label: $value'),
          ),
          const Icon(Icons.calendar_today, size: 18),
        ],
      ),
    );
  }
}
