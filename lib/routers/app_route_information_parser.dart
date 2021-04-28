import 'package:flutter/cupertino.dart';
import 'package:covid19_test_registration/routers/app_route_path.dart';

const String _overviewUri = '/';

class AppRouteInformationParser extends RouteInformationParser<AppRoutePath> {
  @override
  Future<AppRoutePath> parseRouteInformation(
      RouteInformation routeInformation) async {
    final uri = Uri.parse(routeInformation.location);

    if (uri.pathSegments.length > 0) {
      switch (uri.pathSegments.first) {
        case _overviewUri:
          return AppRoutePath.overviewPage();
      }
    }

    return AppRoutePath.overviewPage();
  }

  @override
  RouteInformation restoreRouteInformation(AppRoutePath path) {
    if (path.isOverviewPage) {
      return RouteInformation(location: _overviewUri);
    }

    return RouteInformation();
  }
}
