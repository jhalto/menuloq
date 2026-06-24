import 'package:flutter/material.dart';

import '../../../../config/theme/app_colors.dart';

class MessageBox extends StatelessWidget {
  const MessageBox({
    super.key,
    required this.icon,
    required this.text,
    required this.backgroundColor,
    required this.borderColor,
    required this.iconColor,
    required this.textColor,
    this.actionText,
    this.actionColor,
    this.onActionTap,
  });

  final IconData icon;
  final String text;
  final String? actionText;
  final Color backgroundColor;
  final Color borderColor;
  final Color iconColor;
  final Color textColor;
  final Color? actionColor;
  final VoidCallback? onActionTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
          if (actionText != null) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onActionTap,
              child: Text(
                actionText!,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: actionColor ?? AppColors.accent,
                      fontWeight: FontWeight.w900,
                    ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}