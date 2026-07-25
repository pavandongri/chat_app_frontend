import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_gradients.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import 'small_spinner.dart';

/// Visual style for [AppButton]. [filled] is the standard Material button;
/// [gradient] paints the Story 21 brand gradient for primary calls-to-action
/// (auth screens, hero actions) that want extra emphasis.
enum AppButtonVariant { filled, gradient }

/// Reusable primary button with a built-in loading state. Disabled while
/// [isLoading] is true or [onPressed] is null.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.variant = AppButtonVariant.filled,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final AppButtonVariant variant;

  @override
  Widget build(BuildContext context) {
    if (variant == AppButtonVariant.gradient) {
      return _GradientButton(
        label: label,
        onPressed: onPressed,
        isLoading: isLoading,
      );
    }

    return _PressScale(
      enabled: !isLoading && onPressed != null,
      child: FilledButton(
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? const SmallSpinner(size: 20, strokeWidth: 2)
            : Text(label),
      ),
    );
  }
}

/// Subtle press-down scale, layered on top of a button's own ripple —
/// consistent tactile feedback across every [AppButton] variant. Uses
/// [Listener] (not [GestureDetector]) so it observes pointer events without
/// competing with the button's own tap recognizer for the gesture arena.
class _PressScale extends StatefulWidget {
  const _PressScale({required this.enabled, required this.child});

  final bool enabled;
  final Widget child;

  @override
  State<_PressScale> createState() => _PressScaleState();
}

class _PressScaleState extends State<_PressScale> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed == value) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: widget.enabled ? (_) => _setPressed(true) : null,
      onPointerUp: widget.enabled ? (_) => _setPressed(false) : null,
      onPointerCancel: widget.enabled ? (_) => _setPressed(false) : null,
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}

class _GradientButton extends StatelessWidget {
  const _GradientButton({
    required this.label,
    required this.onPressed,
    required this.isLoading,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final enabled = !isLoading && onPressed != null;

    return _PressScale(
      enabled: enabled,
      child: Opacity(
        opacity: enabled ? 1 : 0.5,
        child: ClipRRect(
          borderRadius: AppRadius.mdRadius,
          // A plain `Container` (not `Ink`) paints the gradient itself,
          // right here — `Ink` instead draws via the nearest ancestor
          // `Material`, which (through a `GlassCard`'s `BackdropFilter`)
          // ends up rendered as "background" content that gets blurred and
          // dimmed by the glass panel's own frosting, making the button
          // look washed out/invisible. The local transparent `Material`
          // below still gives `InkWell` a proper ripple surface.
          child: Container(
            decoration: const BoxDecoration(gradient: AppGradients.primary),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: enabled ? onPressed : null,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.md,
                  ),
                  child: Center(
                    child: isLoading
                        ? const SmallSpinner(
                            size: 20,
                            strokeWidth: 2,
                            color: AppColors.onGradient,
                          )
                        : Text(
                            label,
                            style: Theme.of(context).textTheme.labelLarge
                                ?.copyWith(color: AppColors.onGradient),
                          ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
