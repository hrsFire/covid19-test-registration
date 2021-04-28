import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'generated/codegen_loader.g.dart';
import 'package:covid19_test_registration/app.dart';

void main() async {
  // Needs to be called so that we can await for EasyLocalization.ensureInitialized();
  WidgetsFlutterBinding.ensureInitialized();

  await EasyLocalization.ensureInitialized();

  runApp(EasyLocalization(
      child: App(),
      supportedLocales: [Locale('en'), Locale('de')],
      path: 'resources/langs',
      // Requires:
      // flutter pub run easy_localization:generate
      // flutter pub run easy_localization:generate -f keys -o locale_keys.g.dart
      // https://pub.dev/packages/easy_localization#-localization-asset-loader-class
      assetLoader: CodegenLoader()));
}
