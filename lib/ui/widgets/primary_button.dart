import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isCompact;

  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final padding = isCompact
        ? const EdgeInsets.symmetric(horizontal: 12, vertical: 6)
        : const EdgeInsets.symmetric(horizontal: 24, vertical: 16);
    final buttonShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    );

    if (icon != null) {
      return FilledButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: isCompact ? 18 : null),
        label: Text(label),
        style: FilledButton.styleFrom(
          padding: padding,
          minimumSize: isCompact ? const Size(0, 36) : null,
          tapTargetSize: isCompact ? MaterialTapTargetSize.shrinkWrap : null,
          shape: buttonShape,
        ),
      );
    }

    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        padding: padding,
        minimumSize: isCompact ? const Size(0, 36) : null,
        tapTargetSize: isCompact ? MaterialTapTargetSize.shrinkWrap : null,
        shape: buttonShape,
      ),
      child: Text(label),
    );
  }
}
