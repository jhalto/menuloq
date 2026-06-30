import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:menuloq/config/route/route_name.dart';
import 'package:menuloq/features/auth/domain/enums/verify_email_type.dart';
import 'package:menuloq/features/auth/presentation/widgets/verifly_email/otp_code_field.dart';

import '../../../../config/theme/app_colors.dart';
import '../bloc/verify_email/verify_email_bloc.dart';
import '../bloc/verify_email/verify_email_event.dart';
import '../bloc/verify_email/verify_email_state.dart';
import '../widgets/loading_button_content.dart';
import '../widgets/message_box.dart';

class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({
    super.key,
    required this.email,
    this.type = VerifyEmailType.registration,
  });

  final String email;
  final VerifyEmailType type;

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
  static const double _tabletBreakpoint = 720;

  @override
  void initState() {
    super.initState();

    context.read<VerifyEmailBloc>().add(
      VerifyEmailStarted(email: widget.email),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isTablet = constraints.maxWidth >= _tabletBreakpoint;

            if (isTablet) {
              return _TabletVerifyEmailLayout(
                email: widget.email,
                type: widget.type,
              );
            }

            return _MobileVerifyEmailLayout(
              email: widget.email,
              type: widget.type,
            );
          },
        ),
      ),
    );
  }
}

class _MobileVerifyEmailLayout extends StatelessWidget {
  const _MobileVerifyEmailLayout({required this.email, required this.type});

  final String email;
  final VerifyEmailType type;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 430),
          child: VerifyEmailContent(email: email, type: type),
        ),
      ),
    );
  }
}

class _TabletVerifyEmailLayout extends StatelessWidget {
  const _TabletVerifyEmailLayout({required this.email, required this.type});

  final String email;
  final VerifyEmailType type;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: _VerifyBrandPanel()),
        Expanded(
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 40),
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 500),
                padding: const EdgeInsets.all(34),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: AppColors.cardBorder),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.lightShadow,
                      blurRadius: 28,
                      offset: Offset(0, 16),
                    ),
                  ],
                ),
                child: VerifyEmailContent(
                  email: email,
                  type: type,
                  showBackButton: false,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class VerifyEmailContent extends StatefulWidget {
  const VerifyEmailContent({
    super.key,
    required this.email,
    required this.type,
    this.showBackButton = true,
  });

  final String email;
  final VerifyEmailType type;
  final bool showBackButton;

  @override
  State<VerifyEmailContent> createState() => _VerifyEmailContentState();
}

class _VerifyEmailContentState extends State<VerifyEmailContent> {
  final _otpKey = GlobalKey<OtpCodeFieldState>();

  String _otpCode = '';

  void _submit() {
    FocusScope.of(context).unfocus();

    final otp = _otpCode.trim();

    if (otp.length != 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter the 4-digit OTP code.'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    context.read<VerifyEmailBloc>().add(VerifyEmailOtpSubmitted(code: otp));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<VerifyEmailBloc, VerifyEmailState>(
      listener: (context, state) {
        if (state.status == VerifyEmailStatus.success) {
          if (widget.type == VerifyEmailType.forgotPassword) {
            Navigator.pushReplacementNamed(
              context,
              Routes.resetPassword,
              arguments: {'email': widget.email, 'otp': _otpCode.trim()},
            );
            return;
          }

          Navigator.pushNamedAndRemoveUntil(
            context,
            Routes.login,
            (route) => false,
          );
        }
      },
      builder: (context, state) {
        final isLoading =
            state.status == VerifyEmailStatus.loading ||
            state.status == VerifyEmailStatus.resendLoading;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (widget.showBackButton)
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: isLoading ? null : () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back_rounded),
                ),
              ),
            const _MenuLoqWordmark(),
            const SizedBox(height: 34),
            const _VerifyIcon(),
            const SizedBox(height: 24),
            Text(
              'Verify your email',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.6,
              ),
            ),
            const SizedBox(height: 10),
            Text.rich(
              TextSpan(
                children: [
                  const TextSpan(text: 'Enter the 4-digit code sent to\n'),
                  TextSpan(
                    text: _maskEmail(state.email),
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.textSecondary,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: isLoading ? null : () => Navigator.pop(context),
              child: const Text('Change email'),
            ),
            const SizedBox(height: 26),
            OtpCodeField(
              key: _otpKey,
              enabled: !isLoading && !state.isExpired,
              onCompleted: (code) {
                _otpCode = code;
              },
            ),
            const SizedBox(height: 12),
            Text(
              'Auto-focus, numbers only, and paste entire code supported.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 24),
            Text.rich(
              TextSpan(
                children: [
                  const TextSpan(text: 'Code expires in '),
                  TextSpan(
                    text: _formatSeconds(state.expiresIn),
                    style: const TextStyle(
                      color: AppColors.accent,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: isLoading || state.isExpired ? null : _submit,
                child: isLoading
                    ? const LoadingButtonContent()
                    : const Text('Verify OTP'),
              ),
            ),
            if (state.status == VerifyEmailStatus.loading) ...[
              const SizedBox(height: 14),
              const _VerifyingBox(),
            ],
            const SizedBox(height: 28),
            Text(
              'Didn’t receive the code?',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 14),
            _ResendSection(
              resendIn: state.resendIn,
              canResend: state.canResend && !isLoading,
              onResend: () {
                _otpCode = '';
                _otpKey.currentState?.clear();

                context.read<VerifyEmailBloc>().add(
                  const VerifyEmailResendRequested(),
                );
              },
            ),
            if (state.message != null) ...[
              const SizedBox(height: 26),
              _StatusMessage(state: state),
            ],
            const SizedBox(height: 28),
            const Divider(),
            const SizedBox(height: 14),

            TextButton.icon(
              onPressed: isLoading
                  ? null
                  : () {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        Routes.login,
                        (route) => false,
                      );
                    },
              icon: const Icon(Icons.arrow_back_rounded),
              label: const Text('Back to sign in'),
            ),
          ],
        );
      },
    );
  }

  static String _formatSeconds(int seconds) {
    final safeSeconds = seconds < 0 ? 0 : seconds;
    final minutes = safeSeconds ~/ 60;
    final remainingSeconds = safeSeconds % 60;

    return '${minutes.toString().padLeft(2, '0')}:'
        '${remainingSeconds.toString().padLeft(2, '0')}';
  }

  static String _maskEmail(String email) {
    if (email.isEmpty || !email.contains('@')) return email;

    final parts = email.split('@');
    final name = parts.first;
    final domain = parts.last;

    if (name.length <= 1) return '*@$domain';

    return '${name[0]}***@$domain';
  }
}

class _ResendSection extends StatelessWidget {
  const _ResendSection({
    required this.resendIn,
    required this.canResend,
    required this.onResend,
  });

  final int resendIn;
  final bool canResend;
  final VoidCallback onResend;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          resendIn > 0 ? 'Resend in ${resendIn}s' : 'Ready to resend',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: resendIn > 0 ? AppColors.textMuted : AppColors.textSecondary,
            fontWeight: FontWeight.w700,
          ),
        ),
        Container(
          height: 28,
          width: 1,
          margin: const EdgeInsets.symmetric(horizontal: 24),
          color: AppColors.border,
        ),
        TextButton(
          onPressed: canResend ? onResend : null,
          child: const Text('Resend code'),
        ),
      ],
    );
  }
}

class _StatusMessage extends StatelessWidget {
  const _StatusMessage({required this.state});

  final VerifyEmailState state;

  @override
  Widget build(BuildContext context) {
    switch (state.status) {
      case VerifyEmailStatus.failure:
        return MessageBox(
          icon: Icons.error_rounded,
          text: state.message ?? 'The OTP code is invalid.',
          backgroundColor: AppColors.dangerLight,
          borderColor: AppColors.danger,
          iconColor: AppColors.danger,
          textColor: AppColors.danger,
        );

      case VerifyEmailStatus.expired:
        return MessageBox(
          icon: Icons.timer_rounded,
          text: state.message ?? 'OTP has expired. Please request a new OTP.',
          backgroundColor: AppColors.warningLight,
          borderColor: AppColors.warning,
          iconColor: AppColors.warning,
          textColor: AppColors.textPrimary,
        );

      case VerifyEmailStatus.success:
        return MessageBox(
          icon: Icons.check_circle_rounded,
          text: state.message ?? 'Email verified successfully.',
          actionText: 'Continue to sign in',
          backgroundColor: AppColors.successLight,
          borderColor: AppColors.success,
          iconColor: AppColors.success,
          textColor: AppColors.textPrimary,
          actionColor: AppColors.accent,
          onActionTap: () {
            // Navigator.pushReplacementNamed(context, Routes.login);
          },
        );

      case VerifyEmailStatus.resendSuccess:
        return MessageBox(
          icon: Icons.check_circle_rounded,
          text: state.message ?? 'A new OTP code has been sent.',
          backgroundColor: AppColors.successLight,
          borderColor: AppColors.success,
          iconColor: AppColors.success,
          textColor: AppColors.textPrimary,
        );

      case VerifyEmailStatus.initial:
      case VerifyEmailStatus.loading:
      case VerifyEmailStatus.resendLoading:
        return const SizedBox.shrink();
    }
  }
}

class _VerifyingBox extends StatelessWidget {
  const _VerifyingBox();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.accentLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.accent),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2.4,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Verifying...',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.accent,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _VerifyIcon extends StatelessWidget {
  const _VerifyIcon();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 86,
        height: 86,
        decoration: BoxDecoration(
          color: AppColors.surface,
          shape: BoxShape.circle,
          boxShadow: const [
            BoxShadow(
              color: AppColors.lightShadow,
              blurRadius: 22,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            const Icon(
              Icons.mark_email_unread_outlined,
              color: AppColors.primary,
              size: 42,
            ),
            Positioned(
              right: 15,
              bottom: 15,
              child: Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  color: AppColors.accent,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: AppColors.white,
                  size: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuLoqWordmark extends StatelessWidget {
  const _MenuLoqWordmark();

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.headlineMedium?.copyWith(
      fontWeight: FontWeight.w900,
      letterSpacing: -0.4,
    );

    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: 'Menu',
            style: style?.copyWith(color: AppColors.primary),
          ),
          TextSpan(
            text: 'Loq',
            style: style?.copyWith(color: AppColors.accent),
          ),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}

class _VerifyBrandPanel extends StatelessWidget {
  const _VerifyBrandPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _PanelWordmark(),
          const Spacer(),
          Text(
            'Secure your\nbusiness account.',
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
              color: AppColors.white,
              fontWeight: FontWeight.w900,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Verify your email address to protect your MenuLoq dashboard and business information.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.white.withAlpha(210),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),
          const _PanelPoint(text: 'Email ownership verification'),
          const SizedBox(height: 12),
          const _PanelPoint(text: 'Secure dashboard access'),
          const SizedBox(height: 12),
          const _PanelPoint(text: 'Safe account recovery'),
        ],
      ),
    );
  }
}

class _PanelWordmark extends StatelessWidget {
  const _PanelWordmark();

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.headlineMedium?.copyWith(
      fontWeight: FontWeight.w900,
      letterSpacing: -0.4,
    );

    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: 'Menu',
            style: style?.copyWith(color: AppColors.white),
          ),
          TextSpan(
            text: 'Loq',
            style: style?.copyWith(color: AppColors.accent),
          ),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}

class _PanelPoint extends StatelessWidget {
  const _PanelPoint({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(
          Icons.check_circle_rounded,
          color: AppColors.accent,
          size: 22,
        ),
        const SizedBox(width: 10),
        Text(
          text,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
