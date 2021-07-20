import 'dart:io';

import 'package:db_test_coverage/src/configuration.dart';
import 'package:db_test_coverage/src/exceptions.dart';
import 'package:io/io.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as path;

///
class CoveragePatcher {
  ///
  final Configuration configuration;

  ///
  const CoveragePatcher(this.configuration);

  ///
  Future<String> generatePatchFile() async {
    final List<String> imports = getDartFileImports();

    final String pathFileContent = generatePatchFileContent(imports);

    final File pathFile = File(
      '${configuration.testDirPath}/coverage_patch.dart',
    )..createSync();

    if (!pathFile.existsSync()) {
      throw UnrecoverableException(
        'Could not create patch file',
        ExitCode.ioError.code,
      );
    }

    pathFile.writeAsStringSync(pathFileContent);

    return pathFile.path;
  }

  ///
  Future<void> cleanupPatchFile() async {
    final File patchFile = File(
      '${configuration.testDirPath}/coverage_patch.dart',
    );

    if (!patchFile.existsSync()) {
      throw UnrecoverableException(
        'Coverage patch  not founded in directory ${configuration.testDirPath}',
        ExitCode.config.code,
      );
    }

    patchFile.deleteSync();
  }

  ///
  @visibleForTesting
  List<String> getDartFileImports() {
    final List<String> imports = <String>[];

    final Directory srcDirectory = Directory(configuration.srcDirPath);

    final List<FileSystemEntity> files = srcDirectory.listSync(recursive: true);

    for (final FileSystemEntity file in files) {
      final String filename = path.basename(file.path);

      if (!filename.endsWith('g.dart') && filename.endsWith('dart')) {
        final String packagePath = file.path.replaceFirst(
          srcDirectory.path,
          '',
        );

        imports.add(
          "import 'package:${configuration.packageName}/${configuration.srcDirPath.replaceFirst('lib/', '')}$packagePath';",
        );
      }
    }

    return imports;
  }

  ///
  @visibleForTesting
  String generatePatchFileContent(List<String> imports) {
    final StringBuffer template = StringBuffer()
      ..writeln('// Coverage path file.')
      ..writeln(
        '// Helper file to include all the source code '
        'into coverage report',
      )
      ..writeln()
      ..writeln('// ignore_for_file: unused_import')
      ..writeln();

    imports.forEach(template.writeln);

    template..writeln()..writeln('void main(){}');

    return template.toString();
  }
}
