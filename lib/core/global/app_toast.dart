import 'dart:async';

import 'package:flutter/material.dart';

enum AppToastType { success, error }

class AppToast {
  const AppToast._();

  static OverlayEntry? _currentEntry;
  static Timer? _dismissTimer;

  static void success(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    show(
      context,
      message: message,
      type: AppToastType.success,
      duration: duration,
    );
  }

  static void error(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 4),
  }) {
    show(
      context,
      message: message,
      type: AppToastType.error,
      duration: duration,
    );
  }

  static void show(
    BuildContext context, {
    required String message,
    required AppToastType type,
    Duration duration = const Duration(seconds: 3),
  }) {
    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null || message.trim().isEmpty) return;

    dismiss();

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final style = _AppToastStyle.fromType(type, isDark);

    final entry = OverlayEntry(
      builder: (context) => _AppToastOverlay(
        message: message,
        style: style,
        onClose: dismiss,
      ),
    );

    _currentEntry = entry;
    overlay.insert(entry);
    _dismissTimer = Timer(duration, dismiss);
  }

  static void dismiss() {
    _dismissTimer?.cancel();
    _dismissTimer = null;
    _currentEntry?.remove();
    _currentEntry = null;
  }
}

class _AppToastOverlay extends StatelessWidget {
  const _AppToastOverlay({
    required this.message,
    required this.style,
    required this.onClose,
  });

  final String message;
  final _AppToastStyle style;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        bottom: false,
        child: IgnorePointer(
          ignoring: false,
          child: Material(
            color: Colors.transparent,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: style.backgroundColor,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: style.borderColor),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.14),
                          blurRadius: 22,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
                      child: Row(
                        children: [
                          Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: style.iconBackgroundColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              style.icon,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              message,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: style.messageColor,
                                fontWeight: FontWeight.w800,
                                height: 1.35,
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
                              color: style.messageColor.withValues(
                                alpha: 0.75,
                              ),
                              size: 20,
                            ),
                          ),
                        ],
                      ),
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

class _AppToastStyle {
  const _AppToastStyle({
    required this.icon,
    required this.backgroundColor,
    required this.borderColor,
    required this.iconBackgroundColor,
    required this.messageColor,
  });

  final IconData icon;
  final Color backgroundColor;
  final Color borderColor;
  final Color iconBackgroundColor;
  final Color messageColor;

  factory _AppToastStyle.fromType(AppToastType type, bool isDark) {
    switch (type) {
      case AppToastType.success:
        return _AppToastStyle(
          icon: Icons.check_rounded,
          backgroundColor:
              isDark ? const Color(0xFF052E1A) : const Color(0xFFEFFAF3),
          borderColor:
              isDark ? const Color(0xFF166534) : const Color(0xFFB7E4C7),
          iconBackgroundColor:
              isDark ? const Color(0xFF22C55E) : const Color(0xFF16A34A),
          messageColor:
              isDark ? const Color(0xFFBBF7D0) : const Color(0xFF166534),
        );

      case AppToastType.error:
        return _AppToastStyle(
          icon: Icons.close_rounded,
          backgroundColor:
              isDark ? const Color(0xFF3B0A0A) : const Color(0xFFFFF1F2),
          borderColor:
              isDark ? const Color(0xFF7F1D1D) : const Color(0xFFFECACA),
          iconBackgroundColor:
              isDark ? const Color(0xFFEF4444) : const Color(0xFFDC2626),
          messageColor:
              isDark ? const Color(0xFFFECACA) : const Color(0xFF7F1D1D),
        );
    }
  }
}
