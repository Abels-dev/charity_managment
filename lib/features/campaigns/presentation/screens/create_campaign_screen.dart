import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';

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
  final _imageUrlController = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _targetAmountController.dispose();
    _imageUrlController.dispose();
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

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(withData: false);
    final path = result?.files.single.path;
    if (path != null) {
      setState(() => _imageUrlController.text = path);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select start and end dates.')),
      );
      return;
    }
    if (_endDate!.isBefore(_startDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('End date must be after start date.')),
      );
      return;
    }

    final target = double.parse(_targetAmountController.text.trim());

    final created = await ref.read(createCampaignProvider.notifier).create(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          imageUrl: _imageUrlController.text.trim(),
          targetAmount: target,
          startDate: _startDate!,
          endDate: _endDate!,
        );

    if (!mounted) return;

    if (created != null) {
      ref.read(createCampaignProvider.notifier).clear();
      context.go(AppRoutes.myCampaigns);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Campaign created and active.')),
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
            imageUrlController: _imageUrlController,
            onPickImage: _pickImage,
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
}
