// lib/tool/hooks/pre_commit.dart
import 'dart:io';

Future<void> main() async {
  final Directory hooksDir = Directory('.git/hooks');
  if (!hooksDir.existsSync()) {
    stderr.writeln('❌ .git/hooks not found. Is this a Git repo?');
    exit(1);
  }

  // POSIX hook (macOS/Linux/Git-Bash)
  final File shHook = File('${hooksDir.path}/pre-commit');
  await shHook.writeAsString('''#!/bin/sh
echo "Running pre-commit..."
# Ensure the package is available (dev_dependency or globally activated)
dart run dart_pre_commit
''');
  if (!Platform.isWindows) {
    await Process.run('chmod', <String>['a+x', shHook.path]);
  }

  // Windows CMD hook
  final File batHook = File('${hooksDir.path}/pre-commit.bat');
  await batHook.writeAsString(r'''@echo off
echo Running pre-commit...
dart run dart_pre_commit
if %errorlevel% neq 0 exit /b %errorlevel%
''');

  print('✅ Git pre-commit hooks installed (POSIX + Windows).');
}
