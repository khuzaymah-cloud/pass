import '../models/checkin.dart';
import 'api_client.dart';

class CheckinService {
  final _api = ApiClient();

  Future<Checkin> checkin(String gymId) async {
    final res = await _api.dio.post('/checkins', data: {'gym_id': gymId});
    return Checkin.fromJson(res.data);
  }

  Future<List<Checkin>> list({int limit = 50, int offset = 0}) async {
    final res = await _api.dio.get(
      '/checkins',
      queryParameters: {'limit': limit, 'offset': offset},
    );
    return (res.data as List).map((e) => Checkin.fromJson(e)).toList();
  }
}
