import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:charity_managment/features/authentication/presentation/providers/auth_provider.dart';
import 'package:charity_managment/features/donations/domain/donation_create_input.dart';
import 'package:charity_managment/features/donations/presentation/providers/donation_submission_provider.dart';
import 'package:charity_managment/models/campaign.dart';

class DonationFormSheet extends ConsumerStatefulWidget {
  const DonationFormSheet({
    super.key,
    required this.campaign,
    this.onSuccess,
  });

  final Campaign campaign;
  final VoidCallback? onSuccess;

  @override
  ConsumerState<DonationFormSheet> createState() => _DonationFormSheetState();
}

class _DonationFormSheetState extends ConsumerState<DonationFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountController;
  late final TextEditingController _messageController;
  bool _isAnonymous = false;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController();
    _messageController = TextEditingController();

    ref.listen<AsyncValue>(donationSubmissionProvider, (previous, next) {
      if (next.hasError) {
        final message = next.error.toString();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }

      if (next.hasValue && next.value != null) {
        widget.onSuccess?.call();
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Donation completed successfully.')),
        );
      }
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _messageController.dispose();
    ref.read(donationSubmissionProvider.notifier).clear();
    super.dispose();
  }

  double? _parseAmount() {
    final text = _amountController.text.trim();
    if (text.isEmpty) return null;
    return double.tryParse(text.replaceAll(',', ''));
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final amount = _parseAmount();
    if (amount == null) return;

    final user = ref.read(authControllerProvider).user;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in to donate.')),
      );
      return;
    }

    await ref.read(donationSubmissionProvider.notifier).submit(
          DonationCreateInput(
            donorId: user.id,
            campaignId: widget.campaign.id,
            amount: amount,
            isAnonymous: _isAnonymous,
            message: _messageController.text.trim().isEmpty
                ? null
                : _messageController.text.trim(),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final submission = ref.watch(donationSubmissionProvider);
    final isLoading = submission.isLoading;
    final mediaQuery = MediaQuery.of(context);

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: mediaQuery.viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Donate to ${widget.campaign.title}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Donation amount',
                prefixText: 'USD ',
                border: OutlineInputBorder(),
              ),
              validator: (_) {
                final amount = _parseAmount();
                if (amount == null) {
                  return 'Please enter a valid amount.';
                }
                if (amount <= 0) {
                  return 'Amount must be greater than 0.';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: const Text('Donate anonymously'),
              subtitle: const Text('Hide your identity from the campaign creator.'),
              value: _isAnonymous,
              onChanged: isLoading
                  ? null
                  : (value) {
                      setState(() {
                        _isAnonymous = value;
                      });
                    },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _messageController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Optional message',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: isLoading ? null : _submit,
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Confirm Donation'),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
