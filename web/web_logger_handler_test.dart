import 'package:web_logger/web_logger_handler.dart';
import 'package:logging/logging.dart';
import 'dart:async';
import 'dart:html';

void main() {
  
  
  Element paragraph = querySelector("#text");

  Logger.root.level = Level.ALL;
  Logger log = new Logger("myLogger");
  Logger.root.onRecord.listen((r) {
    
    print("${r.level} ${r.loggerName} ${r.message}");    
    paragraph.appendHtml ( "<br id='logMessage'>${r.toString()}<br/>");
  });
  log.info("hello world");

  WebLoggerHandler underTest;
  String hostUrl = 'ws://localhost:8421/ws';
  print(hostUrl);
  underTest = new WebLoggerHandler(hostUrl, "sessionID");

  new Timer.periodic(new Duration(seconds: 15), (Timer t) {

    log.info("a logging message ${new DateTime.now()}");
  });
}
