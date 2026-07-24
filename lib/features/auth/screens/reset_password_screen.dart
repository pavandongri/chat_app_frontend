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

/// Two stages sharing one screen/route: verify the reset code first, then
/// (once confirmed valid) collect the new password. Both stages reuse the
/// same OTP value, which `reset-password` re-validates server-side anyway.
class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({super.key, this.email});

  final String? email;

  @override
  ConsumerState<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _codeFormKey = GlobalKey<FormState>();
  final _passwordFormKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  bool _otpVerified = false;

  @override
  void dispose() {
    _otpController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _requireEmail() {
    final email = widget.email;
    if (email == null) {
      AppSnackBar.showError(
        context,
        'Missing email. Please restart the reset flow.',
      );
    }
    return email;
  }

  Future<void> _verifyCode() async {
    if (!(_codeFormKey.currentState?.validate() ?? false)) return;
    final email = _requireEmail();
    if (email == null) return;

    setState(() => _isLoading = true);
    try {
      await ref
          .read(authControllerProvider.notifier)
          .verifyResetOtp(email: email, otp: _otpController.text.trim());
      if (!mounted) return;
      setState(() => _otpVerified = true);
    } on AppException catch (e) {
      if (!mounted) return;
      AppSnackBar.showError(context, e.message);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _submit() async {
    if (!(_passwordFormKey.currentState?.validate() ?? false)) return;
    final email = _requireEmail();
    if (email == null) return;

    setState(() => _isLoading = true);
    try {
      await ref
          .read(authControllerProvider.notifier)
          .resetPassword(
            email: email,
            otp: _otpController.text.trim(),
            newPassword: _passwordController.text,
          );
      if (!mounted) return;
      AppSnackBar.showSuccess(context, 'Password reset. Please log in.');
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
      title: 'Reset password',
      subtitle: _otpVerified
          ? 'Choose a new password for your account.'
          : email == null
          ? 'Enter the code we sent you.'
          : 'Enter the code sent to $email.',
      child: _otpVerified ? _buildPasswordForm() : _buildCodeForm(),
    );
  }

  Widget _buildCodeForm() {
    return Form(
      key: _codeFormKey,
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
          AppButton(
            label: 'Verify Code',
            isLoading: _isLoading,
            onPressed: _verifyCode,
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordForm() {
    return Form(
      key: _passwordFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppTextField(
            controller: _passwordController,
            label: 'New Password',
            obscureText: _obscurePassword,
            validator: Validators.password,
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
              ),
              onPressed: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            controller: _confirmPasswordController,
            label: 'Confirm New Password',
            obscureText: _obscureConfirmPassword,
            validator: Validators.confirmPassword(
              () => _passwordController.text,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                _obscureConfirmPassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
              ),
              onPressed: () => setState(
                () => _obscureConfirmPassword = !_obscureConfirmPassword,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppButton(
            label: 'Reset Password',
            isLoading: _isLoading,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }
}
