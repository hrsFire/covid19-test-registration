import 'dart:async';
import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:covid19_test_registration/services/test_date.dart';
import 'package:covid19_test_registration/services/test_location_with_dates.dart';
import 'package:covid19_test_registration/services/test_location.dart';
import 'package:flutter/material.dart';
import 'dart:developer';
import 'package:easy_localization/easy_localization.dart';
import 'package:covid19_test_registration/services/covid_service.dart';
import 'package:covid19_test_registration/generated/locale_keys.g.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';

class OverviewScreen extends StatefulWidget {
  OverviewScreen({Key key}) : super(key: key);

  @override
  _OverviewScreenState createState() => _OverviewScreenState();
}

// https://flutter.dev/docs/get-started/flutter-for/android-devs#how-do-i-listen-to-android-activity-lifecycle-events
class _OverviewScreenState extends State<OverviewScreen>
    with WidgetsBindingObserver {
  final Completer<WebViewController> _controller =
      Completer<WebViewController>();
  final _searchFieldController = TextEditingController();
  bool _isLoading = false;
  DateTime _selectedDate;
  final _selectedDateController = TextEditingController();
  List<TestLocationWithDates> _allTestLocationsWithDates = [];
  List<TestLocationWithDates> _testLocationsWithDates = [];
  List<TestDate> _testDates = [];
  TestLocation _chosenTestSiteForSampling;
  TestDate _chosenTestDateForSampling;
  String _grecaptcha;

  @override
  void initState() {
    super.initState();

    _showLoadingAnimation();

    CovidService.getAllTestLocationsWithDates().then((value) {
      setState(() {
        _allTestLocationsWithDates = value;
      });

      _searchForEntries();
      _stopLoadingAnimation();
    }).catchError((onError) {
      _stopLoadingAnimation();
    });

    // Disabled because it leads to visibility issues with multiple webviews
    //if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();

    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    _stopLoadingAnimation();
    WidgetsBinding.instance.removeObserver(this);
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

  void _showLoadingAnimation() {
    if (_isLoading) {
      return;
    }

    _isLoading = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      var loadingIndicator = SnackBar(
        content: Row(
          children: <Widget>[
            CircularProgressIndicator(),
            Text("    " + LocaleKeys.loading_data.tr())
          ],
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(loadingIndicator);
    });
  }

  void _stopLoadingAnimation() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(LocaleKeys.start.tr())),
      body: SingleChildScrollView(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
            Container(
                padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      onSubmitted: (v) {
                        _searchForEntries();
                      },
                      decoration: new InputDecoration(
                        labelText: LocaleKeys.search_location.tr(),
                      ),
                      controller: _searchFieldController,
                    ),
                  ],
                )),
            Container(
                padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      onSubmitted: (v) {
                        _searchForEntries();
                      },
                      onTap: () => _selectDate(context),
                      decoration: new InputDecoration(
                        labelText: LocaleKeys.search_for_date.tr(),
                      ),
                      controller: _selectedDateController,
                    ),
                  ],
                )),
            Container(
                padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ElevatedButton(
                      child: Text(LocaleKeys.reset_search.tr()),
                      onPressed: _resetSearch,
                    ),
                  ],
                )),
            Container(
              padding: EdgeInsets.fromLTRB(0, 80, 0, 0),
              child: DropdownButton<TestLocationWithDates>(
                value: _chosenTestSiteForSampling,
                items: _testLocationsWithDates
                    .map<DropdownMenuItem<TestLocationWithDates>>(
                        (TestLocation value) {
                  return DropdownMenuItem<TestLocationWithDates>(
                      value: value,
                      child:
                          Text(value.value, overflow: TextOverflow.ellipsis));
                }).toList(),
                hint: Text(
                  LocaleKeys.select_test_site_for_sampling.tr(),
                ),
                disabledHint: Text(
                  LocaleKeys.no_entries_available.tr(),
                ),
                onChanged: _testLocationsWithDates.length > 0
                    ? (TestLocationWithDates value) {
                        setState(() {
                          _chosenTestSiteForSampling = value;
                          _testDates = value.testDates;
                          _chosenTestDateForSampling = null;
                        });
                      }
                    : null,
              ),
            ),
            Container(
                padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
                child: DropdownButton<TestDate>(
                  value: _chosenTestDateForSampling,
                  items: _testDates
                      .map<DropdownMenuItem<TestDate>>((TestDate value) {
                    return DropdownMenuItem<TestDate>(
                        value: value,
                        child: Text(value.shortDescription,
                            overflow: TextOverflow.ellipsis));
                  }).toList(),
                  hint: Text(
                    LocaleKeys.select_location_and_date_for_sampling.tr(),
                  ),
                  disabledHint: Text(
                    LocaleKeys.no_entries_available.tr(),
                  ),
                  onChanged: _testDates.length > 0 &&
                          _chosenTestSiteForSampling != null
                      ? (TestDate value) {
                          setState(() {
                            _chosenTestDateForSampling = value;
                          });
                        }
                      : null,
                )),
            Container(
                padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ElevatedButton(
                      child: Text(LocaleKeys.register.tr()),
                      onPressed: _chosenTestSiteForSampling != null &&
                              _chosenTestDateForSampling != null
                          ? () {
                              _registerForTest(_chosenTestSiteForSampling,
                                  _chosenTestDateForSampling);
                            }
                          : null,
                    ),
                  ],
                )),
            Container(
                alignment: Alignment.bottomCenter,
                child: SizedBox(
                    height: 0,
                    child: WebView(
                      initialUrl:
                          'https://vorarlbergtestet.lwz-vorarlberg.at/GesundheitRegister/Covid/Register',
                      javascriptMode: JavascriptMode.unrestricted,
                      onWebViewCreated: (WebViewController webViewController) {
                        if (_controller.isCompleted) {
                          return;
                        }

                        _controller.complete(webViewController);

                        Future.delayed(const Duration(milliseconds: 2000),
                            () async {
                          // Catch the JavaScript invoke exception
                          try {
                            await webViewController.evaluateJavascript('''
grecaptcha.ready(function () {
  grecaptcha.execute('6LfzL-sZAAAAAA0HC5T8fGz0TzLA7JuNn5GK0Zlz', { action: 'submit' }).then(function (grecaptcharesponse) {
    //alert(grecaptcharesponse);
    AppGrecaptcha.postMessage(grecaptcharesponse);
    return;
  });
});
AppGrecaptcha.postMessage(null);
''');
                          } on MissingPluginException catch (error) {
                            // Intentionally left blank
                          }
                        });
                      },
                      onProgress: (int progress) {
                        print("WebView is loading (progress : $progress%)");
                      },
                      javascriptChannels: <JavascriptChannel>{
                        _grecaptchaJavascriptChannel(),
                      },
                      gestureNavigationEnabled: true,
                    ))),
          ])),
    );
  }

  JavascriptChannel _grecaptchaJavascriptChannel() {
    return JavascriptChannel(
        name: 'AppGrecaptcha',
        onMessageReceived: (JavascriptMessage message) async {
          _grecaptcha = message.message;
        });
  }

  Future<void> _selectDate(BuildContext context) async {
    FocusScope.of(context).unfocus();
    print("selected date");

    final DateTime pickedDate = await showDatePicker(
        context: context,
        initialDate: _selectedDate != null ? _selectedDate : DateTime.now(),
        firstDate: DateTime.now(),
        lastDate: DateTime.now().add(Duration(days: 60)));

    if (pickedDate != null && pickedDate != _selectedDate)
      setState(() {
        final DateFormat formatter = DateFormat('dd.MM.yyyy');
        _selectedDateController.text = formatter.format(pickedDate);
        _selectedDate = pickedDate;
      });

    _searchForEntries();
  }

  _resetSearch() {
    _searchFieldController.text = "";
    _selectedDate = null;
    _selectedDateController.text = "";

    _searchForEntries();
  }

  _searchForEntries() {
    _showLoadingAnimation();

    var searchText = _searchFieldController.text;
    List<TestLocationWithDates> tmpTestLocationsWithDates =
        _allTestLocationsWithDates
            .where(
                (x) => _isTestLocationsInSearch(x, searchText, _selectedDate))
            .toList();

    for (var i = 0; i < tmpTestLocationsWithDates.length; i++) {
      tmpTestLocationsWithDates[i] =
          TestLocationWithDates.clone(tmpTestLocationsWithDates[i]);
      tmpTestLocationsWithDates[i].testDates = tmpTestLocationsWithDates[i]
          .testDates
          .where((x) => _isTestDateInSearch(x, searchText, _selectedDate))
          .toList();
    }

    // Check if the selected entry still exists
    var tmpTestLocationWithDatesList = tmpTestLocationsWithDates
        .where((x) => x.key == _chosenTestSiteForSampling?.key);
    var previouslyChoosenTestLocationWithDates =
        tmpTestLocationWithDatesList.length > 0
            ? tmpTestLocationWithDatesList.first
            : null;

    TestDate previouslyChoosenTestDate;

    // Check if the selected test location still exists
    if (previouslyChoosenTestLocationWithDates == null) {
      previouslyChoosenTestDate = null;
    } else {
      // Check if the selected test date still exists
      var tmpTestDateList = previouslyChoosenTestLocationWithDates.testDates
          .where((x) => (x.key == _chosenTestDateForSampling?.key));
      previouslyChoosenTestDate =
          tmpTestDateList.length > 0 ? tmpTestDateList.first : null;
    }

    setState(() {
      _testLocationsWithDates = tmpTestLocationsWithDates;

      if (previouslyChoosenTestLocationWithDates != null) {
        _testDates = previouslyChoosenTestLocationWithDates.testDates;
      }

      _chosenTestSiteForSampling = previouslyChoosenTestLocationWithDates;
      _chosenTestDateForSampling = previouslyChoosenTestDate;
    });

    _stopLoadingAnimation();
  }

  bool _isTestLocationsInSearch(TestLocationWithDates testLocation,
      String searchText, DateTime selectedDate) {
    var searchTextLc = searchText?.toLowerCase();
    var testLocationValueLc = testLocation.value;

    if (_selectedDate != null && searchText != null && searchText.isNotEmpty) {
      return testLocationValueLc.contains(searchTextLc) &&
          testLocation.testDates.any((x) => _matchsDate(x, _selectedDate));
    } else if (selectedDate != null) {
      return testLocation.testDates.any((x) => _matchsDate(x, _selectedDate));
    } else if (searchText != null && searchText.isNotEmpty) {
      return testLocationValueLc.contains(searchTextLc);
    }

    return true;
  }

  bool _isTestDateInSearch(
      TestDate testDate, String searchText, DateTime selectedDate) {
    var searchTextLc = searchText?.toLowerCase();
    var testDateValueLc = testDate.value;

    if (_selectedDate != null && searchText != null && searchText.isNotEmpty) {
      return testDateValueLc.contains(searchTextLc) &&
          _matchsDate(testDate, _selectedDate);
    } else if (selectedDate != null) {
      return _matchsDate(testDate, _selectedDate);
    } else if (searchText != null && searchText.isNotEmpty) {
      return testDateValueLc.contains(searchTextLc);
    }

    return true;
  }

  bool _matchsDate(TestDate testDate, DateTime dateTime) {
    return testDate.startDateTime.day == dateTime.day &&
        testDate.startDateTime.month == dateTime.month &&
        testDate.startDateTime.year == dateTime.year;
  }

  Future<bool> _registerForTest(
      TestLocation testLocation, TestDate testDate) async {
    if (_grecaptcha == null) {
      return false;
    }

    var requestValidationCode = await CovidService.getRequestVerificationCode();

    var registration = await CovidService.register(
        _grecaptcha, requestValidationCode, testLocation, testDate);

    if (registration != null) {
      final Event event = Event(
        title: LocaleKeys.event_title.tr(),
        description: registration.url,
        location: testLocation.value,
        startDate: testDate.startDateTime,
        endDate: testDate.endDateTime,
      );

      await Add2Calendar.addEvent2Cal(event);

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(LocaleKeys.registration_successful.tr()),
          backgroundColor: Colors.green));

      return true;

      // Not required at the moment
      // if (registration.validatedPerson != null) {
      //   var tan = await CovidService.getTan();

      //   if (await CovidService.sendTan(registration.validatedPerson, tan)) {}
      // }
    }

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      duration: Duration(seconds: 7),
      content: Text(LocaleKeys.registration_failed.tr()),
      backgroundColor: Colors.red,
    ));

    return false;
  }
}
