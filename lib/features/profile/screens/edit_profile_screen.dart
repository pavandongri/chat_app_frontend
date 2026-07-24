import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/gender_options.dart';
import '../../../core/network/app_exception.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_bar.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/user_avatar.dart';
import '../../../models/user.dart';
import '../../../providers/profile_provider.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key, required this.user});

  final User user;

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _avatarUrlController;
  late String? _gender;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name ?? '');
    _avatarUrlController = TextEditingController(text: widget.user.avatarUrl ?? '');
    _gender = widget.user.gender;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _avatarUrlController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSaving = true);
    try {
      final avatarUrl = _avatarUrlController.text.trim();
      await ref.read(profileControllerProvider.notifier).updateProfile(
            name: _nameController.text.trim(),
            gender: _gender,
            avatarUrl: avatarUrl.isEmpty ? null : avatarUrl,
          );
      if (!mounted) return;
      AppSnackBar.showSuccess(context, 'Profile updated.');
      context.pop();
    } on AppException catch (e) {
      if (!mounted) return;
      AppSnackBar.showError(context, e.message);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Edit Profile'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: ValueListenableBuilder<TextEditingValue>(
                        valueListenable: _avatarUrlController,
                        builder: (context, value, _) => UserAvatar(
                          name: _nameController.text.trim().isEmpty
                              ? widget.user.username
                              : _nameController.text.trim(),
                          avatarUrl: value.text.trim().isEmpty ? null : value.text.trim(),
                          radius: 48,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    AppTextField(
                      controller: _nameController,
                      label: 'Name',
                      validator: Validators.name,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    DropdownButtonFormField<String>(
                      initialValue: _gender,
                      decoration: const InputDecoration(labelText: 'Gender'),
                      items: kGenderOptions
                          .map((g) => DropdownMenuItem(value: g, child: Text(g[0].toUpperCase() + g.substring(1))))
                          .toList(),
                      onChanged: (value) => setState(() => _gender = value),
                      validator: Validators.gender,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppTextField(
                      controller: _avatarUrlController,
                      label: 'Avatar URL',
                      hint: 'https://example.com/avatar.png',
                      keyboardType: TextInputType.url,
                      validator: Validators.avatarUrl,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Leave blank to keep your current avatar.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AppButton(label: 'Save Changes', isLoading: _isSaving, onPressed: _submit),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
