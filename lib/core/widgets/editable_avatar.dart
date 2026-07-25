import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import 'app_snackbar.dart';
import 'small_spinner.dart';
import 'user_avatar.dart';

/// [UserAvatar] with a camera-badge overlay that opens a camera/gallery
/// picker. The caller owns the actual upload — [onPickImage] is handed the
/// picked file, and [isUploading] drives the in-progress overlay so this
/// widget never has to know about the network call itself.
class EditableAvatar extends StatelessWidget {
  static const _maxBytes = 2 * 1024 * 1024;

  const EditableAvatar({
    super.key,
    required this.name,
    required this.onPickImage,
    this.avatarUrl,
    this.radius = 56,
    this.isUploading = false,
  });

  final String name;
  final String? avatarUrl;
  final double radius;
  final bool isUploading;
  final ValueChanged<File> onPickImage;

  Future<void> _showPicker(BuildContext context) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Take Photo'),
              onTap: () => Navigator.of(sheetContext).pop(ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose from Gallery'),
              onTap: () => Navigator.of(sheetContext).pop(ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.close),
              title: const Text('Cancel'),
              onTap: () => Navigator.of(sheetContext).pop(),
            ),
          ],
        ),
      ),
    );
    if (source == null || !context.mounted) return;

    final picked = await ImagePicker().pickImage(
      source: source,
      maxWidth: 1024,
      imageQuality: 85,
    );
    if (picked == null) return;

    final sizeBytes = await picked.length();
    if (sizeBytes > _maxBytes) {
      if (context.mounted) {
        AppSnackBar.showError(context, 'Image must be 2MB or smaller.');
      }
      return;
    }

    onPickImage(File(picked.path));
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final diameter = radius * 2;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Opacity(
          opacity: isUploading ? 0.5 : 1,
          child: UserAvatar(name: name, avatarUrl: avatarUrl, radius: radius),
        ),
        if (isUploading)
          Positioned.fill(
            child: Center(
              child: SizedBox(
                width: diameter * 0.4,
                height: diameter * 0.4,
                child: const SmallSpinner(),
              ),
            ),
          ),
        Positioned(
          right: -4,
          bottom: -4,
          child: Material(
            color: colorScheme.primary,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: isUploading ? null : () => _showPicker(context),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xs),
                child: Icon(
                  Icons.camera_alt,
                  size: 18,
                  color: colorScheme.onPrimary,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
