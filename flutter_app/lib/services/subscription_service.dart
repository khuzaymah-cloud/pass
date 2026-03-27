import '../models/subscription.dart';
import 'api_client.dart';

class SubscriptionService {
  final _api = ApiClient();

  Future<Subscription> create(String planId) async {
    final res = await _api.dio.post(
      '/subscriptions',
      data: {'plan_id': planId},
    );
    return Subscription.fromJson(res.data);
  }

  Future<Subscription?> getActive() async {
    try {
      final res = await _api.dio.get('/subscriptions/active');
      return Subscription.fromJson(res.data);
    } catch (_) {
      return null;
    }
  }

  Future<List<Subscription>> list() async {
    final res = await _api.dio.get('/subscriptions');
    return (res.data as List).map((e) => Subscription.fromJson(e)).toList();
  }

  Future<Map<String, dynamic>> initiatePayment(String subscriptionId) async {
    final res = await _api.dio.post(
      '/payments/initiate',
      data: {'subscription_id': subscriptionId},
    );
    return res.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> simulatePayment(String gatewayRef) async {
    final res = await _api.dio.post(
      '/payments/webhook/placeholder',
      data: {'gateway_ref': gatewayRef},
    );
    return res.data as Map<String, dynamic>;
  }
}
