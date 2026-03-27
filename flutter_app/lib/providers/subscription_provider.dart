import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/subscription.dart';
import '../services/subscription_service.dart';

final activeSubscriptionProvider = FutureProvider<Subscription?>((ref) async {
  return SubscriptionService().getActive();
});

final subscriptionListProvider = FutureProvider<List<Subscription>>((
  ref,
) async {
  return SubscriptionService().list();
});
