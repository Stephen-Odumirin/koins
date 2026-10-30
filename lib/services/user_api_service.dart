import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../core/constants/app_constants.dart';
import '../core/errors/app_exception.dart';
import '../models/user_profile.dart';

class UserApiService {
  UserApiService({
    http.Client? client,
    this.timeout = const Duration(seconds: 10),
  }) : _client = client ?? http.Client();

  final http.Client _client;
  final Duration timeout;

  Future<UserProfile> fetchUser(int id) async {
    try {
      final res = await _client
          .get(Uri.parse('${AppConstants.userApiBase}/users/$id'))
          .timeout(timeout);

      if (res.statusCode != 200) {
        throw AppException(
          AppExceptionCode.serverError,
          statusCode: res.statusCode,
        );
      }
      return UserProfile.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
    } on SocketException {
      throw const AppException(AppExceptionCode.noInternet);
    } on TimeoutException {
      throw const AppException(AppExceptionCode.timeout);
    } on FormatException {
      throw const AppException(AppExceptionCode.badResponse);
    } on TypeError {
      // Valid JSON with unexpected shape (e.g. a missing or non-string field)
      throw const AppException(AppExceptionCode.badResponse);
    }
  }
}
