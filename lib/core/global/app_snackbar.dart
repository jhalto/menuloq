import 'package:flutter/material.dart';

enum AppSnackBarType {
  success,
  error,
}

class AppSnackBar {
  const AppSnackBar._();

  static void success(
    BuildContext context, {
    required String message,
    String title = 'Success',
    Duration duration = const Duration(seconds: 3),
  }) {
    show(
      context,
      type: AppSnackBarType.success,
      title: title,
      message: message,
      duration: duration,
    );
  }

  static void error(
    BuildContext context, {
    required String message,
    String title = 'Error',
    Duration duration = const Duration(seconds: 4),
  }) {
    show(
      context,
      type: AppSnackBarType.error,
      title: title,
      message: message,
      duration: duration,
    );
  }

  static void show(
    BuildContext context, {
    required AppSnackBarType type,
    required String title,
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final style = _SnackBarStyle.fromType(type, isDark);

    final messenger = ScaffoldMessenger.of(context);

    messenger.hideCurrentSnackBar();

    messenger.showSnackBar(
      SnackBar(
        elevation: 0,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 18),
        padding: EdgeInsets.zero,
        content: _AppSnackBarContent(
          title: title,
          message: message,
          icon: style.icon,
          backgroundColor: style.backgroundColor,
          borderColor: style.borderColor,
          iconBackgroundColor: style.iconBackgroundColor,
          iconColor: style.iconColor,
          titleColor: style.titleColor,
          messageColor: style.messageColor,
          onClose: messenger.hideCurrentSnackBar,
        ),
      ),
    );
  }
}

class _AppSnackBarContent extends StatelessWidget {
  const _AppSnackBarContent({
    required this.title,
    required this.message,
    required this.icon,
    required this.backgroundColor,
    required this.borderColor,
    required this.iconBackgroundColor,
    required this.iconColor,
    required this.titleColor,
    required this.messageColor,
    required this.onClose,
  });

  final String title;
  final String message;
  final IconData icon;
  final Color backgroundColor;
  final Color borderColor;
  final Color iconBackgroundColor;
  final Color iconColor;
  final Color titleColor;
  final Color messageColor;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 8, 14),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: iconBackgroundColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 1),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: titleColor,
                      fontWeight: FontWeight.w900,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: messageColor,
                      fontWeight: FontWeight.w600,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 6),
          IconButton(
            onPressed: onClose,
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(
              minWidth: 32,
              minHeight: 32,
            ),
            icon: Icon(
              Icons.close_rounded,
              color: messageColor.withValues(alpha: 0.75),
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}

class _SnackBarStyle {
  const _SnackBarStyle({
    required this.icon,
    required this.backgroundColor,
    required this.borderColor,
    required this.iconBackgroundColor,
    required this.iconColor,
    required this.titleColor,
    required this.messageColor,
  });

  final IconData icon;
  final Color backgroundColor;
  final Color borderColor;
  final Color iconBackgroundColor;
  final Color iconColor;
  final Color titleColor;
  final Color messageColor;

  factory _SnackBarStyle.fromType(AppSnackBarType type, bool isDark) {
    switch (type) {
      case AppSnackBarType.success:
        return _SnackBarStyle(
          icon: Icons.check_rounded,
          backgroundColor:
              isDark ? const Color(0xFF052E1A) : const Color(0xFFEFFAF3),
          borderColor:
              isDark ? const Color(0xFF166534) : const Color(0xFFB7E4C7),
          iconBackgroundColor:
              isDark ? const Color(0xFF22C55E) : const Color(0xFF16A34A),
          iconColor: Colors.white,
          titleColor:
              isDark ? const Color(0xFFDCFCE7) : const Color(0xFF166534),
          messageColor:
              isDark ? const Color(0xFFBBF7D0) : const Color(0xFF166534),
        );

      case AppSnackBarType.error:
        return _SnackBarStyle(
          icon: Icons.close_rounded,
          backgroundColor:
              isDark ? const Color(0xFF3B0A0A) : const Color(0xFFFFF1F2),
          borderColor:
              isDark ? const Color(0xFF7F1D1D) : const Color(0xFFFECACA),
          iconBackgroundColor:
              isDark ? const Color(0xFFEF4444) : const Color(0xFFDC2626),
          iconColor: Colors.white,
          titleColor:
              isDark ? const Color(0xFFFEE2E2) : const Color(0xFF991B1B),
          messageColor:
              isDark ? const Color(0xFFFECACA) : const Color(0xFF7F1D1D),
        );
    }
  }
}