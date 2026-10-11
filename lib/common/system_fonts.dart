import 'dart:io';
import 'dart:isolate';

import 'package:fl_clash/enum/enum.dart';
import 'package:flutter/foundation.dart' show visibleForTesting;

import 'print.dart';
import 'system_fonts.io.dart'
    if (dart.library.js_interop) 'system_fonts.web.dart';

@visibleForTesting
Future<List<String>> Function() systemFontFamiliesReader = () =>
    Isolate.run(_readSystemFontFamilies);

/// The font families the engine resolves by name on this host, each listed
/// through the API the engine itself matches names against.
Future<List<String>> loadSystemFontFamilies() async {
  try {
    return await systemFontFamiliesReader();
  } catch (e) {
    commonPrint.log('loadSystemFontFamilies: $e', logLevel: LogLevel.warning);
    return const [];
  }
}

List<String> _readSystemFontFamilies() {
  return sortFontFamilies(switch (Platform.operatingSystem) {
    'macos' => coreTextFamilies(),
    'windows' => directWriteFamilies(),
    'linux' => fontconfigFamilies(),
    'android' => androidFontFamilies(
      File('/system/etc/fonts.xml').readAsStringSync(),
    ),
    _ => const <String>[],
  });
}

@visibleForTesting
List<String> sortFontFamilies(Iterable<String> families) {
  final unique = <String, String>{};
  for (final family in families) {
    final name = family.trim();
    if (name.isEmpty || name.startsWith('.')) {
      continue;
    }
    unique.putIfAbsent(name.toLowerCase(), () => name);
  }
  return unique.values.toList()
    ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
}

@visibleForTesting
List<String> androidFontFamilies(String fontsXml) => [
  for (final match in RegExp(
    r'<family\b[^>]*\bname="([^"]+)"',
  ).allMatches(fontsXml))
    match.group(1)!,
];
