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

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  static const _genderOptions = ['female', 'male', 'other'];

  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String? _gender;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isLoading = true);
    try {
      final email = _emailController.text.trim();
      await ref.read(authControllerProvider.notifier).signup(
            username: _usernameController.text.trim(),
            name: _nameController.text.trim(),
            gender: _gender!,
            email: email,
            password: _passwordController.text,
          );
      if (!mounted) return;
      context.push(
        Uri(path: RouteNames.verifyOtp, queryParameters: {'email': email}).toString(),
      );
    } on AppException catch (e) {
      if (!mounted) return;
      AppSnackBar.showError(context, e.message);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'Create your account',
      subtitle: 'Sign up to start chatting with friends.',
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppTextField(
              controller: _usernameController,
              label: 'Username',
              validator: Validators.username,
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              controller: _nameController,
              label: 'Name',
              validator: Validators.name,
            ),
            const SizedBox(height: AppSpacing.md),
            DropdownButtonFormField<String>(
              initialValue: _gender,
              decoration: const InputDecoration(labelText: 'Gender'),
              items: _genderOptions
                  .map((g) => DropdownMenuItem(value: g, child: Text(g[0].toUpperCase() + g.substring(1))))
                  .toList(),
              onChanged: (value) => setState(() => _gender = value),
              validator: Validators.gender,
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              controller: _emailController,
              label: 'Email',
              keyboardType: TextInputType.emailAddress,
              validator: Validators.email,
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              controller: _passwordController,
              label: 'Password',
              obscureText: _obscurePassword,
              validator: Validators.password,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                ),
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              controller: _confirmPasswordController,
              label: 'Confirm Password',
              obscureText: _obscureConfirmPassword,
              validator: Validators.confirmPassword(() => _passwordController.text),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirmPassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
                onPressed: () =>
                    setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            AppButton(label: 'Sign Up', isLoading: _isLoading, onPressed: _submit),
            const SizedBox(height: AppSpacing.lg),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Already have an account?'),
                TextButton(
                  onPressed: () => context.pop(),
                  child: const Text('Log in'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
