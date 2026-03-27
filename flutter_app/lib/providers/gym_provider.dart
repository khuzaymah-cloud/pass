import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/gym.dart';
import '../services/gym_service.dart';

final gymListProvider = FutureProvider.family<List<Gym>, Map<String, dynamic>?>(
  (ref, params) async {
    final service = GymService();
    return service.listGyms(
      tier: params?['tier'] as String?,
      featured: params?['featured'] as bool?,
      search: params?['search'] as String?,
    );
  },
);

final gymDetailProvider = FutureProvider.family<Gym, String>((ref, id) async {
  return GymService().getGym(id);
});

final featuredGymsProvider = FutureProvider<List<Gym>>((ref) async {
  return GymService().listGyms(featured: true, limit: 10);
});
