import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/gym.dart';
import '../services/gym_service.dart';

// Use a simple string key for proper equality: "tier:search"
final gymListProvider = FutureProvider.family<List<Gym>, String>(
  (ref, key) async {
    final service = GymService();
    final parts = key.split('|');
    final tier = parts.isNotEmpty && parts[0].isNotEmpty ? parts[0] : null;
    final search = parts.length > 1 && parts[1].isNotEmpty ? parts[1] : null;
    return service.listGyms(tier: tier, search: search);
  },
);

final gymDetailProvider = FutureProvider.family<Gym, String>((ref, id) async {
  return GymService().getGym(id);
});

final featuredGymsProvider = FutureProvider<List<Gym>>((ref) async {
  return GymService().listGyms(featured: true, limit: 10);
});
