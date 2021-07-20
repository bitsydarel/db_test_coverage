A command-line tool that run tests with coverage on a project.

```shell
Usage: test_coverage --package-name example --project-type [flutter] <local project directory>
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
