
import 'package:web_logger/web_logger_handler.dart';
import 'package:logging/logging.dart';

void main() {

  Logger.root.level = Level.ALL;
  Logger log = new Logger("myLogger");
  Logger.root.onRecord.listen((r) => print("${r.level} ${r.loggerName} ${r.message}"));
  log.info( "hello world");

  WebLoggerHandler underTest;
  String hostUrl = 'ws://${Uri.base.host}:${Uri.base.port}/ws';
  print( hostUrl);
  underTest = new WebLoggerHandler(hostUrl, "sessionID");
}
