
import 'package:unittest/unittest.dart';
import 'package:web_logger/web_logger_handler.dart';
import 'package:logging/logging.dart';
import 'package:mock/mock.dart';

import 'dart:html';

class MockWebSocket extends Mock implements WebSocket{}

void main(){
  LogRecord lastRecord;
  
  Logger.root.level = Level.ALL;
  Logger log = new  Logger( "myLogger");
  //Catch the last log record to make testing easier
  Logger.root.onRecord.listen( (r)=> lastRecord = r );
  
  
  group("WebLoggerHandler", (){
    WebLoggerHandler underTest;
    MockWebSocket webSocket;
    
    
    setUp((){
      webSocket = new MockWebSocket();
      underTest = new WebLoggerHandler.createforTest( webSocket, "sessionID");
    });
    test("should send the sessionId to the server",(){
      webSocket.getLogs( callsTo("send", "sessionID")).verify( happenedExactly(1));
    });
    test("should send any log records to the server",(){      
      
      log.info( "a message");   
      webSocket.getLogs( callsTo("send", lastRecord)).verify( happenedExactly(1)); 
    });
    
    
  });
}