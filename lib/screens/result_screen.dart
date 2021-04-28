import 'dart:async';
import 'package:covid19_test_registration/common/settings.dart';
import 'package:covid19_test_registration/services/covid_service.dart';
import 'package:flutter/material.dart';
import 'dart:developer';
import 'package:easy_localization/easy_localization.dart';
import 'package:covid19_test_registration/generated/locale_keys.g.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ResultScreen extends StatefulWidget {
  ResultScreen({Key key}) : super(key: key);

  @override
  _ResultScreenState createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen>
    with WidgetsBindingObserver {
  final Completer<WebViewController> _controller =
      Completer<WebViewController>();

  @override
  void initState() {
    super.initState();

    // Disabled because it leads to visibility issues with multiple webviews
    //if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      log(state.toString());
    } else if (state == AppLifecycleState.resumed) {
      log(state.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text(LocaleKeys.result.tr())),
        body: WebView(
          initialUrl: '',
          javascriptMode: JavascriptMode.unrestricted,
          onWebViewCreated: (WebViewController webViewController) async {
            if (_controller.isCompleted) {
              return;
            }

            _controller.complete(webViewController);

            var lastTestNumber = await CovidService.getLastTestNumberFromSms();

            if (await Settings.areUserDefinedSettingsValid() &&
                lastTestNumber != null) {
              var userSettings = await Settings.getUserDefinedSettings();
              webViewController.loadUrl(
                  'https://vorarlbergtestet.lwz-vorarlberg.at/GesundheitRegister/Request/Result?num=${lastTestNumber}&pin=${userSettings.dateOfBirth}');

              Future.delayed(const Duration(milliseconds: 2500), () async {
                await webViewController.evaluateJavascript('''
//document.getElementById('pin').value = "${userSettings.dateOfBirth}";
document.getElementById('btnSend').click();
document.querySelector('[aria-label="Close"]').remove();

''');

                var tan = await CovidService.getTan();

                if (tan != null) {
                  await webViewController.evaluateJavascript('''
document.getElementById('tanInput').value = "${tan}";
document.querySelector('[onclick="sendTan()"]').click();
''');
                }
              });
            }
          },
          gestureNavigationEnabled: true,
        ));
  }
}
