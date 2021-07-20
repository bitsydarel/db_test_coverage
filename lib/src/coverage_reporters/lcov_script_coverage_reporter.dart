import 'dart:io';

import 'package:db_test_coverage/db_test_coverage.dart';
import 'package:db_test_coverage/src/configuration.dart';
import 'package:db_test_coverage/src/coverage_reporter.dart';
import 'package:db_test_coverage/src/shell_runner.dart';
import 'package:io/io.dart';
import 'package:meta/meta.dart';

///
class LcovScriptCoverageReporter extends CoverageReporter {
  ///
  final ShellRunner runner;

  ///
  const LcovScriptCoverageReporter({
    required Configuration configuration,
    this.runner = const ShellRunner(),
  }) : super(configuration: configuration);

  @override
  Future<String> generateReport() async {
    if (configuration.excludes.isNotEmpty) {
      filterCoverageReport(configuration.excludes);
    }

    final ShellOutput output = runner.execute(
      'genhtml',
      <String>[
        '${configuration.coverageOutputDirPath}/$coverageFileName',
        '-o',
        configuration.coverageOutputDirPath,
      ],
    );

    if (output.stderr.isNotEmpty) {
      throw UnrecoverableException(output.stderr, ExitCode.tempFail.code);
    }

    stdout.writeln(output.stdout);

    return '${configuration.coverageOutputDirPath}/index.html';
  }

  @override
  Future<double> overallTestCoverage() async {
    if (configuration.excludes.isNotEmpty) {
      filterCoverageReport(configuration.excludes);
    }

    final File coverageFile = File(
      '${configuration.coverageOutputDirPath}/$coverageFileName',
    );

    final List<String> lines = coverageFile.readAsLinesSync();

    final List<double> coverage = lines.fold(
      <double>[0, 0],
      (List<double> previousValue, String line) {
        double testedLines = previousValue[0];
        double totalLines = previousValue[1];

        if (line.startsWith('DA')) {
          totalLines++;

          if (!line.endsWith('0')) {
            testedLines++;
          }
        }
        return <double>[testedLines, totalLines];
      },
    );

    final double testedLines = coverage[0];
    final double totalLines = coverage[1];

    return testedLines / totalLines;
  }

  ///
  @visibleForTesting
  void filterCoverageReport(List<String> excludes) {
    final String coverageFilePath =
        '${configuration.coverageOutputDirPath}/$coverageFileName';

    final ShellOutput filterOutput = runner.execute(
      'lcov',
      <String>[
        '--remove',
        coverageFilePath,
        ...excludes.map((String exclude) => "'$exclude'"),
        '-o',
        coverageFilePath,
      ],
    );

    if (filterOutput.stderr.isNotEmpty) {
      throw UnrecoverableException(filterOutput.stderr, ExitCode.tempFail.code);
    }
  }
}
