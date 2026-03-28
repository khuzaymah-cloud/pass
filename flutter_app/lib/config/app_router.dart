import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../screens/auth/login_screen.dart';
import '../screens/auth/otp_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/gyms/gym_detail_screen.dart';
import '../screens/plans/plans_screen.dart';
import '../screens/payment/payment_stub_screen.dart';
import '../screens/payment/success_screen.dart';
import '../screens/subscription/my_subscription_screen.dart';
import '../screens/checkin/qr_checkin_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/gym_partner/gym_partner_home_screen.dart';
import '../screens/gym_partner/gym_partner_scan_screen.dart';
import '../providers/auth_provider.dart';
import '../extensions/context_ext.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final isLoggedIn = authState.valueOrNull?.isLoggedIn ?? false;
      final isAuthRoute = state.matchedLocation.startsWith('/auth');
      final isPartnerRoute = state.matchedLocation.startsWith('/partner');
      final user = authState.valueOrNull?.user;
      final isGymPartner = user?.role == 'gym_partner';

      if (!isLoggedIn && !isAuthRoute) return '/auth/login';
      if (isLoggedIn && isAuthRoute) {
        return isGymPartner ? '/partner' : '/';
      }
      if (isLoggedIn && isGymPartner && !isPartnerRoute) return '/partner';
      if (isLoggedIn && !isGymPartner && isPartnerRoute) return '/';
      return null;
    },
    routes: [
      // ─── Auth ───
      GoRoute(path: '/auth/login', builder: (_, __) => const LoginScreen()),
      GoRoute(
        path: '/auth/otp',
        builder: (_, state) =>
            OtpScreen(phone: state.uri.queryParameters['phone'] ?? ''),
      ),
      GoRoute(
          path: '/auth/register', builder: (_, __) => const RegisterScreen()),

      // ─── Gym Partner shell ───
      ShellRoute(
        builder: (_, __, child) => _PartnerShell(child: child),
        routes: [
          GoRoute(
              path: '/partner',
              builder: (_, __) => const GymPartnerHomeScreen()),
          GoRoute(
              path: '/partner/scan',
              builder: (_, __) => const GymPartnerScanScreen()),
        ],
      ),

      // ─── Member shell (3 tabs: Home, QR Scan, Account) ───
      ShellRoute(
        builder: (_, __, child) => _MainShell(child: child),
        routes: [
          GoRoute(path: '/', builder: (_, __) => const HomeScreen()),
          GoRoute(
              path: '/checkin', builder: (_, __) => const QrCheckinScreen()),
          GoRoute(path: '/account', builder: (_, __) => const ProfileScreen()),
          // Sub-pages (no tab)
          GoRoute(path: '/plans', builder: (_, __) => const PlansScreen()),
          // Sub-pages accessible from tabs
          GoRoute(
            path: '/gyms/:id',
            builder: (_, state) =>
                GymDetailScreen(gymId: state.pathParameters['id']!),
          ),
          GoRoute(
            path: '/payment-stub',
            builder: (_, state) => PaymentStubScreen(
              subscriptionId: state.uri.queryParameters['sub_id'] ?? '',
            ),
          ),
          GoRoute(path: '/success', builder: (_, __) => const SuccessScreen()),
          GoRoute(
              path: '/subscription',
              builder: (_, __) => const MySubscriptionScreen()),
          GoRoute(
              path: '/settings', builder: (_, __) => const SettingsScreen()),
        ],
      ),
    ],
  );
});

// ─── Member Shell ───

class _MainShell extends StatelessWidget {
  final Widget child;
  const _MainShell({required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: const _BottomNav(),
    );
  }
}

class _BottomNav extends StatelessWidget {
  const _BottomNav();

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final index = switch (location) {
      '/' => 0,
      '/checkin' => 1,
      _
          when location.startsWith('/account') ||
              location.startsWith('/settings') =>
        2,
      _ => 0,
    };

    return BottomNavigationBar(
      currentIndex: index,
      onTap: (i) {
        final routes = ['/', '/checkin', '/account'];
        context.go(routes[i]);
      },
      items: [
        BottomNavigationBarItem(
            icon: const Icon(Icons.home_rounded), label: context.l10n.home),
        BottomNavigationBarItem(
            icon: const Icon(Icons.qr_code_scanner_rounded),
            label: context.l10n.checkIn),
        BottomNavigationBarItem(
            icon: const Icon(Icons.person_rounded),
            label: context.l10n.profile),
      ],
    );
  }
}

// ─── Partner Shell ───

class _PartnerShell extends StatelessWidget {
  final Widget child;
  const _PartnerShell({required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: _PartnerBottomNav(),
    );
  }
}

class _PartnerBottomNav extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final index = location == '/partner/scan' ? 1 : 0;
    final l = context.l10n;

    return BottomNavigationBar(
      currentIndex: index,
      type: BottomNavigationBarType.fixed,
      onTap: (i) {
        final routes = ['/partner', '/partner/scan'];
        context.go(routes[i]);
      },
      items: [
        BottomNavigationBarItem(
            icon: const Icon(Icons.dashboard_rounded), label: l.partnerHome),
        BottomNavigationBarItem(
            icon: const Icon(Icons.qr_code_2_rounded), label: l.partnerQr),
      ],
    );
  }
}
