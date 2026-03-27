import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../config/app_colors.dart';
import '../../config/app_spacing.dart';
import '../../extensions/context_ext.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/language_switcher.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _phoneController = TextEditingController();
  bool _isLoading = false;
  String? _phoneError;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  bool _isValidPhone(String input) {
    final digits = input.replaceAll(RegExp(r'\D'), '');
    return digits.length == 9;
  }

  Future<void> _sendOtp() async {
    final input = _phoneController.text.trim();
    if (input.isEmpty) {
      setState(() => _phoneError = 'Please enter your phone number');
      return;
    }
    if (!_isValidPhone(input)) {
      setState(() => _phoneError = 'Enter exactly 9 digits (e.g. 791234567)');
      return;
    }
    setState(() {
      _phoneError = null;
      _isLoading = true;
    });
    final digits = input.replaceAll(RegExp(r'\D'), '');
    final phone = '+962$digits';
    try {
      await ref.read(authStateProvider.notifier).sendOtp(phone);
      if (mounted) context.go('/auth/otp?phone=$phone');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              // Top bar
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: LanguageSwitcher(),
              ),
              const Spacer(),
              // Logo area with neon glow
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [AppColors.neonGlow, Colors.transparent],
                    radius: 1.5,
                  ),
                ),
                child: Center(
                  child: Text(
                    'GP',
                    style: TextStyle(
                      color: AppColors.neonPrimary,
                      fontSize: 48,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                context.l10n.appName,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                context.l10n.tagline,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 16,
                ),
              ),
              const Spacer(),
              // Phone input
              GlassCard(
                child: TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  maxLength: 9,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(9),
                  ],
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                  ),
                  textDirection: TextDirection.ltr,
                  onChanged: (_) {
                    if (_phoneError != null) setState(() => _phoneError = null);
                  },
                  onSubmitted: (_) => _sendOtp(),
                  decoration: InputDecoration(
                    hintText: '7XXXXXXXX',
                    hintStyle: const TextStyle(color: AppColors.textHint),
                    counterText: '',
                    prefixIcon: const Padding(
                      padding: EdgeInsetsDirectional.only(start: 12, end: 8),
                      child: Text(
                        '+962',
                        style: TextStyle(
                          color: AppColors.neonPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    prefixIconConstraints: const BoxConstraints(
                      minWidth: 0,
                      minHeight: 0,
                    ),
                    border: InputBorder.none,
                    errorText: _phoneError,
                    errorStyle: const TextStyle(color: AppColors.error, fontSize: 12),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              PrimaryButton(
                label: context.l10n.sendOtp,
                onPressed: _sendOtp,
                isLoading: _isLoading,
              ),
              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }
}
