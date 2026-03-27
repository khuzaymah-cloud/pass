import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/plan.dart';
import '../services/plan_service.dart';

final planListProvider = FutureProvider<List<Plan>>((ref) async {
  return PlanService().listPlans();
});
