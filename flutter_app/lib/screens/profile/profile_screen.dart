import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../config/app_colors.dart';
import '../../config/app_spacing.dart';
import '../../extensions/context_ext.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/glass_card.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final user = authState.valueOrNull?.user;

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.profile)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            // Avatar
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.neonGlow,
              ),
              child: Center(
                child: Text(
                  (user?.fullName ?? 'U').substring(0, 1).toUpperCase(),
                  style: const TextStyle(
                    color: AppColors.neonPrimary,
                    fontSize: 36,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              user?.fullName ?? '',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              user?.phone ?? '',
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            if (user?.createdAt != null) ...[
              const SizedBox(height: 4),
              Text(
                context.l10n.memberSince(user!.createdAt.substring(0, 10)),
                style: const TextStyle(color: AppColors.textHint, fontSize: 12),
              ),
            ],
            const SizedBox(height: AppSpacing.xl),
            // Menu items
            _ProfileTile(
              icon: Icons.edit_rounded,
              label: context.l10n.editProfile,
              onTap: () {},
            ),
            _ProfileTile(
              icon: Icons.card_membership_rounded,
              label: context.l10n.mySubscriptionMenu,
              onTap: () => context.go('/subscription'),
            ),
            _ProfileTile(
              icon: Icons.settings_rounded,
              label: context.l10n.settings,
              onTap: () => context.go('/settings'),
            ),
            _ProfileTile(
              icon: Icons.help_outline_rounded,
              label: context.l10n.help,
              onTap: () {},
            ),
            const SizedBox(height: AppSpacing.lg),
            _ProfileTile(
              icon: Icons.logout_rounded,
              label: context.l10n.logout,
              isDestructive: true,
              onTap: () async {
                await ref.read(authStateProvider.notifier).logout();
                if (context.mounted) context.go('/auth/login');
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  const _ProfileTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(bottom: AppSpacing.sm),
      child: GlassCard(
        padding: EdgeInsets.zero,
        child: ListTile(
          leading: Icon(
            icon,
            color: isDestructive ? AppColors.error : AppColors.neonPrimary,
          ),
          title: Text(
            label,
            style: TextStyle(
              color: isDestructive ? AppColors.error : AppColors.textPrimary,
            ),
          ),
          trailing: const Icon(
            Icons.chevron_right_rounded,
            color: AppColors.textHint,
          ),
          onTap: onTap,
        ),
      ),
    );
  }
}
