import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
            children: [
              EmptyState(
                title: 'Unable to load bank accounts',
                subtitle: error.toString(),
              ),
            ],
          ),
          data: (accounts) {
            if (accounts.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  const EmptyState(
                    title: 'No bank accounts yet',
                    subtitle: 'Add a bank account to receive campaign funds.',
                  ),
                  const SizedBox(height: 8),
                  FilledButton.icon(
                    onPressed: mutationState.isLoading
                        ? null
                        : () => showBankAccountFormDialog(context, ref),
                    icon: const Icon(Icons.add),
                    label: const Text('Add bank account'),
                  ),
                ],
              );
            }

            return ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: accounts.length + 1,
              separatorBuilder: (_, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                if (index == 0) {
                  return FilledButton.icon(
                    onPressed: mutationState.isLoading
                        ? null
                        : () => showBankAccountFormDialog(context, ref),
                    icon: const Icon(Icons.add),
                    label: const Text('Add bank account'),
                  );
                }

                final account = accounts[index - 1];
                return _BankAccountCard(account: account);
              },
            );
          },
        ),
      ),
    );
  }
}

Future<void> showBankAccountFormDialog(
  BuildContext context,
  WidgetRef ref, {
  BankAccount? initial,
}) async {
  final formKey = GlobalKey<FormState>();
  final bankNameController = TextEditingController(text: initial?.bankName ?? '');
  final holderController = TextEditingController(text: initial?.accountHolder ?? '');
  final numberController = TextEditingController(text: initial?.accountNumber ?? '');
  var accountType = initial?.type.toUpperCase() == 'BUSINESS' ? 'BUSINESS' : 'PERSONAL';
  var isPrimary = initial?.isPrimary ?? false;

  final result = await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(initial == null ? 'Add bank account' : 'Edit bank account'),
            content: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: bankNameController,
                      decoration: const InputDecoration(labelText: 'Bank name'),
                      validator: (value) =>
                          (value == null || value.trim().isEmpty) ? 'Bank name is required' : null,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: holderController,
                      decoration: const InputDecoration(labelText: 'Account holder'),
                      validator: (value) =>
                          (value == null || value.trim().isEmpty) ? 'Account holder is required' : null,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: numberController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Account number'),
                      validator: (value) =>
                          (value == null || value.trim().isEmpty) ? 'Account number is required' : null,
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      initialValue: accountType,
                      items: const [
                        DropdownMenuItem(value: 'PERSONAL', child: Text('Personal')),
                        DropdownMenuItem(value: 'BUSINESS', child: Text('Business')),
                      ],
                      decoration: const InputDecoration(labelText: 'Account type'),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => accountType = value);
                        }
                      },
                    ),
                    const SizedBox(height: 10),
                    SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      value: isPrimary,
                      onChanged: (value) => setState(() => isPrimary = value),
                      title: const Text('Set as primary'),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () {
                  if (!(formKey.currentState?.validate() ?? false)) return;
                  Navigator.of(dialogContext).pop(true);
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      );
    },
  );

  if (result != true) return;

  final notifier = ref.read(bankAccountMutationProvider.notifier);
  if (initial == null) {
    await notifier.create(
      bankName: bankNameController.text.trim(),
      accountHolder: holderController.text.trim(),
      accountNumber: numberController.text.trim(),
      type: accountType,
      isPrimary: isPrimary,
    );
  } else {
    await notifier.update(
      accountId: initial.id,
      bankName: bankNameController.text.trim(),
      accountHolder: holderController.text.trim(),
      accountNumber: numberController.text.trim(),
      type: accountType,
      isPrimary: isPrimary,
    );
  }

  final state = ref.read(bankAccountMutationProvider);
  if (context.mounted) {
    if (state.hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.error.toString())),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(initial == null ? 'Bank account added.' : 'Bank account updated.'),
        ),
      );
    }
  }
}

class _BankAccountCard extends ConsumerWidget {
  const _BankAccountCard({required this.account});

  final BankAccount account;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mutationState = ref.watch(bankAccountMutationProvider);
    final isBusy = mutationState.isLoading;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    account.bankName,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                if (account.isPrimary)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      'Primary',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Holder: ${account.accountHolder}'),
            const SizedBox(height: 4),
            Text('Number: ${_masked(account.accountNumber)}'),
            const SizedBox(height: 4),
            Text('Type: ${account.type.toUpperCase()}'),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton(
                  onPressed: isBusy
                      ? null
                      : () => showBankAccountFormDialog(
                            context,
                            ref,
                            initial: account,
                          ),
                  child: const Text('Edit'),
                ),
                OutlinedButton(
                  onPressed: isBusy || account.isPrimary
                      ? null
                      : () async {
                          await ref.read(bankAccountMutationProvider.notifier).setPrimary(account.id);
                          final state = ref.read(bankAccountMutationProvider);
                          if (!context.mounted) return;
                          if (state.hasError) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(state.error.toString())),
                            );
                          }
                        },
                  child: const Text('Set primary'),
                ),
                TextButton(
                  onPressed: isBusy
                      ? null
                      : () async {
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Delete bank account'),
                              content: const Text(
                                'Are you sure you want to delete this bank account?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(false),
                                  child: const Text('Cancel'),
                                ),
                                FilledButton(
                                  onPressed: () => Navigator.of(context).pop(true),
                                  child: const Text('Delete'),
                                ),
                              ],
                            ),
                          );

                          if (confirmed != true) return;
                          await ref.read(bankAccountMutationProvider.notifier).remove(account.id);
                          final state = ref.read(bankAccountMutationProvider);
                          if (!context.mounted) return;
                          if (state.hasError) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(state.error.toString())),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Bank account deleted.')),
                            );
                          }
                        },
                  child: const Text('Delete'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static String _masked(String raw) {
    if (raw.length <= 4) return raw;
    final last4 = raw.substring(raw.length - 4);
    return '•••• •••• $last4';
  }
}
