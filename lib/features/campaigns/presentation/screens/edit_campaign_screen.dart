import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:charity_managment/features/authentication/presentation/providers/auth_provider.dart';
import 'package:charity_managment/features/campaigns/presentation/providers/campaign_detail_provider.dart';
import 'package:charity_managment/features/campaigns/presentation/providers/edit_campaign_provider.dart';
import 'package:charity_managment/features/campaigns/presentation/widgets/campaign_form.dart';
import 'package:charity_managment/features/campaigns/presentation/widgets/campaign_status_badge.dart';
import 'package:charity_managment/models/campaign.dart';
import 'package:charity_managment/routing/app_routes.dart';
import 'package:charity_managment/shared/widgets/app_navigation_drawer.dart';
import 'package:charity_managment/shared/widgets/app_scaffold.dart';
import 'package:charity_managment/shared/widgets/empty_state.dart';

class EditCampaignScreen extends ConsumerStatefulWidget {
  const EditCampaignScreen({
    super.key,
    required this.campaignId,
  });

  final String campaignId;

  @override
  ConsumerState<EditCampaignScreen> createState() => _EditCampaignScreenState();
}

class _EditCampaignScreenState extends ConsumerState<EditCampaignScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _targetAmountController = TextEditingController();
  final _imageUrlController = TextEditingController();

  DateTime? _endDate;
  DateTime? _startDate;
  bool _initialized = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _targetAmountController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  void _prefill(Campaign campaign) {
    if (_initialized) return;
    _initialized = true;

    _titleController.text = campaign.title;
    _descriptionController.text = campaign.description;
    _targetAmountController.text = campaign.targetAmount.toStringAsFixed(0);
    _imageUrlController.text = campaign.imageUrl;
    _startDate = campaign.startDate;
    _endDate = campaign.endDate;
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
    if (!_formKey.currentState!.validate()) return;
    if (_endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an end date.')),
      );
      return;
    }
    if (_startDate != null && _endDate!.isBefore(_startDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('End date must be after start date.')),
      );
      return;
    }

    final updated = await ref.read(editCampaignProvider.notifier).update(
          campaignId: widget.campaignId,
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          imageUrl: _imageUrlController.text.trim(),
          targetAmount: double.parse(_targetAmountController.text.trim()),
          endDate: _endDate!,
        );

    if (!mounted) return;

    if (updated != null) {
      ref.read(editCampaignProvider.notifier).clear();
      context.go(AppRoutes.myCampaigns);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Campaign updated successfully.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final campaignAsync = ref.watch(campaignDetailProvider(widget.campaignId));
    final user = ref.watch(authControllerProvider).user;
    final editState = ref.watch(editCampaignProvider);

    return AppScaffold(
      title: 'Edit Campaign',
      drawer: const AppNavigationDrawer(),
      body: campaignAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => EmptyState(
          title: 'Unable to load campaign',
          subtitle: error.toString(),
        ),
        data: (campaign) {
          if (campaign == null) {
            return const EmptyState(
              title: 'Campaign not found',
              subtitle: 'This campaign may have been removed.',
            );
          }

          if (user == null || user.id != campaign.charityId) {
            return const EmptyState(
              title: 'Access denied',
              subtitle: 'You can only edit campaigns owned by your charity.',
            );
          }

          _prefill(campaign);

          final locked = campaign.status == CampaignStatus.closed;

          return ListView(
            children: [
              Row(
                children: [
                  const Text('Status: '),
                  CampaignStatusBadge(status: campaign.status),
                ],
              ),
              if (locked) ...[
                const SizedBox(height: 12),
                const Text(
                  'Closed campaigns cannot be edited.',
                ),
              ],
              const SizedBox(height: 12),
              CampaignForm(
                formKey: _formKey,
                titleController: _titleController,
                descriptionController: _descriptionController,
                targetAmountController: _targetAmountController,
                imageUrlController: _imageUrlController,
                startDate: _startDate,
                endDate: _endDate,
                onPickStartDate: () {},
                onPickEndDate: _pickEndDate,
                onSubmit: _submit,
                submitLabel: 'Save Changes',
                isSubmitting: editState.isLoading,
                errorMessage: editState.error?.toString(),
                readOnlyStartDate: true,
                isLocked: locked,
              ),
            ],
          );
        },
      ),
    );
  }
}
