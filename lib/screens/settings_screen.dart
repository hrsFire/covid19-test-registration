import 'package:covid19_test_registration/common/settings.dart';
import 'package:covid19_test_registration/common/user_settings.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:covid19_test_registration/generated/locale_keys.g.dart';

class SettingsScreen extends StatefulWidget {
  SettingsScreen({Key key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();

  // https://stackoverflow.com/questions/52150677/how-to-shift-focus-to-next-textfield-in-flutter
  final _lastNameFocus = FocusNode();
  final _socialSecurityNumberFocus = FocusNode();
  final _postalCodeFocus = FocusNode();
  final _cityFocus = FocusNode();
  final _streetFocus = FocusNode();
  final _houseNumberFocus = FocusNode();
  final _mobileNumberFocus = FocusNode();
  final _emailAddressFocus = FocusNode();

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _dateOfBirthController = TextEditingController();
  final _socialSecurityNumberController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _cityController = TextEditingController();
  final _streetController = TextEditingController();
  final _houseNumberController = TextEditingController();
  final _mobileNumberController = TextEditingController();
  final _emailAddressController = TextEditingController();

  var _currentDateOfBirth = DateTime.now();

  @override
  void initState() {
    super.initState();

    Settings.getUserDefinedSettings()
        .then((UserSettings userSettings) => _applyUserSettings(userSettings));
  }

  @override
  Widget build(BuildContext context) {
    final _dateOfBirthFocus = FocusNode();
    _dateOfBirthFocus.addListener(() {
      _selectDate(context);
    });

    return Scaffold(
      appBar: AppBar(title: Text(LocaleKeys.settings.tr())),
      body: SingleChildScrollView(
        child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                Container(
                    padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          onFieldSubmitted: (v) {
                            FocusScope.of(context).requestFocus(_lastNameFocus);
                          },
                          validator: (value) {
                            return _nameValidator(value);
                          },
                          decoration: new InputDecoration(
                            labelText: LocaleKeys.first_name.tr(),
                          ),
                          controller: _firstNameController,
                        ),
                      ],
                    )),
                Container(
                    padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          focusNode: _lastNameFocus,
                          onFieldSubmitted: (v) {
                            FocusScope.of(context)
                                .requestFocus(_dateOfBirthFocus);
                          },
                          validator: (value) {
                            return _nameValidator(value);
                          },
                          decoration: new InputDecoration(
                            labelText: LocaleKeys.last_name.tr(),
                          ),
                          controller: _lastNameController,
                        ),
                      ],
                    )),
                Container(
                    padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          focusNode: _dateOfBirthFocus,
                          onFieldSubmitted: (v) {
                            FocusScope.of(context)
                                .requestFocus(_socialSecurityNumberFocus);
                          },
                          onTap: () => _selectDate(context),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return LocaleKeys.please_enter_your_date_of_birth
                                  .tr();
                            }
                            return null;
                          },
                          decoration: new InputDecoration(
                            labelText: LocaleKeys.date_of_birth.tr(),
                          ),
                          controller: _dateOfBirthController,
                        ),
                      ],
                    )),
                Container(
                    padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          keyboardType: TextInputType.number,
                          focusNode: _socialSecurityNumberFocus,
                          onFieldSubmitted: (v) {
                            FocusScope.of(context)
                                .requestFocus(_postalCodeFocus);
                          },
                          validator: (value) {
                            var text = value.trim();

                            if (value == null ||
                                text.isEmpty ||
                                text.length < 10) {
                              return LocaleKeys
                                  .please_enter_your_social_security_number
                                  .tr();
                            }
                            return null;
                          },
                          decoration: new InputDecoration(
                            labelText: LocaleKeys.social_security_number.tr(),
                          ),
                          controller: _socialSecurityNumberController,
                        ),
                      ],
                    )),
                Container(
                    padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          keyboardType: TextInputType.number,
                          focusNode: _postalCodeFocus,
                          onFieldSubmitted: (v) {
                            FocusScope.of(context).requestFocus(_cityFocus);
                          },
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return LocaleKeys.please_enter_your_postal_code
                                  .tr();
                            }
                            return null;
                          },
                          decoration: new InputDecoration(
                            labelText: LocaleKeys.postal_code.tr(),
                          ),
                          controller: _postalCodeController,
                        ),
                      ],
                    )),
                Container(
                    padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          focusNode: _cityFocus,
                          onFieldSubmitted: (v) {
                            FocusScope.of(context).requestFocus(_streetFocus);
                          },
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return LocaleKeys.please_enter_your_city.tr();
                            }
                            return null;
                          },
                          decoration: new InputDecoration(
                            labelText: LocaleKeys.city.tr(),
                          ),
                          controller: _cityController,
                        ),
                      ],
                    )),
                Container(
                    padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                            focusNode: _streetFocus,
                            onFieldSubmitted: (v) {
                              FocusScope.of(context)
                                  .requestFocus(_houseNumberFocus);
                            },
                            validator: (value) {
                              var text = value.trim();

                              if (value == null || text.isEmpty) {
                                return LocaleKeys.please_enter_your_street.tr();
                              }
                              return null;
                            },
                            decoration: new InputDecoration(
                              labelText: LocaleKeys.street.tr(),
                            ),
                            controller: _streetController),
                      ],
                    )),
                Container(
                    padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          keyboardType: TextInputType.number,
                          focusNode: _houseNumberFocus,
                          onFieldSubmitted: (v) {
                            FocusScope.of(context)
                                .requestFocus(_mobileNumberFocus);
                          },
                          validator: (value) {
                            var text = value.trim();

                            if (value == null || text.isEmpty) {
                              return LocaleKeys.please_enter_your_house_number
                                  .tr();
                            }
                            return null;
                          },
                          decoration: new InputDecoration(
                            labelText: LocaleKeys.house_number.tr(),
                          ),
                          controller: _houseNumberController,
                        ),
                      ],
                    )),
                Container(
                    padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          keyboardType: TextInputType.phone,
                          focusNode: _mobileNumberFocus,
                          onFieldSubmitted: (v) {
                            FocusScope.of(context)
                                .requestFocus(_emailAddressFocus);
                          },
                          validator: (value) {
                            var text = value.trim();

                            if (value == null ||
                                text.isEmpty ||
                                !RegExp(r"^\+[1-9]{1}[0-9 ]{3,14}$")
                                    .hasMatch(text)) {
                              return LocaleKeys.please_enter_your_mobile_number
                                  .tr();
                            }
                            return null;
                          },
                          decoration: new InputDecoration(
                            labelText: LocaleKeys.mobile_number.tr(),
                          ),
                          controller: _mobileNumberController,
                        ),
                      ],
                    )),
                Container(
                    padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          keyboardType: TextInputType.emailAddress,
                          focusNode: _emailAddressFocus,
                          onFieldSubmitted: (v) async {
                            await _saveSettings();
                          },
                          validator: (value) {
                            var text = value.trim();

                            if (value == null ||
                                text.isEmpty ||
                                !RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                    .hasMatch(text)) {
                              return LocaleKeys.please_enter_your_email_address
                                  .tr();
                            }
                            return null;
                          },
                          decoration: new InputDecoration(
                            labelText: LocaleKeys.email_address.tr(),
                          ),
                          controller: _emailAddressController,
                        ),
                      ],
                    )),
              ],
            )),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
        child: ElevatedButton(
          child: Text(LocaleKeys.save.tr()),
          onPressed: _saveSettings,
        ),
      ),
    );
  }

  _nameValidator(String value) {
    if (value == null || value.isEmpty || value.length == 0) {
      return LocaleKeys.please_enter_some_text.tr();
    }

    return null;
  }

  Future<void> _selectDate(BuildContext context) async {
    FocusScope.of(context).unfocus();

    final DateTime pickedDate = await showDatePicker(
        context: context,
        initialDate: _currentDateOfBirth,
        firstDate:
            DateTime.now().subtract(Duration(days: 31 * 12 * 150)), // 150 years
        lastDate: DateTime.now());

    if (pickedDate != null && pickedDate != _currentDateOfBirth)
      setState(() {
        final DateFormat formatter = DateFormat('dd.MM.yyyy');
        _dateOfBirthController.text = formatter.format(pickedDate);
        _currentDateOfBirth = pickedDate;
      });
  }

  _applyUserSettings(UserSettings userSettings) {
    _firstNameController.text = userSettings.firstName;
    _lastNameController.text = userSettings.lastName;
    _dateOfBirthController.text = userSettings.dateOfBirth;
    _socialSecurityNumberController.text = userSettings.socialSecurityNumber;
    _postalCodeController.text = userSettings.postalCode;
    _cityController.text = userSettings.city;
    _streetController.text = userSettings.street;
    _houseNumberController.text = userSettings.houseNumber;
    _mobileNumberController.text = userSettings.mobileNumber;
    _emailAddressController.text = userSettings.emailAddress;
  }

  _saveSettings() async {
    if (_formKey.currentState.validate()) {
      var userSettings = UserSettings();
      userSettings.firstName = _firstNameController.text.trim();
      userSettings.lastName = _lastNameController.text.trim();
      userSettings.dateOfBirth = _dateOfBirthController.text.trim();
      userSettings.socialSecurityNumber =
          _socialSecurityNumberController.text.trim();
      userSettings.postalCode = _postalCodeController.text.trim();
      userSettings.city = _cityController.text.trim();
      userSettings.street = _streetController.text.trim();
      userSettings.houseNumber = _houseNumberController.text.trim();
      userSettings.mobileNumber = _mobileNumberController.text.trim();
      userSettings.emailAddress = _emailAddressController.text.trim();

      if (await Settings.setUserDefinedSettings(userSettings)) {
        _applyUserSettings(userSettings);

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(LocaleKeys.saved.tr()),
            backgroundColor: Colors.green));

        return;
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(LocaleKeys.at_least_one_input_is_missing.tr()),
        backgroundColor: Colors.red));
  }
}
