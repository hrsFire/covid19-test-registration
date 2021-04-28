import 'package:covid19_test_registration/pages/overview_page.dart';
import 'package:covid19_test_registration/pages/registrations_page.dart';
import 'package:covid19_test_registration/pages/results_page.dart';
import 'package:covid19_test_registration/pages/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:covid19_test_registration/animations/no_animation_transition_delegate.dart';
import 'package:covid19_test_registration/states/menu_state.dart';
import 'package:covid19_test_registration/routers/app_route_path.dart';

class AppRouterDelegate extends RouterDelegate<AppRoutePath>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<AppRoutePath> {
  final GlobalKey<NavigatorState> navigatorKey;
  MenuState menuState;

  AppRouterDelegate(this.menuState)
      : navigatorKey = GlobalKey<NavigatorState>();

  @override
  AppRoutePath get currentConfiguration {
    if (menuState.isOverviewActive) {
      return AppRoutePath.overviewPage();
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      transitionDelegate: NoAnimationTransitionDelegate(),
      pages: [
        if (menuState.isOverviewActive) OverviewPage(),
        if (menuState.isRegistrationsActive) RegistrationsPage(),
        if (menuState.isResultsActive) ResultsPage(),
        if (menuState.isSettingsActive) SettingsPage(),
      ],
      onPopPage: (route, result) {
        if (!route.didPop(result)) {
          return false;
        }

        notifyListeners();
        return true;
      },
    );
  }

  @override
  Future<void> setNewRoutePath(AppRoutePath path) async {
    if (path.isOverviewPage) {
      menuState.isOverviewActive = true;
    }
  }
}
