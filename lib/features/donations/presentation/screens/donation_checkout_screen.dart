import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:charity_managment/core/theme/app_colors.dart';
import 'package:charity_managment/core/theme/app_text_styles.dart';
import 'package:charity_managment/core/theme/app_theme.dart';
import 'package:charity_managment/core/widgets/app_button.dart';
import 'package:charity_managment/features/campaigns/presentation/providers/campaign_detail_provider.dart';
import 'package:charity_managment/features/donations/presentation/providers/donation_detail_provider.dart';
import 'package:charity_managment/features/donations/presentation/providers/donation_history_provider.dart';
import 'package:charity_managment/features/donations/presentation/providers/donation_repository_provider.dart';
import 'package:charity_managment/models/donation.dart';
import 'package:charity_managment/routing/app_routes.dart';
import 'package:charity_managment/shared/widgets/app_scaffold.dart';

class DonationCheckoutScreen extends ConsumerStatefulWidget {
  const DonationCheckoutScreen({
    super.key,
    required this.donationId,
    required this.txRef,
    required this.checkoutUrl,
  });

  final String donationId;
  final String txRef;
  final String checkoutUrl;

  @override
  ConsumerState<DonationCheckoutScreen> createState() => _DonationCheckoutScreenState();
}

class _DonationCheckoutScreenState extends ConsumerState<DonationCheckoutScreen> {
  Timer? _pollTimer;
  bool _launchedCheckout = false;
  bool _isLaunching = false;
  bool _isVerifying = false;
  String? _statusMessage;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    scheduleMicrotask(() async {
      if (widget.checkoutUrl.isNotEmpty) {
        await _openCheckout();
      }
      _startPolling();
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> _openCheckout({bool force = false}) async {
    if ((!force && _launchedCheckout) || _isLaunching) return;

    final uri = Uri.tryParse(widget.checkoutUrl);
    if (widget.checkoutUrl.isEmpty || uri == null) {
      setState(() {
        _errorMessage = 'Payment checkout link is invalid.';
      });
      return;
    }

    setState(() {
      _isLaunching = true;
      _errorMessage = null;
    });

    try {
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched && mounted) {
        setState(() {
          _errorMessage = 'Unable to open Chapa checkout.';
        });
      }
      _launchedCheckout = launched;
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = error.toString();
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _isLaunching = false;
      });
    }
  }

  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 8), (_) {
      _verifyPayment(showPendingMessage: false);
    });
    _verifyPayment(showPendingMessage: false);
  }

  Future<void> _verifyPayment({bool showPendingMessage = true}) async {
    if (_isVerifying) return;

    if (widget.txRef.isEmpty) {
      setState(() {
        _errorMessage = 'Payment transaction reference is missing.';
      });
      return;
    }

    setState(() {
      _isVerifying = true;
      _errorMessage = null;
      if (showPendingMessage) {
        _statusMessage = 'Checking payment status...';
      }
    });

    try {
      final repository = ref.read(donationRepositoryProvider);
      final donation = await repository.getDonationByTransactionRef(widget.txRef);

      if (!mounted) return;

      if (donation == null || donation.status == DonationStatus.pending) {
        setState(() {
          _statusMessage = 'Payment is still pending. Complete checkout, then check again.';
        });
        return;
      }

      if (donation.status == DonationStatus.completed) {
        _pollTimer?.cancel();
        ref.invalidate(donationDetailProvider(donation.id));
        ref.invalidate(campaignDetailProvider(donation.campaignId));
        ref.invalidate(donationHistoryProvider);
        context.go(AppRoutes.donationSuccess(donation.id));
        return;
      }

      setState(() {
        _statusMessage = 'Payment status: ${donation.status.label}.';
        _errorMessage = 'The payment was not completed. Please try again.';
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = error.toString();
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _isVerifying = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Chapa Payment',
      showNotificationAction: false,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppTheme.spacing24),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppTheme.borderRadiusMd,
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.primaryBg,
                        borderRadius: AppTheme.borderRadiusMd,
                      ),
                      child: const Icon(Icons.payments_outlined, color: AppColors.primary),
                    ),
                    const SizedBox(width: AppTheme.spacing16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Complete your payment', style: AppTextStyles.title),
                          const SizedBox(height: AppTheme.spacing4),
                          Text('Transaction ${widget.txRef}', style: AppTextStyles.micro),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.spacing24),
                Text(
                  _statusMessage ??
                      (widget.checkoutUrl.isEmpty
                          ? 'Verifying your Chapa payment...'
                          : 'Chapa checkout opened in your browser.'),
                  style: AppTextStyles.body,
                ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: AppTheme.spacing12),
                  Text(
                    _errorMessage!,
                    style: AppTextStyles.body.copyWith(color: AppColors.error),
                  ),
                ],
                const SizedBox(height: AppTheme.spacing24),
                AppButton(
                  text: _isVerifying ? 'Checking...' : 'Check Payment Status',
                  isLoading: _isVerifying,
                  onPressed: () => _verifyPayment(),
                ),
                if (widget.checkoutUrl.isNotEmpty) ...[
                  const SizedBox(height: AppTheme.spacing12),
                  OutlinedButton.icon(
                    onPressed:
                        _isLaunching ? null : () => _openCheckout(force: true),
                    icon: const Icon(Icons.open_in_new_outlined),
                    label: const Text('Open Chapa Checkout'),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
