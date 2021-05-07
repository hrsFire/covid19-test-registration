# covid19_test_registration

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://flutter.dev/docs/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://flutter.dev/docs/cookbook)

For help getting started with Flutter, view our
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Building the app for the PlayStore
[How to publish to the PlayStore](https://flutter.dev/docs/deployment/android)

First the user has to generate a certificate:
```bash
keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

Afterwards create a file named [project]/android/key.properties that contains a reference to your keystore (Warning: Keep the key.properties file private; don’t check it into public source control.):
```text
storePassword=<password from previous step>
keyPassword=<password from previous step>
keyAlias=upload
storeFile=<location of the key store file, such as /Users/<user name>/upload-keystore.jks>

```


If everything has been set up the following command can be used to generate an aab file:
```bash
flutter build appbundle
```

The final file can be found in the following directory:
[project]/build/app/outputs/bundle/release/app.aab
