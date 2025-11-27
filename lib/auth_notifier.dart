import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppUser {
  final String email;
  final String username;

  const AppUser({
    required this.email,
    required this.username,
  });

  factory AppUser.fromEmail(String email) {
    return AppUser(email: email, username: email);
  }

  AppUser copyWith({
    String? email,
    String? username,
  }) {
    return AppUser(
      email: email ?? this.email,
      username: username ?? this.username,
    );
  }
}

class AuthNotifier extends Notifier<AppUser?> {
  @override
  AppUser? build() => null; // non loggato

  bool get isLoggedIn => state != null;

  void login(String email) {
    state = AppUser.fromEmail(email);
  }

  void logout() {
    state = null;
  }

  void updateUsername(String newUsername) {
    if (state == null) return;
    state = state!.copyWith(username: newUsername);
  }

  void updateEmail(String newEmail) {
    if (state == null) return;
    state = state!.copyWith(email: newEmail);
  }
}

final authProvider =
    NotifierProvider<AuthNotifier, AppUser?>(AuthNotifier.new);
