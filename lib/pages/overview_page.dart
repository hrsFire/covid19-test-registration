import 'package:flutter/material.dart';
import 'package:covid19_test_registration/screens/overview_screen.dart';

class OverviewPage extends Page {
  OverviewPage() : super(key: ValueKey('OverviewPage'));

  @override
  Route createRoute(BuildContext context) {
    return MaterialPageRoute(
      settings: this,
      builder: (BuildContext context) {
        return OverviewScreen();
      },
    );
  }
}
