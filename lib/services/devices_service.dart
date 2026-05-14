import '../models/device.dart';
import '../models/device_map_item.dart';
import 'api_client.dart';

class DevicesService {
  Future<List<Device>> list() async {
    final res = await ApiClient.instance.get('/devices');
    final data = res.data as Map<String, dynamic>;
    final items = (data['data'] as List<dynamic>? ?? [])
        .cast<Map<String, dynamic>>()
        .map(Device.fromJson)
        .toList();
    return items;
  }

  Future<List<DeviceMapItem>> map() async {
    final res = await ApiClient.instance.get('/devices/map');
    final data = res.data as Map<String, dynamic>;
    return (data['data'] as List<dynamic>? ?? [])
        .cast<Map<String, dynamic>>()
        .map(DeviceMapItem.fromJson)
        .toList();
  }
}
