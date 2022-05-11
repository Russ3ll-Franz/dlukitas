import 'package:dlukitas/app/bloc/app_bloc.dart';
import 'package:flutter/material.dart';

List<Page> onGenerateAppViewPages(AppStatus status, List<Page> pages) {
  if (status.isAuthenticated) {
    /* return [CounterPage.page()]; */
  } else {
    return [SplashPage.page()];
  }
}
