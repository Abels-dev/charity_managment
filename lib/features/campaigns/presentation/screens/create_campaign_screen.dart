import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:developer' as developer;

import 'package:charity_managment/features/campaigns/presentation/providers/create_campaign_provider.dart';
import 'package:charity_managment/features/campaigns/presentation/widgets/campaign_form.dart';
import 'package:charity_managment/routing/app_routes.dart';
import 'package:charity_managment/shared/widgets/app_navigation_drawer.dart';
import 'package:charity_managment/shared/widgets/app_scaffold.dart';

class CreateCampaignScreen extends ConsumerStatefulWidget {
  const CreateCampaignScreen({super.key});

  @override
  ConsumerState<CreateCampaignScreen> createState() => _CreateCampaignScreenState();
}

class _CreateCampaignScreenState extends ConsumerState<CreateCampaignScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _targetAmountController = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;
  String _selectedCategory = 'education';

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _targetAmountController.dispose();
    super.dispose();
  }

  Future<void> _pickStartDate() async {
    final now = DateTime.now();
    final selected = await showDatePicker(
      context: context,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
      initialDate: _startDate ?? now,
    );

    if (selected != null) {
      setState(() => _startDate = selected);
    }
  }

  Future<void> _pickEndDate() async {
    final baseline = _startDate ?? DateTime.now();
    final selected = await showDatePicker(
      context: context,
      firstDate: baseline,
      lastDate: DateTime(baseline.year + 5),
      initialDate: _endDate ?? baseline.add(const Duration(days: 30)),
    );

    if (selected != null) {
      setState(() => _endDate = selected);
    }
  }

  Future<void> _submit() async {
    developer.log('Submit: Starting form validation', name: 'create_campaign');
    
    if (!_formKey.currentState!.validate()) {
      developer.log('Submit: Form validation failed', name: 'create_campaign');
      return;
    }
    
    if (_startDate == null || _endDate == null) {
      developer.log('Submit: Missing dates', name: 'create_campaign');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select start and end dates.')),
      );
      return;
    }
    if (_endDate!.isBefore(_startDate!)) {
      developer.log('Submit: End date before start date', name: 'create_campaign');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('End date must be after start date.')),
      );
      return;
    }

    final target = double.parse(_targetAmountController.text.trim());
    developer.log('Submit: All validations passed, calling create', name: 'create_campaign');

    try {
      final created = await ref.read(createCampaignProvider.notifier).create(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _mapCategoryToApi(_selectedCategory),
        targetAmount: target,
        startDate: _startDate!,
        endDate: _endDate!,
      );

      if (!mounted) return;

      if (created != null) {
        developer.log('Submit: Campaign created successfully', name: 'create_campaign');
        ref.read(createCampaignProvider.notifier).clear();
        context.go(AppRoutes.myCampaigns);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Campaign created and active.')),
        );
      } else {
        developer.log('Submit: Campaign creation returned null', name: 'create_campaign');
      }
    } catch (e) {
      developer.log('Submit: Error creating campaign: $e', name: 'create_campaign', error: e);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final createState = ref.watch(createCampaignProvider);

    return AppScaffold(
      title: 'Create Campaign',
      drawer: const AppNavigationDrawer(),
      body: ListView(
        children: [
          CampaignForm(
            formKey: _formKey,
            titleController: _titleController,
            descriptionController: _descriptionController,
            targetAmountController: _targetAmountController,
            selectedCategory: _selectedCategory,
            onCategoryChanged: (value) => setState(() => _selectedCategory = value),
            startDate: _startDate,
            endDate: _endDate,
            onPickStartDate: _pickStartDate,
            onPickEndDate: _pickEndDate,
            onSubmit: _submit,
            submitLabel: 'Create Campaign',
            isSubmitting: createState.isLoading,
            errorMessage: createState.error?.toString(),
          ),
        ],
      ),
    );
  }

  String _mapCategoryToApi(String value) {
    switch (value) {
      case 'health':
        return 'HEALTH';
      case 'food':
        return 'FOOD_SUPPORT';
      case 'emergency':
        return 'EMERGENCY';
      case 'environment':
        return 'ENVIRONMENT';
      case 'education':
      default:
        return 'EDUCATION';
    }
  }
}
