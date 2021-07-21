# db_test_coverage

test coverage tool for dart, flutter.

## Overview

A command-line tool that run tests with coverage on a project.

It’s help you automate verification that your project code coverage meet your expected standard.

[license](https://github.com/bitsydarel/db_test_coverage/blob/master/LICENSE).

<br>

## Installation

db_test_coverage is dependent on lcov being installed.

So first install lcov.

### MacOS

```shell
brew install lcov
```

### Linux

```shell
apt install lcov
```

After, installing lcov you can run.

```bash
pub global activate db_test_coverage
```
<br>
<br>

## Usage
```shell
test_coverage --package-name example <local project directory>
```

```shell
Options:
--project-type                        Specify the type of project the script is run on

      [flutter] (default)             Test coverage for flutter project

--package-name (mandatory)            Specify the package name of this project
--src-dir                             Specify the src directory of this project
                                      (defaults to "lib/src")
--test-dir                            Specify the test directory of this project
                                      (defaults to "test")
--coverage-dir-path                   Specify the test coverage directory of this project
                                      (defaults to ".test_coverage")
--coverage-exclude=<lib/**.g.dart>    Specify the file pattern from the coverage report

--min-cov                             Specify the minimum coverage percentage of code coverage allowed, from 0.0 to 1.0
                                      (defaults to "0.0")
--[no-]help                           Print help message
```

### Run db_test_coverage and check if code coverage is at least 70%

```shell
test_coverage --package-name example --min-cov 0.7 <local project directory>
```

### Run db_test_coverage but removed unneeded files from the code coverage report.

```shell
test_coverage --package-name example --coverage-exclude 'lib/src/*.g.dar', 'lib/generated_plugin_registrant.dart' <local project directory>
```

<br>