import 'package:covid19_test_registration/services/test_date.dart';
import 'package:covid19_test_registration/services/test_location.dart';

class TestLocationWithDates extends TestLocation {
  List<TestDate> testDates;

  TestLocationWithDates();

  TestLocationWithDates.clone(TestLocationWithDates self) {
    this.key = self.key;
    this.value = self.value;
    this.testDates = self.testDates;
  }
}
