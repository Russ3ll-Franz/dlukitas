// ignore_for_file: must_be_immutable
import 'package:authentication_repository/authentication_repository.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:firebase_auth_platform_interface/firebase_auth_platform_interface.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

const _mockFirebaseUserUid = 'mock-uid';
const _mockFirebaseUserEmail = 'mock-email';

class MockFirebaseAuth extends Mock implements firebase_auth.FirebaseAuth {}

class MockFirebaseUser extends Mock implements firebase_auth.User {}

class MockUserCredential extends Mock implements firebase_auth.UserCredential {}

class FakeAuthCredential extends Fake implements firebase_auth.AuthCredential {}

class FakeAuthProvider extends Fake implements AuthProvider {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  MethodChannelFirebase.channel.setMockMethodCallHandler((call) async {
    if (call.method == 'Firebase#initializeCore') {
      return [
        {
          'name': defaultFirebaseAppName,
          'options': {
            'apiKey': '123',
            'appId': '123',
            'messagingSenderId': '123',
            'projectId': '123',
          },
          'pluginConstants': const <String, String>{},
        }
      ];
    }

    if (call.method == 'Firebase#initializeApp') {
      final arguments = call.arguments as Map<String, dynamic>;
      return <String, dynamic>{
        'name': arguments['appName'],
        'options': arguments['options'],
        'pluginConstants': const <String, String>{},
      };
    }

    return null;
  });

  TestWidgetsFlutterBinding.ensureInitialized();
  Firebase.initializeApp();

  const email = 'test@gmail.com';
  const password = 't0ps3cret42';
  const user = User(
    uid: _mockFirebaseUserUid,
    email: _mockFirebaseUserEmail,
  );

  group('AuthenticationRepository', () {
    late firebase_auth.FirebaseAuth firebaseAuth;
    late AuthenticationRepository authenticationRepository;

    setUpAll(() {
      registerFallbackValue(FakeAuthCredential());
      registerFallbackValue(FakeAuthProvider());
    });

    setUp(() {
      firebaseAuth = MockFirebaseAuth();
      authenticationRepository = AuthenticationRepository(
        firebaseAuth: firebaseAuth,
      );
    });

    test('creates FirebaseAuth instance internally when not injected', () {
      expect(AuthenticationRepository.new, isNot(throwsException));
    });

    group('signUp', () {
      setUp(
        () {
          when(
            () => firebaseAuth.createUserWithEmailAndPassword(
              email: any(named: 'email'),
              password: any(named: 'password'),
            ),
          ).thenAnswer((_) => Future.value(MockUserCredential()));
        },
      );

      test('calls createUserWithEmailAndPassword', () async {
        await authenticationRepository.signUp(email: email, password: password);
        verify(
          () => firebaseAuth.createUserWithEmailAndPassword(
            email: email,
            password: password,
          ),
        ).called(1);
      });

      test('succeeds when createUserWithEmailAndPassword succeeds', () async {
        expect(
          authenticationRepository.signUp(email: email, password: password),
          completes,
        );
      });

      test(
        'throws SignUpWithEmailAndPasswordFailure when '
        'createUserWithEmailAndPassword throws a FirebaseAuthException',
        () async {
          when(
            () => firebaseAuth.createUserWithEmailAndPassword(
              email: any(named: 'email'),
              password: any(named: 'password'),
            ),
          ).thenThrow(firebase_auth.FirebaseAuthException(code: 'code'));
          expect(
            authenticationRepository.signUp(email: email, password: password),
            throwsA(isA<SignUpWithEmailAndPasswordFailure>()),
          );
        },
      );

      test(
        'throws SignUpWithEmailAndPasswordFailure '
        'when createUserWithEmailAndPassword throws',
        () async {
          when(
            () => firebaseAuth.createUserWithEmailAndPassword(
              email: any(named: 'email'),
              password: any(named: 'password'),
            ),
          ).thenThrow(Exception());
          expect(
            authenticationRepository.signUp(email: email, password: password),
            throwsA(isA<SignUpWithEmailAndPasswordFailure>()),
          );
        },
      );
    });

    group('logInWithEmailAndPassword', () {
      setUp(() {
        when(
          () => firebaseAuth.signInWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        ).thenAnswer((_) => Future.value(MockUserCredential()));
      });

      test('calls signInWithEmailAndPassword', () async {
        await authenticationRepository.logInWithEmailAndPassword(
          email: email,
          password: password,
        );
        verify(
          () => firebaseAuth.signInWithEmailAndPassword(
            email: email,
            password: password,
          ),
        ).called(1);
      });

      test('succeeds when signInWithEmailAndPassword succeeds', () async {
        expect(
          authenticationRepository.logInWithEmailAndPassword(
            email: email,
            password: password,
          ),
          completes,
        );
      });

      test(
        'throws LogInWithEmailAndPasswordFailure '
        'when signInWithEmailAndPassword throws FirebaseAuthException',
        () async {
          when(
            () => firebaseAuth.signInWithEmailAndPassword(
              email: any(named: 'email'),
              password: any(named: 'password'),
            ),
          ).thenThrow(FirebaseAuthException(code: 'code'));
          expect(
            authenticationRepository.logInWithEmailAndPassword(
              email: email,
              password: password,
            ),
            throwsA(isA<LogInWithEmailAndPasswordFailure>()),
          );
        },
      );

      test(
        'throws LogInWithEmailAndPasswordFailure '
        'when signInWithEmailAndPassword throws',
        () async {
          when(
            () => firebaseAuth.signInWithEmailAndPassword(
              email: any(named: 'email'),
              password: any(named: 'password'),
            ),
          ).thenThrow(Exception());
          expect(
            authenticationRepository.logInWithEmailAndPassword(
              email: email,
              password: password,
            ),
            throwsA(isA<LogInWithEmailAndPasswordFailure>()),
          );
        },
      );
    });

    group('logOut', () {
      test('calls signOut', () async {
        when(firebaseAuth.signOut).thenAnswer((_) async {});
        await authenticationRepository.logOut();
        verify(firebaseAuth.signOut).called(1);
      });

      test('throws LogOutFailure when signOut throws', () async {
        when(firebaseAuth.signOut).thenThrow(Exception());
        expect(
          authenticationRepository.logOut,
          throwsA(isA<LogOutFailure>()),
        );
      });
    });

    group('user', () {
      test('emits User.empty when firebase user is null', () async {
        when(firebaseAuth.authStateChanges).thenAnswer(
          (_) => Stream.value(null),
        );
        await expectLater(
          authenticationRepository.user,
          emitsInOrder(const <User>[User.empty]),
        );
      });

      test('emits User when firebase user is not null', () async {
        final firebaseUser = MockFirebaseUser();
        when(() => firebaseUser.uid).thenReturn(_mockFirebaseUserUid);
        when(() => firebaseUser.email).thenReturn(_mockFirebaseUserEmail);
        when(() => firebaseUser.photoURL).thenReturn(null);
        when(firebaseAuth.authStateChanges).thenAnswer(
          (_) => Stream.value(firebaseUser),
        );
        await expectLater(
          authenticationRepository.user,
          emitsInOrder(const <User>[user]),
        );
      });
    });
  });
}
