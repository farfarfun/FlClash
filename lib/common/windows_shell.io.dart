import 'dart:ffi';

import 'package:ffi/ffi.dart';

final _shell32 = DynamicLibrary.open('shell32.dll');

/// ShellExecuteW's raw return value: anything at or below 32 is a failure code.
int shellExecuteRunas(String command, String arguments, int showCmd) {
  final commandPtr = command.toNativeUtf16();
  final argumentsPtr = arguments.toNativeUtf16();
  final operationPtr = 'runas'.toNativeUtf16();

  final shellExecute = _shell32
      .lookupFunction<
        Int32 Function(
          Pointer<Utf16> hwnd,
          Pointer<Utf16> lpOperation,
          Pointer<Utf16> lpFile,
          Pointer<Utf16> lpParameters,
          Pointer<Utf16> lpDirectory,
          Int32 nShowCmd,
        ),
        int Function(
          Pointer<Utf16> hwnd,
          Pointer<Utf16> lpOperation,
          Pointer<Utf16> lpFile,
          Pointer<Utf16> lpParameters,
          Pointer<Utf16> lpDirectory,
          int nShowCmd,
        )
      >('ShellExecuteW');

  final result = shellExecute(
    nullptr,
    operationPtr,
    commandPtr,
    argumentsPtr,
    nullptr,
    showCmd,
  );

  calloc.free(commandPtr);
  calloc.free(argumentsPtr);
  calloc.free(operationPtr);

  return result;
}
