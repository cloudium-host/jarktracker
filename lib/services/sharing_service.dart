import '../models/sharing.dart';
import 'api_client.dart';

class SharingService {
  Future<Sharing> create({
    required int deviceId,
    int? expirationMinutes,
  }) async {
    final body = <String, dynamic>{'device_id': deviceId};
    if (expirationMinutes != null) {
      body['expiration_minutes'] = expirationMinutes;
    }
    final res = await ApiClient.instance.post('/sharing', data: body);
    final data = (res.data as Map<String, dynamic>)['data'] as Map<String, dynamic>;
    return Sharing.fromJson(data);
  }

  Future<List<Sharing>> list() async {
    final res = await ApiClient.instance.get('/sharing');
    final items = (res.data as Map<String, dynamic>)['data'] as List<dynamic>;
    return items
        .cast<Map<String, dynamic>>()
        .map(Sharing.fromJson)
        .toList();
  }

  Future<void> remove(int id) async {
    await ApiClient.instance.dio.delete('/sharing/$id');
  }
}
