import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../screens/auth/login_screen.dart';
import '../screens/auth/otp_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/gyms/gym_map_screen.dart';
import '../screens/gyms/gym_detail_screen.dart';
import '../screens/plans/plans_screen.dart';
import '../screens/payment/payment_stub_screen.dart';
import '../screens/payment/success_screen.dart';
import '../screens/subscription/my_subscription_screen.dart';
import '../screens/checkin/qr_checkin_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../providers/auth_provider.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final isLoggedIn = authState.valueOrNull?.isLoggedIn ?? false;
      final isAuthRoute = state.matchedLocation.startsWith('/auth');

      if (!isLoggedIn && !isAuthRoute) return '/auth/login';
      if (isLoggedIn && isAuthRoute) return '/';
      return null;
    },
    routes: [
      // ─── Auth ───
      GoRoute(path: '/auth/login', builder: (_, __) => const LoginScreen()),
      GoRoute(
        path: '/auth/otp',
        builder: (_, state) => OtpScreen(phone: state.uri.queryParameters['phone'] ?? ''),
      ),
      GoRoute(path: '/auth/register', builder: (_, __) => const RegisterScreen()),

      // ─── Main shell ───
      ShellRoute(
        builder: (_, __, child) => _MainShell(child: child),
        routes: [
          GoRoute(path: '/', builder: (_, __) => const HomeScreen()),
          GoRoute(path: '/gyms', builder: (_, __) => const GymMapScreen()),
          GoRoute(
            path: '/gyms/:id',
            builder: (_, state) => GymDetailScreen(gymId: state.pathParameters['id']!),
          ),
          GoRoute(path: '/plans', builder: (_, __) => const PlansScreen()),
          GoRoute(
            path: '/payment-stub',
            builder: (_, state) => PaymentStubScreen(
              subscriptionId: state.uri.queryParameters['sub_id'] ?? '',
            ),
          ),
          GoRoute(path: '/success', builder: (_, __) => const SuccessScreen()),
          GoRoute(path: '/subscription', builder: (_, __) => const MySubscriptionScreen()),
          GoRoute(path: '/checkin', builder: (_, __) => const QrCheckinScreen()),
          GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
          GoRoute(path: '/settings', builder: (_, __) => const SettingsScreen()),
        ],
      ),
    ],
  );
});

class _MainShell extends StatelessWidget {
  final Widget child;
  const _MainShell({required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: _BottomNav(),
    );
  }
}

class _BottomNav extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final index = switch (location) {
      '/' => 0,
      _ when location.startsWith('/gyms') => 1,
      '/checkin' => 2,
      _ when location.startsWith('/subscription') || location.startsWith('/plans') => 3,
      _ when location.startsWith('/profile') || location.startsWith('/settings') => 4,
      _ => 0,
    };

    return BottomNavigationBar(
      currentIndex: index,
      type: BottomNavigationBarType.fixed,
      onTap: (i) {
        final routes = ['/', '/gyms', '/checkin', '/subscription', '/profile'];
        context.go(routes[i]);
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.map_rounded), label: 'Gyms'),
        BottomNavigationBarItem(icon: Icon(Icons.qr_code_scanner_rounded), label: 'Check In'),
        BottomNavigationBarItem(icon: Icon(Icons.card_membership_rounded), label: 'Plan'),
        BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Profile'),
      ],
    );
  }
}
