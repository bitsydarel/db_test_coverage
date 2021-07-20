///
const String coverageFileName = 'lcov.info';

///
class Configuration {
  ///
  final String projectDirPath;

  ///
  final ProjectType projectType;

  ///
  final String packageName;

  ///
  final String srcDirPath;

  ///
  final String testDirPath;

  ///
  final String coverageOutputDirPath;

  ///
  final List<String> excludes;

  ///
  final double minCodeCoverageAllowed;

  ///
  const Configuration({
    required this.projectDirPath,
    required this.projectType,
    required this.packageName,
    required this.srcDirPath,
    required this.testDirPath,
    required this.coverageOutputDirPath,
    required this.excludes,
    required this.minCodeCoverageAllowed,
  });
}

///
enum ProjectType {
  ///
  flutter
}
