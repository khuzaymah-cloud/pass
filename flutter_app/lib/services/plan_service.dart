import '../models/plan.dart';
import 'api_client.dart';

class PlanService {
  final _api = ApiClient();

  Future<List<Plan>> listPlans({int? duration}) async {
    final params = <String, dynamic>{};
    if (duration != null) params['duration'] = duration;
    final res = await _api.dio.get('/plans', queryParameters: params);
    return (res.data as List).map((e) => Plan.fromJson(e)).toList();
  }

  Future<List<Plan>> listAllPlans() async {
    final res = await _api.dio.get('/plans');
    return (res.data as List).map((e) => Plan.fromJson(e)).toList();
  }

  Future<Plan> getPlan(String id) async {
    final res = await _api.dio.get('/plans/$id');
    return Plan.fromJson(res.data);
  }
}
