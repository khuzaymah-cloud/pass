import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../config/app_colors.dart';
import '../../extensions/context_ext.dart';
import '../../providers/auth_provider.dart';
import '../../providers/subscription_provider.dart';

const _kBlue = AppColors.accent;

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final activeSub = ref.watch(activeSubscriptionProvider);
    final user = authState.valueOrNull?.user;

    final planName = activeSub.valueOrNull?.isActive == true ? context.l10n.subscribed : context.l10n.noPlan;
    final visitsRemaining = activeSub.valueOrNull?.visitsRemaining ?? 0;

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // ─── Header area ───
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _kBlue.withValues(alpha: 0.12),
                      AppColors.bgPrimary
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                  child: Column(
                    children: [
                      // Top bar
                      const Align(
                        alignment: AlignmentDirectional.centerEnd,
                        child: Icon(Icons.notifications_outlined,
                            color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 8),
                      // Avatar
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          color: _kBlue.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: _kBlue.withValues(alpha: 0.3), width: 2),
                        ),
                        child: Center(
                          child: Text(
                            (user?.fullName ?? context.l10n.defaultInitial)
                                .substring(0, 1)
                                .toUpperCase(),
                            style: const TextStyle(
                                color: _kBlue,
                                fontSize: 40,
                                fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        user?.fullName ?? '',
                        style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 20,
                            fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user?.phone ?? '',
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 13),
                      ),
                      const SizedBox(height: 20),
                      // Plan + Credits cards
                      Row(
                        children: [
                          Expanded(
                            child: _InfoCard(
                              icon: Icons.fitness_center_rounded,
                              label: context.l10n.planLabel,
                              value: planName,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _InfoCard(
                              icon: Icons.confirmation_number_rounded,
                              label: context.l10n.visitsRemainingLabel,
                              value: '$visitsRemaining',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // ─── Menu items ───
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    _MenuTile(
                      icon: Icons.card_membership_rounded,
                      label: context.l10n.myPlan,
                      onTap: () => context.push('/subscription'),
                    ),
                    _MenuTile(
                      icon: Icons.tune_rounded,
                      label: context.l10n.preferences,
                      subtitle: context.l10n.locationAmmanJordan,
                      onTap: () {},
                    ),
                    _MenuTile(
                      icon: Icons.help_outline_rounded,
                      label: context.l10n.helpCenter,
                      onTap: () {},
                    ),
                    _MenuTile(
                      icon: Icons.settings_rounded,
                      label: context.l10n.settings,
                      onTap: () => context.push('/settings'),
                    ),
                    const SizedBox(height: 8),
                    _MenuTile(
                      icon: Icons.logout_rounded,
                      label: context.l10n.logout,
                      isDestructive: true,
                      onTap: () async {
                        await ref.read(authStateProvider.notifier).logout();
                        if (context.mounted) context.go('/auth/login');
                      },
                    ),
                    const SizedBox(height: 24),
                    Text(
                      '${context.l10n.version} 1.0.0',
                      style: const TextStyle(
                          color: AppColors.textHint, fontSize: 12),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Info Card (Plan / Credits) ───

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoCard(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.bgElevated),
      ),
      child: Row(
        children: [
          Icon(icon, color: _kBlue, size: 24),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 11)),
                Text(value,
                    style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Menu Tile ───

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final VoidCallback onTap;
  final bool isDestructive;

  const _MenuTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.subtitle,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? AppColors.error : AppColors.textPrimary;
    final iconColor = isDestructive ? AppColors.error : AppColors.textSecondary;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: const BoxDecoration(
          border: Border(
              bottom: BorderSide(color: AppColors.bgElevated, width: 0.5)),
        ),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: TextStyle(
                          color: color,
                          fontSize: 15,
                          fontWeight: FontWeight.w500)),
                  if (subtitle != null)
                    Text(subtitle!,
                        style: const TextStyle(
                            color: AppColors.textHint, fontSize: 12)),
                ],
              ),
            ),
            if (!isDestructive)
              const Icon(Icons.chevron_right_rounded,
                  color: AppColors.textHint, size: 20),
          ],
        ),
      ),
    );
  }
}
