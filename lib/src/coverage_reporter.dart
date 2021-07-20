import 'package:db_test_coverage/src/configuration.dart';

///
abstract class CoverageReporter {
  ///
  final Configuration configuration;

  ///
  const CoverageReporter({required this.configuration});

  ///
  Future<String> generateReport();

  ///
  Future<double> overallTestCoverage();
}
