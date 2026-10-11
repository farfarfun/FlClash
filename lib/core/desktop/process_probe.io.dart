import 'dart:ffi';

import 'package:ffi/ffi.dart';

const _processQueryLimitedInformation = 0x1000;
const _errorInvalidParameter = 87;
const _stillActive = 259;

// A Helper-spawned Core belongs to SYSTEM; OpenProcess fails with
// ERROR_INVALID_PARAMETER only when no such process exists.
bool isWindowsProcessAlive(int pid) {
  final kernel32 = DynamicLibrary.open('kernel32.dll');
  final openProcess = kernel32
      .lookupFunction<
        Pointer<Void> Function(Uint32, Int32, Uint32),
        Pointer<Void> Function(int, int, int)
      >('OpenProcess');
  final getLastError = kernel32
      .lookupFunction<Uint32 Function(), int Function()>('GetLastError');
  final getExitCodeProcess = kernel32
      .lookupFunction<
        Int32 Function(Pointer<Void>, Pointer<Uint32>),
        int Function(Pointer<Void>, Pointer<Uint32>)
      >('GetExitCodeProcess');
  final closeHandle = kernel32
      .lookupFunction<
        Int32 Function(Pointer<Void>),
        int Function(Pointer<Void>)
      >('CloseHandle');

  final handle = openProcess(_processQueryLimitedInformation, 0, pid);
  if (handle == nullptr) {
    return getLastError() != _errorInvalidParameter;
  }
  final exitCode = calloc<Uint32>();
  try {
    if (getExitCodeProcess(handle, exitCode) == 0) {
      return true;
    }
    return exitCode.value == _stillActive;
  } finally {
    calloc.free(exitCode);
    closeHandle(handle);
  }
}
