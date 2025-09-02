import 'dart:io';

void main() {
  final Directory imageDir = Directory('assets/images');

  if (!imageDir.existsSync()) {
    print('📁 No assets/images directory found.');
    exit(0); // Exit cleanly
  }

  final List<File> filesWithUppercase = imageDir
      .listSync(recursive: true)
      .whereType<File>()
      .where(
        (File f) => RegExp(
          r'[A-Z]',
        ).hasMatch(f.path.split(Platform.pathSeparator).last),
      )
      .toList();

  if (filesWithUppercase.isEmpty) {
    print('✅ No capitalized image filenames found.');
    exit(0);
  }

  print('⚠️ Found asset files with uppercase letters. Renaming:');

  for (final File file in filesWithUppercase) {
    final String originalPath = file.path;
    final String fileName = originalPath.split(Platform.pathSeparator).last;
    final String directory = file.parent.path;

    final String lowerName = fileName.toLowerCase();
    final String lowerPath = '$directory${Platform.pathSeparator}$lowerName';
    final String tempPath = '$lowerPath.tmp';

    print(' - $fileName → $lowerName');

    // Use git mv twice to force rename on case-insensitive FS
    final ProcessResult mvTemp = Process.runSync('git', <String>[
      'mv',
      originalPath,
      tempPath,
    ]);
    if (mvTemp.exitCode != 0) {
      stderr.writeln('❌ Failed to rename to temp: $originalPath → $tempPath');
      stderr.writeln(mvTemp.stderr);
      exit(1);
    }

    final ProcessResult mvFinal = Process.runSync('git', <String>[
      'mv',
      tempPath,
      lowerPath,
    ]);
    if (mvFinal.exitCode != 0) {
      stderr.writeln('❌ Failed to rename to final: $tempPath → $lowerPath');
      stderr.writeln(mvFinal.stderr);
      exit(1);
    }
  }

  print('\n✅ Renamed files. Please review changes and re-commit.');
  exit(1); // Prevent commit; renames require manual review
}
