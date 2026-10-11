import 'package:win32_registry/win32_registry.dart';

/// A missing key, a missing value and a denied read all answer null.
int? readLocalMachineInt(String keyPath, String valueName) {
  try {
    final key = LOCAL_MACHINE.open(keyPath);
    try {
      return key.getInt(valueName);
    } finally {
      key.close();
    }
  } catch (_) {
    return null;
  }
}

void writeCurrentUserProtocol({
  required String protocolKey,
  required String protocolValueName,
  required String protocolValue,
  required String commandKey,
  required String command,
}) {
  final regKey = CURRENT_USER.create(protocolKey);
  try {
    regKey.setValue(protocolValueName, RegistryValue.string(protocolValue));
    final subKey = regKey.create(commandKey);
    try {
      subKey.setValue('', RegistryValue.string(command));
    } finally {
      subKey.close();
    }
  } finally {
    regKey.close();
  }
}
