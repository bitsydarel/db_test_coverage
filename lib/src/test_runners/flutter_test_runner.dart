import 'dart:io';

import 'package:db_test_coverage/src/configuration.dart';
import 'package:db_test_coverage/src/exceptions.dart';
import 'package:db_test_coverage/src/shell_runner.dart';
import 'package:db_test_coverage/src/test_runner.dart';
import 'package:io/io.dart';

///
class FlutterTestRunner extends TestRunner {
  ///
  FlutterTestRunner(
    Configuration configuration, {
    ShellRunner runner = const ShellRunner(),
  }) : super(configuration: configuration, runner: runner);

  @override
  Future<void> execute() async {
    final ShellOutput testResult = runner.execute(
      'flutter',
      <String>[
        'test',
        '--coverage',
        '--coverage-path',
        '${configuration.coverageOutputDirPath}/$coverageFileName',
        configuration.testDirPath,
      ],
    );

    if (testResult.stderr.isNotEmpty) {
      throw UnrecoverableException(testResult.stderr, ExitCode.tempFail.code);
    }

    stdout.writeln(testResult.stdout);
  }
}
