import '../models/event.dart';
import 'api_client.dart';

class EventsService {
  Future<List<AppEvent>> list({int page = 1}) async {
    final res = await ApiClient.instance.get('/events', query: {'page': page});
    final data = res.data as Map<String, dynamic>;
    return (data['data'] as List<dynamic>? ?? [])
        .cast<Map<String, dynamic>>()
        .map(AppEvent.fromJson)
        .toList();
  }
}
