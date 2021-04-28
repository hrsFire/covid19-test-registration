import 'package:flutter/material.dart';

class MenuState extends ChangeNotifier {
  bool _isOverviewActive = false;
  bool _isRegistrationsActive = false;
  bool _isResultsActive = false;
  bool _isSettingsActive = false;

  set isOverviewActive(bool isOverviewActive) {
    _reset(isOverviewActive);
    _isOverviewActive = isOverviewActive;
    notifyListeners();
  }

  set isRegistrationsActive(bool isRegistrationsActive) {
    _reset(isRegistrationsActive);
    _isRegistrationsActive = isRegistrationsActive;
    notifyListeners();
  }

  set isResultsActive(bool isResultsActive) {
    _reset(isResultsActive);
    _isResultsActive = isResultsActive;
    notifyListeners();
  }

  set isSettingsActive(bool isSettingsActive) {
    _reset(isSettingsActive);
    _isSettingsActive = isSettingsActive;
    notifyListeners();
  }

  bool get isOverviewActive => _isOverviewActive;
  bool get isRegistrationsActive => _isRegistrationsActive;
  bool get isResultsActive => _isResultsActive;
  bool get isSettingsActive => _isSettingsActive;

  _reset(bool isActive) {
    if (isActive) {
      _isOverviewActive = false;
      _isRegistrationsActive = false;
      _isResultsActive = false;
      _isSettingsActive = false;
    }
  }
}
