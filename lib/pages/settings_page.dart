import 'package:flutter/material.dart';
import 'package:covid19_test_registration/screens/settings_screen.dart';

class SettingsPage extends Page {
  SettingsPage() : super(key: ValueKey('SettingsPage'));

  @override
  Route createRoute(BuildContext context) {
    return MaterialPageRoute(
      settings: this,
      builder: (BuildContext context) {
        return SettingsScreen();
      },
    );
  }
}
