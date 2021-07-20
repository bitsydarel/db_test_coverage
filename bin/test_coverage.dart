import 'dart:async';
import 'dart:io';

import 'package:args/args.dart';
import 'package:db_test_coverage/db_test_coverage.dart';
import 'package:io/io.dart';

///
Future<void> main(List<String> arguments) async {
  ArgResults argResults;

  try {
    argResults = argumentParser.parse(arguments);
  } on Exception catch (e) {
    printHelpMessage(e is FormatException ? e.message : null);
    return;
  }

  if (argResults.wasParsed(helpArgument)) {
    printHelpMessage();
    exitCode = 0;
    return;
  }

  await runZonedGuarded<Future<void>>(
    () async {
      final Configuration configuration = argResults.toConfiguration();

      // save previous pwd so we can get back to location where the script
      // was executed.
      final Directory previousPwd = Directory.current;

      Directory.current = configuration.projectDirPath;

      final CoveragePatcher patcher = CoveragePatcher(configuration);

      if (configuration.projectType == ProjectType.flutter) {
        final String patchFilePath = await patcher.generatePatchFile();

        stdout.writeln('Patch file generated at: $patchFilePath\n');
      }

      final TestRunner testRunner = FlutterTestRunner(configuration);

      await testRunner.execute();

      stdout.writeln(
        '$coverageFileName file generated '
        'at: ${configuration.coverageOutputDirPath}\n',
      );

      await patcher.cleanupPatchFile();

      stdout.writeln('Patch file cleaned up after code coverage generation\n');

      final LcovScriptCoverageReporter reporter =
          LcovScriptCoverageReporter(configuration: configuration);

      if (configuration.enableHtmlReport) {
        final String reportFilePath = await reporter.generateReport();

        stdout.writeln('Detailed code coverage report: $reportFilePath');
      }

      if (configuration.excludes.isNotEmpty) {
        stdout.writeln(
          'Excluded from the report, files matching : '
          '${configuration.excludes.join(', ')}\n',
        );
      }

      final double overallTestCoverage = await reporter.overallTestCoverage();

      if (overallTestCoverage < configuration.minCodeCoverageAllowed) {
        throw UnrecoverableException(
          '${(overallTestCoverage * 100).toStringAsFixed(1)}% code coverage '
          'is lower than the minimum allowed of '
          '${(configuration.minCodeCoverageAllowed * 100).toStringAsFixed(1)}%',
          exitCode,
        );
      }

      Directory.current = previousPwd;
    },
    (Object error, StackTrace stack) {
      if (error is UnrecoverableException) {
        stderr.writeln(error.reason);
        exitCode = error.exitCode;
        exit(exitCode);
      } else {
        printHelpMessage(error.toString());
        exitCode = ExitCode.software.code;
        exit(exitCode);
      }
    },
  );
}
