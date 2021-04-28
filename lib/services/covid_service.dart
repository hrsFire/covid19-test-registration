import 'dart:convert';
import 'dart:io';
import 'package:covid19_test_registration/common/settings.dart';
import 'package:covid19_test_registration/services/validated_person.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;
import 'registration.dart';
import 'test_date.dart';
import 'test_location_with_dates.dart';
import 'test_location.dart';
import 'city.dart';

class CovidService {
  static final _germanDateTimeFormat = DateFormat("dd.MM.yyyy hh:mm");

  static Future<List<City>> getCities() async {
    // https://flutter.dev/docs/cookbook/networking/fetch-data
    try {
      var uri = Uri.https('vorarlbergtestet.lwz-vorarlberg.at',
          'GesundheitRegister/Covid/GetGemeinden');
      var response = await http.post(uri);

      if (response.statusCode == 200) {
        List<dynamic> jsonCities = jsonDecode(response.body);
        List<City> cities = [];

        for (String jsonCity in jsonCities) {
          var city = City();
          city.key = jsonCity;

          // Split the postal code from the city name
          var items = jsonCity.split(' ');
          city.postalCode = items[0];
          city.city = items[1];

          cities.add(city);
        }

        return cities;
      }
    } catch (error) {
      // Intentionally left blank
    }

    return null;
  }

  static Future<List<TestLocation>> getTestLocations() async {
    // https://flutter.dev/docs/cookbook/networking/fetch-data
    try {
      var uri = Uri.https(
          'vorarlbergtestet.lwz-vorarlberg.at',
          'GesundheitRegister/Covid/GetCovidTestLocationMassTest',
          {'betriebe': '0'});
      var response = await http.get(uri);

      if (response.statusCode == 200) {
        List<dynamic> jsonTestLocations = jsonDecode(response.body);
        List<TestLocation> testLocations = [];

        for (Map<String, dynamic> jsonLocation in jsonTestLocations) {
          var testLocation = TestLocation();
          testLocation.key = jsonLocation["key"];
          testLocation.value = jsonLocation["value"];
          testLocations.add(testLocation);
        }

        return testLocations;
      }
    } catch (error) {
      // Intentionally left blank
    }

    return null;
  }

  static Future<List<TestDate>> getTestDates(TestLocation testLocation) async {
    try {
      var uri = Uri.https('vorarlbergtestet.lwz-vorarlberg.at',
          'GesundheitRegister/Covid/GetCovidTestDatesMassTest');
      var response =
          await http.post(uri, body: {"ort": testLocation.key, "code": ""});

      if (response.statusCode == 200) {
        List<dynamic> jsonTestDates = jsonDecode(response.body);
        List<TestDate> testDates = [];

        for (Map<String, dynamic> jsonTestDate in jsonTestDates) {
          var testDate = TestDate();
          testDate.key = jsonTestDate["key"];
          testDate.value = jsonTestDate["value"];

          final dateTimeDurationRegex = RegExp(
              r'[0-9]{2}.[0-9]{2}.[0-9]{4} [0-9]{2}:[0-9]{2} - [0-9]{2}:[0-9]{2}');
          var match = dateTimeDurationRegex.firstMatch(testDate.value);
          var dateTimeDuration = match.group(0);

          // e.g.: "26.04.2021 19:30 - 19:45"
          var dateDurationItems = dateTimeDuration.split(' ');
          var date = dateDurationItems[0];
          var startTime = dateDurationItems[1];
          var endTime = dateDurationItems[3];
          testDate.startDateTime = _germanDateTimeFormat.parse(
            date + " " + startTime,
          );
          testDate.endDateTime =
              _germanDateTimeFormat.parse(date + " " + endTime);

          // Remove the location from the date time
          var locationEndIndex = testDate.value.indexOf(': ') + 2;
          testDate.shortDescription =
              testDate.value.substring(locationEndIndex, testDate.value.length);

          testDates.add(testDate);
        }

        return testDates;
      }
    } catch (error) {
      // Intentionally left blank
    }

    return null;
  }

  static Future<List<TestLocationWithDates>>
      getAllTestLocationsWithDates() async {
    var testLocations = await CovidService.getTestLocations();
    List<Future<List<TestDate>>> workers = [];
    List<List<TestDate>> testDates = [];

    for (var testLocation in testLocations) {
      workers.add(CovidService.getTestDates(testLocation));
    }

    testDates = await Future.wait(workers);
    List<TestLocationWithDates> testLocationsWithDates = [];

    for (var i = 0; i < testLocations.length; i++) {
      var testLocationWithDate = TestLocationWithDates();
      testLocationWithDate.key = testLocations[i].key;
      testLocationWithDate.value = testLocations[i].value;
      testLocationWithDate.testDates = testDates[i];

      testLocationsWithDates.add(testLocationWithDate);
    }

    return testLocationsWithDates;
  }

  static Future<String> getRequestVerificationCode({String tan}) async {
    try {
      Uri uri;

      if (tan != null) {
        uri = Uri.https('vorarlbergtestet.lwz-vorarlberg.at',
            'GesundheitRegister/Request/Result', {'num': tan}); //todo
      } else {
        uri = Uri.https('vorarlbergtestet.lwz-vorarlberg.at',
            'GesundheitRegister/Covid/Register');
      }

      var response = await http.get(uri);

      if (response.statusCode == 200) {
        var document = parse(response.body);
        var requestVerificationCodeTags = document
            .getElementsByTagName("input")
            .where((element) =>
                element.attributes["name"] == "__RequestVerificationToken");

        var requestVerificationCode =
            requestVerificationCodeTags.first.attributes["value"];

        return requestVerificationCode;
      }
    } catch (error) {
      // Intentionally left blank
    }

    return null;
  }

  static Future<ValidatedPerson> validatePerson(String grecaptcha) async {
    if (!await Settings.areUserDefinedSettingsValid()) {
      return null;
    }

    var userSettings = await Settings.getUserDefinedSettings();

    try {
      var uri = Uri.https('vorarlbergtestet.lwz-vorarlberg.at',
          'GesundheitRegister/Covid/ValidatePersonData');
      var response = await http.post(uri, body: {
        "checkboxSvnr": 'false',
        "vorname": userSettings.firstName,
        "nachname": userSettings.lastName,
        "geburtsdatum": userSettings.dateOfBirth,
        "svnr": userSettings.socialSecurityNumber,
        "phoneFull": userSettings.mobileNumber,
        "email": userSettings.emailAddress,
        "checkboxGuidelinesSelf": 'true',
        "recaptcha": grecaptcha
      });

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResult = jsonDecode(response.body);
        var validatedPerson = ValidatedPerson();
        validatedPerson.validationId = jsonResult["validate"];
        validatedPerson.dibos = jsonResult["dibos"];
        validatedPerson.gender = jsonResult["geschlecht"];
        validatedPerson.eventPresent = jsonResult["eventPresent"];

        return validatedPerson;
      }
    } catch (error) {
      // Intentionally left blank
    }

    return null;
  }

  static Future<Registration> register(
      String grecaptcha,
      String requestValidationCode,
      TestLocation testLocation,
      TestDate testDate) async {
    var userSettings = await Settings.getUserDefinedSettings();

    if (!await Settings.areUserDefinedSettingsValid()) {
      return null;
    }

    var validatedPerson = await validatePerson(grecaptcha);

    if (validatedPerson != null && !validatedPerson.eventPresent) {
      try {
        var shortMobileNumber = userSettings.mobileNumber
            .substring(3, userSettings.mobileNumber.length);
        var uri = Uri.https('vorarlbergtestet.lwz-vorarlberg.at',
            'GesundheitRegister/Covid/FormConfirmed');

        var response = await http.post(uri, body: {
          "firstName": userSettings.firstName,
          "lastName": userSettings.lastName,
          "birthday": userSettings.dateOfBirth,
          "svnr": userSettings.socialSecurityNumber,
          "geschlecht": validatedPerson.gender,
          "place": userSettings.postalCode + " " + userSettings.city,
          "street": userSettings.street,
          "streetNumber": userSettings.houseNumber,
          "phone": shortMobileNumber,
          "phoneFull": userSettings.mobileNumber,
          "email": userSettings.emailAddress,
          "code": "",
          "probeLocation": testLocation.key,
          "probeDate": testDate.key.toString(),
          "checkboxGuidelinesSelf": "on",
          "userId": validatedPerson.validationId,
          "logonUser": "",
          "__RequestVerificationToken": requestValidationCode
        });

        if (response.statusCode == 302) {
          var registration = Registration();
          registration.url = "https://vorarlbergtestet.lwz-vorarlberg.at" +
              response.headers["location"];
          registration.validatedPerson = validatedPerson;

          return registration;
        }
      } catch (error) {
        // Intentionally left blank
      }
    }

    return null;
  }

  static Future<String> getTan() async {
    var startDate = DateTime.now();

    try {
      SmsQuery query = new SmsQuery();

      while (true) {
        var smsList = await query.querySms(
            kinds: [SmsQueryKind.Inbox], count: 1, address: 'BOS-Vlbg');

        for (var sms in smsList) {
          if (sms.dateSent.isAfter(startDate)) {
            var tan = sms.body
                .replaceFirst('Folgenden TAN im Formular eingeben: ', '')
                .replaceFirst(
                    'Folgenden TAN im Abfrage Formular eingeben: ', '')
                .trim();
            return tan;
          }
        }

        if (DateTime.now().difference(startDate).inSeconds > 50) {
          return null;
        }

        sleep(Duration(microseconds: 200));
      }
    } catch (error) {
      // Intentionally left blank
    }

    return null;
  }

  static Future<bool> sendTan(
      ValidatedPerson validatedPerson, String tan) async {
    if (validatedPerson != null && !validatedPerson.eventPresent) {
      try {
        var uri = Uri.https('vorarlbergtestet.lwz-vorarlberg.at',
            'GesundheitRegister/Covid/TanValidation');

        var response = await http.post(uri,
            body: {"tanInput": tan, "id": validatedPerson.validationId});

        if (response.statusCode == 200) {
          var body = response.body;
          return body == "true";
        }
      } catch (error) {
        // Intentionally left blank
      }
    }

    return false;
  }

  static Future<String> getLastTestNumberFromSms() async {
    try {
      SmsQuery query = new SmsQuery();

      var smsList = await query
          .querySms(kinds: [SmsQueryKind.Inbox], address: 'BOS-Vlbg');
      const searchString =
          'https://vorarlbergtestet.lwz-vorarlberg.at/GesundheitRegister/Request/Result?num=';
      String tan;

      for (var sms in smsList) {
        if (sms.body.contains(searchString)) {
          tan = sms.body.replaceFirst(searchString, '').trim();
          break;
        }
      }

      return tan;
    } catch (error) {
      // Intentionally left blank
    }

    return null;
  }

  static Future<bool> getResult(
      String tan, String requestValidationCode, String grecaptcha) async {
    if (await Settings.areUserDefinedSettingsValid()) {
      var userSettings = await Settings.getUserDefinedSettings();

      try {
        var uri = Uri.https('vorarlbergtestet.lwz-vorarlberg.at',
            'GesundheitRegister/Request/SendTan');
        //'GesundheitRegister/Request/ResultConfirmed');

        var response = await http.post(uri, body: '''{
          "num_1": tan,
          "pin": /*userSettings.dateOfBirth*/ "05.11.1993",
          "recaptcha": "${grecaptcha}",
          __RequestVerificationToken: "${requestValidationCode}"
        }''');

        if (response.statusCode == 200) {
          var body = response.body;
          return body == "true";
        }
      } catch (error) {
        // Intentionally left blank
      }
    }

    return false;
  }

  static Future<String> getLastResultFromSms(String grecaptcha) async {
    try {
      var testNumber = await getLastTestNumberFromSms();

      if (testNumber != null) {
        var requestValidationCode =
            await getRequestVerificationCode(tan: testNumber);
        await getResult(testNumber, requestValidationCode, grecaptcha);
      }
    } catch (error) {
      // Intentionally left blank
    }

    return null;
  }
}
