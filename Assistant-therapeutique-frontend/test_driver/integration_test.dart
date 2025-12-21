// Integration test driver for web visual testing.
// This file is needed for flutter drive to work.
// Run with: flutter drive --driver=test_driver/integration_test.dart --target=integration_test/login_test.dart -d chrome

import 'package:integration_test/integration_test_driver.dart';

Future<void> main() => integrationDriver();
