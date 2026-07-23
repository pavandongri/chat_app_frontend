import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/app_exception.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../providers/auth_provider.dart';
import '../../../routes/route_names.dart';
import '../widgets/auth_scaffold.dart';

class VerifyOtpScreen extends ConsumerStatefulWidget {
  const VerifyOtpScreen({super.key, this.email});

  final String? email;

  @override
  ConsumerState<VerifyOtpScreen> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends ConsumerState<VerifyOtpScreen> {
  static const _resendCooldown = 30;

  final _formKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();

  bool _isLoading = false;
  int _resendSecondsLeft = _resendCooldown;
  Timer? _resendTimer;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  void _startResendTimer() {
    _resendTimer?.cancel();
    setState(() => _resendSecondsLeft = _resendCooldown);
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendSecondsLeft <= 1) {
        timer.cancel();
        setState(() => _resendSecondsLeft = 0);
      } else {
        setState(() => _resendSecondsLeft -= 1);
      }
    });
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _resend() async {
    final email = widget.email;
    if (email == null) return;

    try {
      await ref.read(authControllerProvider.notifier).resendOtp(email: email);
      if (!mounted) return;
      AppSnackBar.showSuccess(context, 'Verification code resent.');
      _startResendTimer();
    } on AppException catch (e) {
      if (!mounted) return;
      AppSnackBar.showError(context, e.message);
    }
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final email = widget.email;
    if (email == null) {
      AppSnackBar.showError(context, 'Missing email. Please sign up again.');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await ref.read(authControllerProvider.notifier).verifyEmail(
            email: email,
            otp: _otpController.text.trim(),
          );
      if (!mounted) return;
      AppSnackBar.showSuccess(context, 'Account verified. Please log in.');
      context.go(RouteNames.login);
    } on AppException catch (e) {
      if (!mounted) return;
      AppSnackBar.showError(context, e.message);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final email = widget.email;

    return AuthScaffold(
      title: 'Verify your email',
      subtitle: email == null
          ? 'Enter the 6-digit code we sent you.'
          : 'Enter the 6-digit code sent to $email.',
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppTextField(
              controller: _otpController,
              label: 'Verification Code',
              keyboardType: TextInputType.number,
              validator: Validators.otp,
            ),
            const SizedBox(height: AppSpacing.lg),
            AppButton(label: 'Verify', isLoading: _isLoading, onPressed: _submit),
            const SizedBox(height: AppSpacing.md),
            Align(
              alignment: Alignment.center,
              child: TextButton(
                onPressed: _resendSecondsLeft == 0 ? _resend : null,
                child: Text(
                  _resendSecondsLeft == 0
                      ? 'Resend code'
                      : 'Resend code in ${_resendSecondsLeft}s',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
