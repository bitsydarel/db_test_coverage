import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:db_test_coverage/src/configuration.dart';
import 'package:io/ansi.dart';
import 'package:path/path.dart' as path;

const String _projectTypeArgument = 'project-type';

const String _flutterProjectType = 'flutter';

/// List of project type supported by the script.
const Map<String, ProjectType> _supportedProjectType = <String, ProjectType>{
  _flutterProjectType: ProjectType.flutter,
};

/// Help argument name
const String helpArgument = 'help';

const String _packageNameArgument = 'package-name';

const String _srcDirPathArgument = 'src-dir';

const String _testDirPathArgument = 'test-dir';

const String _coverageOutputDirPathArgument = 'coverage-dir-path';

const String _coverageExclude = 'coverage-exclude';

const String _minCoveragePercent = 'min-cov';

const String _htmlReport = 'html-report';

/// Script argument parser.
final ArgParser argumentParser = ArgParser()
  ..addOption(
    _projectTypeArgument,
    defaultsTo: _flutterProjectType,
    allowed: _supportedProjectType.keys,
    allowedHelp: <String, String>{
      _flutterProjectType: 'Test coverage for flutter project',
    },
    help: 'Specify the type of project the script is run on',
  )
  ..addOption(
    _packageNameArgument,
    help: 'Specify the package name of this project',
    mandatory: true,
  )
  ..addOption(
    _srcDirPathArgument,
    help: 'Specify the src directory of this project',
    defaultsTo: 'lib/src',
  )
  ..addOption(
    _testDirPathArgument,
    help: 'Specify the test directory of this project',
    defaultsTo: 'test',
  )
  ..addOption(
    _coverageOutputDirPathArgument,
    help: 'Specify the test coverage directory of this project',
    defaultsTo: '.test_coverage',
  )
  ..addMultiOption(
    _coverageExclude,
    help: 'Specify the file pattern from the coverage report',
    valueHelp: 'lib/**.g.dart',
  )
  ..addOption(
    _minCoveragePercent,
    help: 'Specify the minimum coverage percentage '
        'of code coverage allowed, from 0.0 to 1.0',
    defaultsTo: '0.0',
  )
  ..addFlag(
    _htmlReport,
    help: 'Generate html report.',
    defaultsTo: true,
  )
  ..addFlag(helpArgument, help: 'Print help message');

/// Print help message to the console.
void printHelpMessage([final String? message]) {
  if (message != null) {
    stderr.writeln(red.wrap('$message\n'));
  }

  final String options =
      LineSplitter.split(argumentParser.usage).map((String l) => l).join('\n');

  stdout.writeln(
    'Usage: test_coverage --$_packageNameArgument example '
    '--$_projectTypeArgument [${_supportedProjectType.keys.join(', ')}] '
    '<local project directory>\nOptions:\n$options',
  );
}

///
extension ArgResultsExtension on ArgResults {
  ///
  Configuration toConfiguration() {
    return Configuration(
      projectDirPath: _parseProjectDir().path,
      projectType: _parseProjectType(),
      packageName: _parseStringArg(_packageNameArgument),
      srcDirPath: _parseStringArg(_srcDirPathArgument),
      testDirPath: _parseStringArg(_testDirPathArgument),
      coverageOutputDirPath: _parseStringArg(_coverageOutputDirPathArgument),
      excludes: _parseExcludes(),
      minCodeCoverageAllowed: _parseMinCodeCoverage(),
      enableHtmlReport: _parseHtmlReport(),
    );
  }

  ProjectType _parseProjectType() {
    final Object? projectType = this[_projectTypeArgument];

    if (projectType is String &&
        _supportedProjectType.containsKey(projectType)) {
      final ProjectType? type = _supportedProjectType[projectType];

      if (type != null) {
        return type;
      }
    }

    throw ArgumentError(
      '$_projectTypeArgument parameter is required, '
      "supported values are ${_supportedProjectType.keys.join(", ")}",
    );
  }

  Directory _parseProjectDir() {
    if (rest.length != 1) {
      throw ArgumentError('invalid project dir path');
    }

    final Directory projectDir = getResolvedProjectDir(rest[0]);

    if (!projectDir.existsSync()) {
      throw ArgumentError('specified local project dir does not exist');
    }

    return projectDir;
  }

  List<String> _parseExcludes() {
    final Object? excludes = this[_coverageExclude];

    if (excludes is List<String>) {
      return excludes;
    }

    throw ArgumentError('$_coverageExclude parameter is required');
  }

  double _parseMinCodeCoverage() {
    final Object? minCodeCoverage = this[_minCoveragePercent];

    if (minCodeCoverage is String && minCodeCoverage.trim().isNotEmpty) {
      return double.parse(minCodeCoverage);
    }

    throw ArgumentError('$_minCoveragePercent parameter is required');
  }

  bool _parseHtmlReport() {
    final Object? enableHtmlReport = this[_htmlReport];

    if (enableHtmlReport is bool) {
      return enableHtmlReport;
    }

    throw ArgumentError('$_htmlReport parameter is required');
  }

  String _parseStringArg(String argumentName) {
    final Object? argumentValue = this[argumentName];

    if (argumentValue is String && argumentValue.trim().isNotEmpty) {
      return argumentValue;
    }

    throw ArgumentError('$argumentName parameter is required');
  }
}

/// Get the project [Directory] with a full path.
Directory getResolvedProjectDir(final String projectDir) {
  return Directory(path.canonicalize(projectDir));
}
