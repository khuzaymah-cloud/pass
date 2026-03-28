import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/plan.dart';
import '../services/plan_service.dart';
import '../services/gym_service.dart';

final selectedDurationProvider = StateProvider<int>((ref) => 1);

final planListProvider = FutureProvider.family<List<Plan>, int>((ref, duration) async {
  return PlanService().listPlans(duration: duration);
});

final filteredPlanListProvider = FutureProvider<List<Plan>>((ref) async {
  final duration = ref.watch(selectedDurationProvider);
  return ref.watch(planListProvider(duration).future);
});

final allPlansProvider = FutureProvider<List<Plan>>((ref) async {
  return PlanService().listAllPlans();
});

final gymCountsProvider = FutureProvider<Map<String, int>>((ref) async {
  return GymService().getNetworkCounts();
});
