import 'dart:async';
import 'package:unittest/unittest.dart';
import 'package:unittest/html_enhanced_config.dart';

import 'package:web_logger/web_logger_handler.dart';
import 'package:logging/logging.dart';
import 'package:mock/mock.dart';
import 'package:jsonx/jsonx.dart' as Json;
import 'dart:html';

@proxy
class MockWebSocket extends Mock implements WebSocket {
  
  StreamController openStreamController = new StreamController();
  Stream<Event> get onOpen => openStreamController.stream;
  StreamController closeStreamController = new StreamController();
  Stream<Event> get onClose => closeStreamController.stream;
  StreamController errorStreamController = new StreamController();
  Stream<Event> get onError => errorStreamController.stream;
  int readyState;
}


class WebSocketFactory {

  List<MockWebSocket> sockets = [];
  int calls = 0;

  MockWebSocket get lastMockWebSocket => sockets.last;
  
  WebSocket createWebSocket(String url) {
    calls++;
    sockets.add(new MockWebSocket());
    return lastMockWebSocket;
  }
}



void main() {
  useHtmlEnhancedConfiguration();
  LogRecord lastRecord;

  Logger.root.level = Level.ALL;
  Logger log = new Logger("myLogger");
  //Catch the last log record to make testing easier
  Logger.root.onRecord.listen((r) => lastRecord = r);

  group("When the socket is opened ", () {

    WebLoggerHandler underTest;
    WebSocketFactory webSocketFactory;

    setUp(() {
      webSocketFactory = new WebSocketFactory();
      underTest = new WebLoggerHandler.createforTest(webSocketFactory.createWebSocket, "testUrl", "NameOfSession");

      //fire the onOpen event
      webSocketFactory.lastMockWebSocket.openStreamController.add(new Event("onOpen"));
      webSocketFactory.lastMockWebSocket.readyState = WebSocket.OPEN;
    });
    tearDown(() {
      underTest.close();
    });
    test("the web socket should be created with the correct parameter", () {
      expect(webSocketFactory.calls, equals(1));
    });
    test("it should first send the sessionID to the server", () {

      return new Future.value().then((_) {
        String message = Json.encode(new Message("sessionID", "NameOfSession"));
        webSocketFactory.lastMockWebSocket.getLogs(callsTo("sendString", message)).verify(happenedOnce);
      });

    });
    test("it should fire the open event", () {

      Timer t = createDurationTimeout(3);

      underTest.events.first.then(expectAsync((Event e) {
        expect(e.type, equals("webSocketOpened"));
        cancelTimeout(t);
      }));
    });

    test("it should send any log records to the server", () {

      return new Future.value().then((_) {

        log.info("a message");

        String message = Json.encode(new Message("logRecord", lastRecord));
        webSocketFactory.lastMockWebSocket.getLogs(callsTo("sendString", message)).verify(happenedOnce);
      });
    });
    test("it should not send any log records if the socket is in the CONNECTING state", () {

      return new Future.value().then((_) {

        webSocketFactory.lastMockWebSocket.readyState = WebSocket.CONNECTING;
        log.info("not sent");

        String message = Json.encode(new Message("logRecord", lastRecord));
        webSocketFactory.lastMockWebSocket.getLogs(callsTo("sendString", message)).verify(neverHappened);
      });
    });
    test("it should not send any log records if the socket is in the CLOSING state", () {

      return new Future.value().then((_) {

        webSocketFactory.lastMockWebSocket.readyState = WebSocket.CLOSING;
        log.info("not sent");

        String message = Json.encode(new Message("logRecord", lastRecord));
        webSocketFactory.lastMockWebSocket.getLogs(callsTo("sendString", message)).verify(neverHappened);
      });
    });
    test("it should not send any log records if the socket is in the CLOSED state", () {

      return new Future.value().then((_) {

        webSocketFactory.lastMockWebSocket.readyState = WebSocket.CLOSED;
        log.info("not sent");

        String message = Json.encode(new Message("logRecord", lastRecord));
        webSocketFactory.lastMockWebSocket.getLogs(callsTo("sendString", message)).verify(neverHappened);
      });
    });


    group("When the user calls 'close()", () {
      test("the webSockets close() should be called", () {
        underTest.close();
        webSocketFactory.lastMockWebSocket.getLogs(callsTo("close")).verify(happenedOnce);
      });
    });
  });

  group("When an error event occures", () {

    WebLoggerHandler underTest;
    MockWebSocket webSocket;
    WebSocketFactory webSocketFactory;

    setUp(() {

      webSocketFactory = new WebSocketFactory();
      underTest = new WebLoggerHandler.createforTest(webSocketFactory.createWebSocket, "testUrl", "NameOfSession");

      //When the socket is opened, the socket then fires a onError event
      underTest.events.first.then((e) {
        webSocketFactory.lastMockWebSocket.errorStreamController.add(new Event("onError"));
      });
      //Open the socket to get things going
      webSocketFactory.lastMockWebSocket.openStreamController.add(new Event("onOpen"));
      webSocketFactory.lastMockWebSocket.readyState = WebSocket.OPEN;

    });
    tearDown(() {
      underTest.close();
    });

    test("the original websocket.close() should be called", () {

      return new Future.delayed( new Duration( milliseconds:200), (){
        webSocketFactory.sockets.first.getLogs(  callsTo("close")).verify(happenedOnce);
      });
      
    });
    test("a new Socket should be created after the testing reopenDelay of 100 milliseconds", () {
      
      return new Future.delayed( new Duration( milliseconds:200), (){        
        expect(webSocketFactory.calls, equals(2));
      });
    });
  });

  group("When an close event occures", () {

      WebLoggerHandler underTest;
      MockWebSocket webSocket;
      WebSocketFactory webSocketFactory;

      setUp(() {

        webSocketFactory = new WebSocketFactory();
        underTest = new WebLoggerHandler.createforTest(webSocketFactory.createWebSocket, "testUrl", "NameOfSession");

        //When the socket is opened, the socket then fires a onClose event
        underTest.events.first.then((e) {
          webSocketFactory.lastMockWebSocket.readyState = WebSocket.CLOSED;
          webSocketFactory.lastMockWebSocket.closeStreamController.add(new Event("onClose"));
        });
        //Open the socket to get things going
        webSocketFactory.lastMockWebSocket.openStreamController.add(new Event("onOpen"));
        webSocketFactory.lastMockWebSocket.readyState = WebSocket.OPEN;

      });
      tearDown(() {
        underTest.close();
      });

      test("the original websocket.close() should be called", () {

        return new Future.delayed( new Duration( milliseconds:200), (){
          webSocketFactory.sockets.first.getLogs(  callsTo("close")).verify(happenedOnce);
        });
        
      });
      test("a new Socket should be created after the testing reopenDelay of 100 milliseconds", () {
        
        return new Future.delayed( new Duration( milliseconds:200), (){        
          expect(webSocketFactory.calls, equals(2));
        });
      });
    });
  
}


Timer createDurationTimeout(int period) {
  return new Timer(new Duration(seconds: 3), () {
    fail('event not fired in time');
  });
}
void cancelTimeout(Timer t) {
  if (t != null) {
    t.cancel();
  }
}
