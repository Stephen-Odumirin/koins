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
        throw AppException('Server error (${res.statusCode})');
      }
      return UserProfile.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
    } on SocketException {
      throw const AppException('No internet connection');
    } on TimeoutException {
      throw const AppException('Request timed out. Please try again.');
    } on FormatException {
      throw const AppException('Unexpected response from server');
    } on TypeError {
      // Valid JSON with unexpected shape (e.g. a missing or non-string field)
      throw const AppException('Unexpected response from server');
    }
  }
}
