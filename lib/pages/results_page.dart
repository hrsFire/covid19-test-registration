import 'package:flutter/material.dart';
import 'package:covid19_test_registration/screens/result_screen.dart';

class ResultsPage extends Page {
  ResultsPage() : super(key: ValueKey('ResultsPage'));

  @override
  Route createRoute(BuildContext context) {
    return MaterialPageRoute(
      settings: this,
      builder: (BuildContext context) {
        return ResultScreen();
      },
    );
  }
}
