import '../models/gym.dart';
import 'api_client.dart';

class GymService {
  final _api = ApiClient();

  Future<List<Gym>> listGyms({
    String? tier,
    bool? featured,
    String? search,
    int limit = 50,
    int offset = 0,
  }) async {
    final params = <String, dynamic>{
      'limit': limit,
      'offset': offset,
      if (tier != null) 'tier': tier,
      if (featured != null) 'featured': featured,
      if (search != null) 'search': search,
    };
    final res = await _api.dio.get('/gyms', queryParameters: params);
    return (res.data as List).map((e) => Gym.fromJson(e)).toList();
  }

  Future<Gym> getGym(String id) async {
    final res = await _api.dio.get('/gyms/$id');
    return Gym.fromJson(res.data);
  }

  Future<Map<String, int>> getNetworkCounts() async {
    final res = await _api.dio.get('/gyms/network-counts');
    return (res.data as Map<String, dynamic>)
        .map((k, v) => MapEntry(k, (v as num).toInt()));
  }

  Future<List<Gym>> getNetworkGyms(String planTier) async {
    final res = await _api.dio.get('/gyms/network/$planTier');
    return (res.data as List).map((e) => Gym.fromJson(e)).toList();
  }
}
