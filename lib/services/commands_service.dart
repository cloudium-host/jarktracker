import 'package:dio/dio.dart';
import 'api_client.dart';

class DeviceCommandResult {
  DeviceCommandResult({required this.ok, required this.message});
  final bool ok;
  final String message;
}

class CommandsService {
  Future<DeviceCommandResult> send({
    required int deviceId,
    required String type,
  }) async {
    try {
      final res = await ApiClient.instance.post(
        '/device/$deviceId/command',
        data: {'type': type},
      );
      final data = res.data as Map<String, dynamic>;
      final status = data['status'];
      final ok = status == 1 || status == '1';
      String msg = (data['message'] as String?) ?? '';
      // Pull nested per-device error if present
      if (ok && data['result'] is List && (data['result'] as List).isNotEmpty) {
        final first = (data['result'] as List).first;
        if (first is Map && first['status'] == 0 && first['error'] is String) {
          return DeviceCommandResult(ok: false, message: first['error'] as String);
        }
      }
      return DeviceCommandResult(ok: ok, message: msg.isEmpty ? 'OK' : msg);
    } on DioException catch (e) {
      final body = e.response?.data;
      String msg = 'Error';
      if (body is Map && body['message'] is String) msg = body['message'] as String;
      return DeviceCommandResult(ok: false, message: msg);
    } catch (e) {
      return DeviceCommandResult(ok: false, message: e.toString());
    }
  }
}
