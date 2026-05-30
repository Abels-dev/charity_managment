import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:charity_managment/core/theme/app_colors.dart';
import 'package:charity_managment/core/theme/app_text_styles.dart';
import 'package:charity_managment/core/theme/app_theme.dart';
import 'package:charity_managment/core/widgets/app_card.dart';
import 'package:charity_managment/core/widgets/form_input.dart';
import 'package:charity_managment/features/bank_accounts/data/api_bank_account_repository.dart';
import 'package:charity_managment/features/bank_accounts/presentation/providers/bank_account_repository_provider.dart';
import 'package:charity_managment/shared/widgets/app_navigation_drawer.dart';
import 'package:charity_managment/shared/widgets/app_scaffold.dart';
import 'package:charity_managment/shared/widgets/empty_state.dart';

class BankAccountsScreen extends ConsumerWidget {
  const BankAccountsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountsAsync = ref.watch(bankAccountsProvider);
    final mutationState = ref.watch(bankAccountMutationProvider);

    return AppScaffold(
      title: 'Bank Accounts',
      drawer: const AppNavigationDrawer(),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(bankAccountsProvider);
          await ref.read(bankAccountsProvider.future);
        },
        child: accountsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            children: [
              EmptyState(
                title: 'Unable to load bank accounts',
                subtitle: error.toString(),
              ),
            ],
          ),
          data: (accounts) {
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: [
                _HeaderCard(
                  accountCount: accounts.length,
                  onAddPressed: mutationState.isLoading
                      ? null
                      : () => showBankAccountFormSheet(context, ref),
                ),
                const SizedBox(height: AppTheme.spacing16),
                if (accounts.isEmpty)
                  const EmptyState(
                    title: 'No bank accounts yet',
                    subtitle: 'Add a bank account to receive campaign funds.',
                  )
                else
                  ...[
                    for (final account in accounts) ...[
                      _BankAccountCard(account: account),
                      const SizedBox(height: AppTheme.spacing12),
                    ],
                  ],
              ],
            );
          },
        ),
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({
    required this.accountCount,
    required this.onAddPressed,
  });

  final int accountCount;
  final VoidCallback? onAddPressed;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppTheme.spacing16),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: AppTheme.borderRadiusMd,
            ),
            child: const Icon(Icons.account_balance_wallet_outlined, color: AppColors.primary),
          ),
          const SizedBox(width: AppTheme.spacing12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Bank accounts', style: AppTextStyles.title),
                const SizedBox(height: 4),
                Text(
                  accountCount == 0
                      ? 'No bank accounts have been added yet.'
                      : '$accountCount account${accountCount == 1 ? '' : 's'} available',
                  style: AppTextStyles.body.copyWith(color: AppColors.textBody),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppTheme.spacing12),
          FilledButton.icon(
            onPressed: onAddPressed,
            icon: const Icon(Icons.add),
            label: const Text('Add'),
          ),
        ],
      ),
    );
  }
}

Future<void> showBankAccountFormSheet(
  BuildContext context,
  WidgetRef ref, {
  BankAccount? initial,
}) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      return _BankAccountFormSheet(
        initial: initial,
        onCancel: () => Navigator.of(sheetContext).pop(),
        onSubmit: (payload) async {
          final notifier = ref.read(bankAccountMutationProvider.notifier);

          if (initial == null) {
            await notifier.create(
              bankName: payload.bankName,
              accountHolder: payload.accountHolder,
              accountNumber: payload.accountNumber,
              type: 'PERSONAL',
              isPrimary: payload.isPrimary,
            );
          } else {
            await notifier.update(
              accountId: initial.id,
              bankName: payload.bankName,
              accountHolder: payload.accountHolder,
              accountNumber: payload.accountNumber,
              type: 'PERSONAL',
              isPrimary: payload.isPrimary,
            );
          }

          if (!context.mounted) return;
          final state = ref.read(bankAccountMutationProvider);
          Navigator.of(sheetContext).pop();

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.hasError
                    ? state.error.toString()
                    : (initial == null ? 'Bank account added.' : 'Bank account updated.'),
              ),
            ),
          );
        },
      );
    },
  );
}

class _BankAccountFormSheet extends StatefulWidget {
  const _BankAccountFormSheet({
    required this.initial,
    required this.onCancel,
    required this.onSubmit,
  });

  final BankAccount? initial;
  final VoidCallback onCancel;
  final Future<void> Function(_BankAccountFormData payload) onSubmit;

  @override
  State<_BankAccountFormSheet> createState() => _BankAccountFormSheetState();
}

class _BankAccountFormSheetState extends State<_BankAccountFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _bankNameController;
  late final TextEditingController _holderController;
  late final TextEditingController _numberController;
  bool _isPrimary = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _bankNameController = TextEditingController(text: widget.initial?.bankName ?? '');
    _holderController = TextEditingController(text: widget.initial?.accountHolder ?? '');
    _numberController = TextEditingController(text: widget.initial?.accountNumber ?? '');
    _isPrimary = widget.initial?.isPrimary ?? false;
  }

  @override
  void dispose() {
    _bankNameController.dispose();
    _holderController.dispose();
    _numberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              AppCard(
                padding: const EdgeInsets.all(AppTheme.spacing16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: AppTheme.borderRadiusMd,
                          ),
                          child: const Icon(Icons.account_balance_outlined, color: AppColors.primary),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.initial == null ? 'Add bank account' : 'Edit bank account',
                                style: AppTextStyles.title,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Keep the details accurate for fund transfers.',
                                style: AppTextStyles.body.copyWith(color: AppColors.textBody),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          FormInput(
                            label: 'Bank name',
                            controller: _bankNameController,
                            hint: 'e.g. Commercial Bank of Ethiopia',
                            prefixIcon: const Icon(Icons.account_balance_outlined),
                            validator: (value) =>
                                (value == null || value.trim().isEmpty) ? 'Bank name is required' : null,
                          ),
                          const SizedBox(height: 16),
                          FormInput(
                            label: 'Account holder',
                            controller: _holderController,
                            hint: 'Name on the bank account',
                            prefixIcon: const Icon(Icons.person_outline),
                            validator: (value) => (value == null || value.trim().isEmpty)
                                ? 'Account holder is required'
                                : null,
                          ),
                          const SizedBox(height: 16),
                          FormInput(
                            label: 'Account number',
                            controller: _numberController,
                            hint: 'Enter account number',
                            keyboardType: TextInputType.number,
                            prefixIcon: const Icon(Icons.numbers_outlined),
                            validator: (value) => (value == null || value.trim().isEmpty)
                                ? 'Account number is required'
                                : null,
                          ),
                          const SizedBox(height: 12),
                          SwitchListTile.adaptive(
                            contentPadding: EdgeInsets.zero,
                            value: _isPrimary,
                            onChanged: (value) => setState(() => _isPrimary = value),
                            title: const Text('Set as primary'),
                            subtitle: const Text('Primary account receives campaign funds first.'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _isSubmitting ? null : widget.onCancel,
                            child: const Text('Cancel'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton(
                            onPressed: _isSubmitting
                                ? null
                                : () async {
                                    if (!(_formKey.currentState?.validate() ?? false)) return;
                                    setState(() => _isSubmitting = true);
                                    try {
                                      await widget.onSubmit(
                                        _BankAccountFormData(
                                          bankName: _bankNameController.text.trim(),
                                          accountHolder: _holderController.text.trim(),
                                          accountNumber: _numberController.text.trim(),
                                          isPrimary: _isPrimary,
                                        ),
                                      );
                                    } finally {
                                      if (mounted) {
                                        setState(() => _isSubmitting = false);
                                      }
                                    }
                                  },
                            child: Text(widget.initial == null ? 'Add account' : 'Save changes'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BankAccountCard extends ConsumerWidget {
  const _BankAccountCard({required this.account});

  final BankAccount account;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isBusy = ref.watch(bankAccountMutationProvider).isLoading;
    final theme = Theme.of(context);

    return AppCard(
      padding: const EdgeInsets.all(AppTheme.spacing16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(account.bankName, style: AppTextStyles.title),
              ),
              if (account.isPrimary)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: AppTheme.borderRadiusPill,
                  ),
                  child: Text(
                    'Primary',
                    style: AppTextStyles.micro.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppTheme.spacing8),
          Text(
            account.accountHolder,
            style: AppTextStyles.body.copyWith(color: AppColors.textBody),
          ),
          const SizedBox(height: AppTheme.spacing4),
          Text(
            _masked(account.accountNumber),
            style: AppTextStyles.title.copyWith(
              fontSize: 18,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: AppTheme.spacing16),
          Row(
            children: [
              TextButton.icon(
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: account.accountNumber));
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Copied ${account.bankName} account number.')),
                  );
                },
                icon: const Icon(Icons.copy_outlined, size: 18),
                label: const Text('Copy'),
              ),
              const Spacer(),
              IconButton(
                tooltip: 'Edit',
                onPressed: isBusy
                    ? null
                    : () => showBankAccountFormSheet(
                          context,
                          ref,
                          initial: account,
                        ),
                icon: const Icon(Icons.edit_outlined),
              ),
              IconButton(
                tooltip: account.isPrimary ? 'Primary account' : 'Set as primary',
                onPressed: isBusy || account.isPrimary
                    ? null
                    : () async {
                        await ref.read(bankAccountMutationProvider.notifier).setPrimary(account.id);
                        if (!context.mounted) return;
                        final state = ref.read(bankAccountMutationProvider);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(state.hasError ? state.error.toString() : 'Primary account updated.')),
                        );
                      },
                icon: Icon(
                  account.isPrimary ? Icons.verified_outlined : Icons.star_border_outlined,
                  color: account.isPrimary ? AppColors.primary : theme.colorScheme.onSurfaceVariant,
                ),
              ),
              IconButton(
                tooltip: 'Delete',
                onPressed: isBusy
                    ? null
                    : () async {
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (dialogContext) => AlertDialog(
                            title: const Text('Delete bank account'),
                            content: const Text('Are you sure you want to delete this bank account?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(dialogContext).pop(false),
                                child: const Text('Cancel'),
                              ),
                              FilledButton(
                                onPressed: () => Navigator.of(dialogContext).pop(true),
                                child: const Text('Delete'),
                              ),
                            ],
                          ),
                        );

                        if (confirmed != true) return;
                        await ref.read(bankAccountMutationProvider.notifier).remove(account.id);
                        if (!context.mounted) return;
                        final state = ref.read(bankAccountMutationProvider);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(state.hasError ? state.error.toString() : 'Bank account deleted.')),
                        );
                      },
                icon: Icon(Icons.delete_outline, color: theme.colorScheme.error),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static String _masked(String raw) {
    if (raw.length <= 4) return raw;
    final last4 = raw.substring(raw.length - 4);
    return '•••• •••• $last4';
  }
}

class _BankAccountFormData {
  const _BankAccountFormData({
    required this.bankName,
    required this.accountHolder,
    required this.accountNumber,
    required this.isPrimary,
  });

  final String bankName;
  final String accountHolder;
  final String accountNumber;
  final bool isPrimary;
}
