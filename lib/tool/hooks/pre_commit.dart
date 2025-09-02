// lib/tool/hooks/pre_commit.dart
import 'dart:io';

void main() {
  run('Fix asset casing', <String>['tool/hooks/fix_asset_casing.dart']);
  run('Analyze', <String>['analyze']);
  run('Run tests', <String>['test']);
  run('Check formatting', <String>['format', '--set-exit-if-changed']);
}

void run(String title, List<String> args) {
  print('\n🔍 Running $title...');

  final ProcessResult result = Process.runSync(
    'dart',
    args,
    environment: <String, String>{
      // Add custom environment variables if needed
    },
  );

  stdout.write(result.stdout);
  stderr.write(result.stderr);

  if (result.exitCode != 0) {
    print('❌ $title failed. Stopping commit.');
    exit(result.exitCode);
  }

  print('✅ $title passed.');
}
