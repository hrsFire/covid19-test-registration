class AppRoutePath {
  final int _menuIndex;

  AppRoutePath.overviewPage() : _menuIndex = 0;

  bool get isOverviewPage => _menuIndex == 0;
}
