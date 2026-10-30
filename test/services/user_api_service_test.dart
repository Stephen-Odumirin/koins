import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:savings_app/core/errors/app_exception.dart';
import 'package:savings_app/services/user_api_service.dart';

const _userJson =
    '{"firstName":"Emily","lastName":"Johnson","email":"e@x.com","phone":"+1 555"}';

void main() {
  test('parses dummyjson user into UserProfile', () async {
    final api = UserApiService(
      client: MockClient((_) async => http.Response(_userJson, 200)),
    );

    final user = await api.fetchUser(1);

    expect(user.fullName, 'Emily Johnson');
    expect(user.email, 'e@x.com');
  });

  test('non-200 throws AppException with status', () async {
    final api = UserApiService(
      client: MockClient((_) async => http.Response('', 500)),
    );

    await expectLater(
      api.fetchUser(1),
      throwsA(
        isA<AppException>().having(
          (e) => (e.code, e.statusCode),
          'code and status',
          (AppExceptionCode.serverError, 500),
        ),
      ),
    );
  });

  test('malformed body throws AppException', () async {
    final api = UserApiService(
      client: MockClient((_) async => http.Response('nope', 200)),
    );

    await expectLater(
      api.fetchUser(1),
      throwsA(isA<AppException>()),
    ); // Review Focus 5
  });

  test('no connection throws AppException', () async {
    final api = UserApiService(
      client: MockClient((_) async => throw const SocketException('offline')),
    );

    await expectLater(
      api.fetchUser(1),
      throwsA(
        isA<AppException>().having(
          (e) => e.code,
          'code',
          AppExceptionCode.noInternet,
        ),
      ),
    );
  });

  test('slow response times out with AppException', () async {
    final api = UserApiService(
      client: MockClient((_) => Completer<http.Response>().future),
      timeout: const Duration(milliseconds: 10),
    );

    await expectLater(
      api.fetchUser(1),
      throwsA(isA<AppException>()),
    ); // Review Focus 5
  });
}
