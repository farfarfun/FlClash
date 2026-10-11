import 'package:drift/drift.dart';

// drift does run on the web, but through WasmDatabase, which needs sqlite3.wasm
// and drift_worker.js shipped under web/. Until those are in place the build
// compiles and the first query says so, rather than faking a store.
QueryExecutor openDatabaseConnection() {
  throw UnsupportedError('the web build has no database backend yet');
}
