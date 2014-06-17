
import 'dart:io';

import 'package:route/server.dart' show Router;
import 'package:logging/logging.dart' show Logger, Level, LogRecord;
import 'package:web_logger/web_logger_server.dart';



void main() {


  int port = 8421;  // TODO use args from command line to set this

  HttpServer.bind(InternetAddress.LOOPBACK_IP_V4, port).then((server) {
    
    print("server is running on 'http://${server.address.address}:$port/'");
    
    createWebSocketRouter( server, "/ws", consoleWebLoggerHandler);
    
  });
}
