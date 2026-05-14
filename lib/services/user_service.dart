import 'dart:io';
import 'package:dio/dio.dart';
import '../models/user.dart';
import 'api_client.dart';

class UserService {
  Future<AppUser> get() async {
    final res = await ApiClient.instance.get('/user');
    return AppUser.fromJson(res.data as Map<String, dynamic>);
  }

  Future<AppUser> updatePhone(String phoneNumber) async {
    final res = await ApiClient.instance.post(
      '/user/profile',
      data: {'phone_number': phoneNumber},
    );
    return AppUser.fromJson(res.data as Map<String, dynamic>);
  }

  Future<void> updatePassword({
    required String current,
    required String next,
  }) async {
    await ApiClient.instance.post(
      '/user/password',
      data: {
        'current_password': current,
        'new_password': next,
        'new_password_confirmation': next,
      },
    );
  }

  Future<AppUser> uploadAvatar(File file) async {
    final form = FormData.fromMap({
      'avatar': await MultipartFile.fromFile(
        file.path,
        filename: file.path.split('/').last,
      ),
    });
    final res = await ApiClient.instance.dio.post(
      '/user/avatar',
      data: form,
      options: Options(contentType: 'multipart/form-data'),
    );
    return AppUser.fromJson(res.data as Map<String, dynamic>);
  }
}
