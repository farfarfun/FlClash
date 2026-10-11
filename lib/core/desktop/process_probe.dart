import 'dart:io';

import 'process_probe.io.dart'
    if (dart.library.js_interop) 'process_probe.web.dart';

typedef ProcessLivenessProbe = Future<bool> Function(int pid);

/// A recycled pid reads as alive, which delays a confirmation but never fakes one.
Future<bool> isProcessAlive(int pid) async {
  if (pid <= 0) {
    return false;
  }
  if (Platform.isWindows) {
    return isWindowsProcessAlive(pid);
  }
  if (Platform.isLinux) {
    return _isLinuxProcessAlive(pid);
  }
  final result = await Process.run('ps', ['-o', 'stat=', '-p', '$pid']);
  final state = (result.stdout as String).trim();
  return result.exitCode == 0 && state.isNotEmpty && !state.startsWith('Z');
}

Future<bool> _isLinuxProcessAlive(int pid) async {
  final String stat;
  try {
    stat = await File('/proc/$pid/stat').readAsString();
  } on FileSystemException {
    return false;
  }
  final state = stat.substring(stat.lastIndexOf(')') + 1).trim();
  return state.isNotEmpty && state[0] != 'Z' && state[0] != 'X';
}
