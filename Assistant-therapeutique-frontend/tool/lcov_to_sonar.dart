import 'dart:io';

/// Converts LCOV coverage format to SonarQube Generic Test Coverage format
/// 
/// Usage: dart run tool/lcov_to_sonar.dart
/// 
/// This reads coverage/lcov.info and outputs coverage/sonar-coverage.xml

void main() {
  final lcovFile = File('coverage/lcov.info');
  final outputFile = File('coverage/sonar-coverage.xml');

  if (!lcovFile.existsSync()) {
    print('Error: coverage/lcov.info not found!');
    print('Run: flutter test --coverage');
    exit(1);
  }

  final lcovContent = lcovFile.readAsStringSync();
  final sonarXml = convertLcovToSonar(lcovContent);
  
  outputFile.writeAsStringSync(sonarXml);
  print('Generated: coverage/sonar-coverage.xml');
}

String convertLcovToSonar(String lcovContent) {
  final buffer = StringBuffer();
  buffer.writeln('<?xml version="1.0" encoding="UTF-8"?>');
  buffer.writeln('<coverage version="1">');

  String? currentFile;
  final lines = <String, int>{};

  for (final line in lcovContent.split('\n')) {
    if (line.startsWith('SF:')) {
      // Save previous file if exists
      if (currentFile != null && lines.isNotEmpty) {
        _writeFileElement(buffer, currentFile, lines);
        lines.clear();
      }
      // Start new file - convert Windows paths to forward slashes
      // Prefix with frontend folder so paths match sonar.sources
      var filePath = line.substring(3).replaceAll('\\', '/');
      currentFile = 'Assistant-therapeutique-frontend/$filePath';
    } else if (line.startsWith('DA:')) {
      // DA:lineNumber,hitCount
      final parts = line.substring(3).split(',');
      if (parts.length >= 2) {
        final lineNum = parts[0];
        final hits = int.tryParse(parts[1]) ?? 0;
        lines[lineNum] = hits;
      }
    } else if (line == 'end_of_record') {
      if (currentFile != null && lines.isNotEmpty) {
        _writeFileElement(buffer, currentFile, lines);
        lines.clear();
      }
      currentFile = null;
    }
  }

  buffer.writeln('</coverage>');
  return buffer.toString();
}

void _writeFileElement(StringBuffer buffer, String filePath, Map<String, int> lines) {
  buffer.writeln('  <file path="$filePath">');
  for (final entry in lines.entries) {
    final covered = entry.value > 0 ? 'true' : 'false';
    buffer.writeln('    <lineToCover lineNumber="${entry.key}" covered="$covered"/>');
  }
  buffer.writeln('  </file>');
}
