import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/app_colors.dart';
import '../../config/app_spacing.dart';
import '../../extensions/context_ext.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/language_switcher.dart';
import '../../widgets/theme_switcher.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.settings)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Language
            Text(
              context.l10n.language,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            GlassCard(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    context.l10n.language,
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                  const LanguageSwitcher(),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            // Theme
            Text(
              context.l10n.theme,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            const GlassCard(child: Center(child: ThemeSwitcher())),
            const SizedBox(height: AppSpacing.lg),
            // Version
            Center(
              child: Text(
                '${context.l10n.version} 1.0.0',
                style: const TextStyle(color: AppColors.textHint, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
