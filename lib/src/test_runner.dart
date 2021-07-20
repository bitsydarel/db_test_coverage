import 'package:db_test_coverage/src/configuration.dart';
import 'package:db_test_coverage/src/shell_runner.dart';

///
abstract class TestRunner {
  ///
  final Configuration configuration;

  ///
  final ShellRunner runner;

  ///
  const TestRunner({required this.configuration, required this.runner});

  ///
  Future<void> execute();
}
