import 'dart:async';

import 'package:covid19_test_registration/common/settings.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:covid19_test_registration/generated/locale_keys.g.dart';
import 'package:covid19_test_registration/states/menu_state.dart';
import 'package:covid19_test_registration/routers/app_router_delegate.dart';

class AppShellScreen extends StatefulWidget {
  final MenuState _state = MenuState();

  AppShellScreen({Key key}) : super(key: key) {
    Settings.areUserDefinedSettingsValid().then((value) {
      if (value) {
        _state.isOverviewActive = true;
      } else {
        _state.isSettingsActive = true;
      }
    });
  }

  @override
  _AppShellScreenState createState() => _AppShellScreenState();
}

class _AppShellScreenState extends State<AppShellScreen> {
  AppRouterDelegate _routerDelegate;
  int _selectedIndex = 0;
  bool _userSettingsExist = false;

  @override
  void initState() {
    super.initState();

    Settings.areUserDefinedSettingsValid().then((areSettingsValid) {
      setState(() {
        _userSettingsExist = areSettingsValid;

        if (areSettingsValid) {
          if (widget._state.isOverviewActive) {
            _selectedIndex = 0;
          } else if (widget._state.isRegistrationsActive) {
            _selectedIndex = 1;
          } else if (widget._state.isResultsActive) {
            _selectedIndex = 2;
          } else if (widget._state.isSettingsActive) {
            _selectedIndex = 3;
          }
        } else {
          _selectedIndex = 3;
        }
      });
    });

    const oneSec = const Duration(seconds: 1);
    final timer = new Timer.periodic(oneSec, (Timer timer) async {
      var areSettingsValid = await Settings.areUserDefinedSettingsValid();

      if (areSettingsValid) {
        setState(() {
          _userSettingsExist = areSettingsValid;
          widget._state.isOverviewActive = true;
          _selectedIndex = 0;
        });

        timer.cancel();
      }
    });

    _routerDelegate = AppRouterDelegate(widget._state);
  }

  @override
  void didUpdateWidget(covariant AppShellScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    _routerDelegate.menuState = widget._state;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPopScope,
      child: Scaffold(
        body: Router(
          routerDelegate: _routerDelegate,
        ),
        bottomNavigationBar: Container(
            child: _userSettingsExist
                ? BottomNavigationBar(
                    items: [
                      BottomNavigationBarItem(
                          icon: Icon(Icons.home),
                          label: LocaleKeys.start.tr(),
                          backgroundColor: Colors.grey[350]),
                      BottomNavigationBarItem(
                          icon: Icon(Icons.alarm),
                          label: LocaleKeys.registrations.tr(),
                          backgroundColor: Colors.grey[350]),
                      BottomNavigationBarItem(
                          icon: Icon(Icons.chat_rounded),
                          label: LocaleKeys.result.tr(),
                          backgroundColor: Colors.grey[350]),
                      BottomNavigationBarItem(
                          icon: Icon(Icons.settings),
                          label: LocaleKeys.settings.tr(),
                          backgroundColor: Colors.grey[350])
                    ],
                    currentIndex: _selectedIndex,
                    selectedItemColor: Colors.red,
                    onTap: _onMenuItemTapped,
                  )
                : Container(
                    height: 0,
                    width: MediaQuery.of(context).size.width,
                  )),
      ),
    );
  }

  Future<bool> _onWillPopScope() async {
    _routerDelegate.popRoute();

    return false;
  }

  void _onMenuItemTapped(int index) {
    if (!_userSettingsExist) {
      return;
    }

    setState(() {
      _selectedIndex = index;

      switch (index) {
        case 0:
          widget._state.isOverviewActive = true;
          break;
        case 1:
          widget._state.isRegistrationsActive = true;
          break;
        case 2:
          widget._state.isResultsActive = true;
          break;
        case 3:
        default:
          widget._state.isSettingsActive = true;
          break;
      }
    });
  }
}
