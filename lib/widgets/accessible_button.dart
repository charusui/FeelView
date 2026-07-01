import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// The single accessible button used throughout Elder Mode.
/// Enforces 64×64pt minimum touch target, haptic feedback, and
/// high-contrast styling. Use this instead of ElevatedButton in elder screens.
class AccessibleButton extends StatelessWidget {
  const AccessibleButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.icon,
    this.semanticLabel,
    this.color,
    this.textColor,
    this.isDestructive = false,
    this.isLarge = false,
  });

  final VoidCallback? onPressed;
  final String label;
  final IconData? icon;
  final String? semanticLabel;
  final Color? color;
  final Color? textColor;
  final bool isDestructive;
  /// Extra-large variant for the most prominent action on a screen.
  final bool isLarge;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bgColor = isDestructive
        ? Colors.red.shade700
        : (color ?? theme.colorScheme.primary);
    final fg = textColor ?? Colors.white;
    final double minH = isLarge ? 80 : 64;
    final double fontSize = isLarge ? 22 : 18;

    return Semantics(
      label: semanticLabel ?? label,
      button: true,
      child: MaterialButton(
        onPressed: onPressed == null
            ? null
            : () {
                HapticFeedback.mediumImpact();
                onPressed!();
              },
        color: bgColor,
        disabledColor: Colors.grey.shade400,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: isLarge ? 32 : 24,
          vertical: isLarge ? 20 : 14,
        ),
        minWidth: 64,
        height: minH,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, color: fg, size: isLarge ? 28 : 24),
              const SizedBox(width: 10),
            ],
            Flexible(
              child: Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: fg,
                  fontSize: fontSize,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Icon-only variant — always shows a tooltip / semantic label.
class AccessibleIconButton extends StatelessWidget {
  const AccessibleIconButton({
    super.key,
    required this.onPressed,
    required this.icon,
    required this.semanticLabel,
    this.color,
    this.size = 32,
  });

  final VoidCallback? onPressed;
  final IconData icon;
  final String semanticLabel;
  final Color? color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      button: true,
      child: InkWell(
        onTap: onPressed == null
            ? null
            : () {
                HapticFeedback.lightImpact();
                onPressed!();
              },
        borderRadius: BorderRadius.circular(32),
        child: SizedBox(
          width: 64,
          height: 64,
          child: Center(
            child: Icon(
              icon,
              size: size,
              color: color ?? Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      ),
    );
  }
}
