// ignore_for_file: prefer_const_constructors

import 'package:authentication_repository/authentication_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('User', () {
    const uid = 'mock-uid';
    const email = 'mock-email';

    test('uses value equality', () {
      expect(
        User(email: email, uid: uid),
        equals(User(email: email, uid: uid)),
      );
    });

    test('isEmpty returns true for empty user', () {
      expect(User.empty.isEmpty, isTrue);
    });

    test('isEmpty returns false for non-empty user', () {
      final user = User(email: email, uid: uid);
      expect(user.isEmpty, isFalse);
    });

    test('isNotEmpty returns false for empty user', () {
      expect(User.empty.isNotEmpty, isFalse);
    });

    test('isNotEmpty returns true for non-empty user', () {
      final user = User(email: email, uid: uid);
      expect(user.isNotEmpty, isTrue);
    });
  });
}
