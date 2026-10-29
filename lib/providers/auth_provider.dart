import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers.dart';

/// null = logged out, otherwise the logged-in email
class AuthNotifier extends Notifier<String?> {
  @override
  String? build() => ref.watch(authRepositoryProvider).currentUserEmail;

  Future<void> login(String email, String password) async {
    await ref.read(authRepositoryProvider).login(email, password);
    state = email.trim().toLowerCase();
  }

  Future<void> logout() async {
    await ref.read(authRepositoryProvider).logout();
    state = null;
  }
}

final authProvider = NotifierProvider<AuthNotifier, String?>(AuthNotifier.new);
