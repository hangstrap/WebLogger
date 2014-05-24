import 'dart:async';
import 'package:unittest/unittest.dart';
import 'package:web_logger/web_logger_handler.dart';
import 'package:logging/logging.dart';
import 'package:mock/mock.dart';
import 'package:jsonx/jsonx.dart' as Json;
import 'dart:html';

class MockWebSocket extends Mock implements WebSocket {
  Stream<Event> onOpen;
}

void main() {
  LogRecord lastRecord;

  Logger.root.level = Level.ALL;
  Logger log = new Logger("myLogger");
  //Catch the last log record to make testing easier
  Logger.root.onRecord.listen((r) => lastRecord = r);


  group("When the socket is opened ", () {
    WebLoggerHandler underTest;
    MockWebSocket webSocket;


    setUp(() {
      webSocket = new MockWebSocket();
      //fire the onOpen event
      webSocket.onOpen = new Stream.fromFuture(new Future.value(new Event("onOpen")));
      underTest = new WebLoggerHandler.createforTest(webSocket, "NameOfSession");
    });
    test("it should send the sessionID to the server", () {

      String message = Json.encode(new Message("sessionID", "NameOfSession"));

      return new Future.value().then((_) {
        print("BBBB");
        webSocket.getLogs(callsTo("sendString", message)).verify(happenedExactly(1));
        print("CCCC");
      });

    });
    //    test("should send any log records to the server",(){
    //      log.info( "a message");
    //      webSocket.getLogs( callsTo("send", lastRecord)).verify( happenedExactly(1));
    //    });


  });
}

