// Copyright (c) 2022, Very Good Ventures
// https://verygood.ventures
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import 'package:authentication_repository/authentication_repository.dart';
import 'package:dlukitas/app/app.dart';
import 'package:dlukitas/bootstrap.dart';
import 'package:dlukitas/firebase_options/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final authenticationRepository = AuthenticationRepository();
  final user = await authenticationRepository.user.first;

  await bootstrap(
    () => App(
      authenticationRepository: authenticationRepository,
      user: user,
    ),
  );
}
