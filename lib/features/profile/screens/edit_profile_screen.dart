import 'dart:io';

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
import '../../../core/widgets/editable_avatar.dart';
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
  late String? _gender;
  late String? _avatarUrl;

  bool _isSaving = false;
  bool _isUploadingAvatar = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name ?? '');
    _gender = widget.user.gender;
    _avatarUrl = widget.user.avatarUrl;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _uploadAvatar(File file) async {
    setState(() => _isUploadingAvatar = true);
    try {
      await ref.read(profileControllerProvider.notifier).uploadAvatar(file);
      if (!mounted) return;
      setState(() {
        _avatarUrl = ref.read(profileControllerProvider).valueOrNull?.avatarUrl;
      });
    } on AppException catch (e) {
      if (mounted) AppSnackBar.showError(context, e.message);
    } finally {
      if (mounted) setState(() => _isUploadingAvatar = false);
    }
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSaving = true);
    try {
      await ref
          .read(profileControllerProvider.notifier)
          .updateProfile(name: _nameController.text.trim(), gender: _gender);
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
                        valueListenable: _nameController,
                        builder: (context, value, _) => EditableAvatar(
                          name: value.text.trim().isEmpty
                              ? widget.user.username
                              : value.text.trim(),
                          avatarUrl: _avatarUrl,
                          radius: 48,
                          isUploading: _isUploadingAvatar,
                          onPickImage: _uploadAvatar,
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
                          .map(
                            (g) => DropdownMenuItem(
                              value: g,
                              child: Text(g[0].toUpperCase() + g.substring(1)),
                            ),
                          )
                          .toList(),
                      onChanged: (value) => setState(() => _gender = value),
                      validator: Validators.gender,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AppButton(
                      label: 'Save Changes',
                      isLoading: _isSaving,
                      onPressed: _submit,
                    ),
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
