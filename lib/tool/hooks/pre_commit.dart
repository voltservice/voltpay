// lib/tool/hooks/pre_commit.dart
import 'dart:io';

void main() {
  run('Generate mocks', <String>[
    'dart',
    'run',
    'build_runner',
    'build',
    '--delete-conflicting-outputs',
  ]);
  run('Analyze', <String>['flutter', 'analyze']);
  run('Run tests', <String>[
    'flutter',
    'test',
    '--no-pub',
  ]); // <-- use flutter here
  run('Check formatting', <String>['dart', 'format', '.']);
}

void run(String title, List<String> cmdAndArgs) {
  final String cmd = cmdAndArgs.first;
  final List<String> args = cmdAndArgs.sublist(1);
  print('\n🔍 Running $title...');

  final ProcessResult result = Process.runSync(cmd, args, runInShell: true);

  stdout.write(result.stdout);
  stderr.write(result.stderr);

  if (result.exitCode != 0) {
    print('❌ $title failed. Stopping commit.');
    exit(result.exitCode);
  }

  print('✅ $title passed.');
}
