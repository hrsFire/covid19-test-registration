import 'package:flutter/material.dart';
import 'package:covid19_test_registration/screens/registrations_screen.dart';

class RegistrationsPage extends Page {
  RegistrationsPage() : super(key: ValueKey('RegistrationsPage'));

  @override
  Route createRoute(BuildContext context) {
    return MaterialPageRoute(
      settings: this,
      builder: (BuildContext context) {
        return RegistrationsScreen();
      },
    );
  }
}
