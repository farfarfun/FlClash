import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:fl_clash/common/path.dart';

QueryExecutor openDatabaseConnection() {
  return LazyDatabase(() async {
    final databaseFile = File(await appPath.databasePath);
    return NativeDatabase.createInBackground(databaseFile);
  });
}
