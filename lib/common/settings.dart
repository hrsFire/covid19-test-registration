import 'package:covid19_test_registration/common/user_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Settings {
  // https://flutter.dev/docs/cookbook/persistence/key-value
  static const _firstNameKey = "firstName";
  static const _lastNameKey = "lastName";
  static const _dateOfBirthKey = "dateOfBirth";
  static const _socialSecurityNumberKey = "socialSecurityNumber";
  static const _postalCodeKey = "postalCode";
  static const _cityKey = "city";
  static const _streetKey = "street";
  static const _houseNumberKey = "houseNumber";
  static const _mobileNumberKey = "mobileNumber";
  static const _emailAddressKey = "emailAddress";

  static Future<bool> setUserDefinedSettings(UserSettings userSettings) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(_firstNameKey, userSettings.firstName);
    prefs.setString(_lastNameKey, userSettings.lastName);
    prefs.setString(_dateOfBirthKey, userSettings.dateOfBirth);
    prefs.setString(
        _socialSecurityNumberKey, userSettings.socialSecurityNumber);
    prefs.setString(_postalCodeKey, userSettings.postalCode);
    prefs.setString(_cityKey, userSettings.city);
    prefs.setString(_streetKey, userSettings.street);
    prefs.setString(_houseNumberKey, userSettings.houseNumber);
    prefs.setString(_mobileNumberKey, userSettings.mobileNumber);
    prefs.setString(_emailAddressKey, userSettings.emailAddress);

    return true;
  }

  static Future<UserSettings> getUserDefinedSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var settings = UserSettings();

    try {
      settings.firstName = prefs.getString(_firstNameKey);
      settings.lastName = prefs.getString(_lastNameKey);
      settings.dateOfBirth = prefs.getString(_dateOfBirthKey);
      settings.socialSecurityNumber = prefs.getString(_socialSecurityNumberKey);
      settings.postalCode = prefs.getString(_postalCodeKey);
      settings.city = prefs.getString(_cityKey);
      settings.street = prefs.getString(_streetKey);
      settings.houseNumber = prefs.getString(_houseNumberKey);
      settings.mobileNumber = prefs.getString(_mobileNumberKey);
      settings.emailAddress = prefs.getString(_emailAddressKey);
    } catch (error) {
      return null;
    }

    return settings;
  }

  static Future<bool> areUserDefinedSettingsValid() async {
    var settings = await getUserDefinedSettings();

    if (settings == null ||
        settings.firstName == null ||
        settings.firstName.isEmpty ||
        settings.lastName == null ||
        settings.lastName.isEmpty ||
        settings.dateOfBirth == null ||
        settings.dateOfBirth.isEmpty ||
        settings.socialSecurityNumber == null ||
        settings.socialSecurityNumber.isEmpty ||
        settings.postalCode == null ||
        settings.postalCode.isEmpty ||
        settings.city == null ||
        settings.city.isEmpty ||
        settings.street == null ||
        settings.street.isEmpty ||
        settings.houseNumber == null ||
        settings.houseNumber.isEmpty ||
        settings.mobileNumber == null ||
        settings.mobileNumber.isEmpty ||
        settings.emailAddress == null ||
        settings.emailAddress.isEmpty) {
      return false;
    }

    return true;
  }
}
