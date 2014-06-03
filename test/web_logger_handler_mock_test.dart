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

@proxy
class MockWebSocketFactory extends Mock {

  final MockWebSocket mockWebSocket;
  MockWebSocketFactory(this.mockWebSocket) {
    when(callsTo("createWebSocket")).thenReturn(mockWebSocket, 1000);

  }
  MockWebSocket createWebSocket(String url) => super.createWebSocket(url);

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

    MockWebSocket webSocket = new MockWebSocket();
    MockWebSocketFactory webSocketFactory = new MockWebSocketFactory(webSocket);

    setUp(() {
      webSocket = new MockWebSocket();
      webSocketFactory = new MockWebSocketFactory(webSocket);

      //fire the onOpen event
      webSocket.openStreamController.add(new Event("onOpen"));
      webSocket.readyState = WebSocket.OPEN;

      underTest = new WebLoggerHandler.createforTest(webSocketFactory.createWebSocket, "testUrl", "NameOfSession");

    });
    tearDown(() {
      underTest.close();
    });
    test("the web socket should be created with the correct parameter", () {
      webSocketFactory.getLogs(callsTo("createWebSocket", "testUrl")).verify(happenedOnce);
    });
    test("it should first send the sessionID to the server", () {

      return new Future.value().then((_) {
        String message = Json.encode(new Message("sessionID", "NameOfSession"));
        webSocket.getLogs(callsTo("sendString", message)).verify(happenedOnce);
      });

    });
    test("it should fire the open event", () {
        return underTest.events.first.then((Event e) {
          expect(e.type, equals("webSocketOpened"));
        });
    });

    test("it should send any log records to the server", () {

      return new Future.value().then((_) {

        log.info("a message");

        String message = Json.encode(new Message("logRecord", lastRecord));
        webSocket.getLogs(callsTo("sendString", message)).verify(happenedOnce);
      });
    });
    test("it should not send any log records if the socket is in the CONNECTING state", () {

      return new Future.value().then((_) {

        webSocket.readyState = WebSocket.CONNECTING;
        log.info("not sent");

        String message = Json.encode(new Message("logRecord", lastRecord));
        webSocket.getLogs(callsTo("sendString", message)).verify(neverHappened);
      });
    });
    test("it should not send any log records if the socket is in the CLOSING state", () {

      return new Future.value().then((_) {

        webSocket.readyState = WebSocket.CLOSING;
        log.info("not sent");

        String message = Json.encode(new Message("logRecord", lastRecord));
        webSocket.getLogs(callsTo("sendString", message)).verify(neverHappened);
      });
    });
    test("it should not send any log records if the socket is in the CLOSED state", () {

      return new Future.value().then((_) {

        webSocket.readyState = WebSocket.CLOSED;
        log.info("not sent");

        String message = Json.encode(new Message("logRecord", lastRecord));
        webSocket.getLogs(callsTo("sendString", message)).verify(neverHappened);
      });
    });


    group("When the user calls 'close()", () {
      test("the webSockets close() should be called", () {
        underTest.close();
        webSocket.getLogs(callsTo("close")).verify(happenedOnce);
      });
    });
  });

  group("When an error event occures", () {

    WebLoggerHandler underTest;
    MockWebSocket webSocket = new MockWebSocket();
    ;
    MockWebSocketFactory webSocketFactory = new MockWebSocketFactory(webSocket);


    setUp(() {

      webSocket = new MockWebSocket();
      ;
      webSocketFactory = new MockWebSocketFactory(webSocket);

      //fire the onOpen event and then the error one
      webSocket.openStreamController.add(new Event("onOpen"));
      webSocket.errorStreamControlleradd(new Event("onError"));
      webSocket.readyState = WebSocket.OPEN;

      underTest = new WebLoggerHandler.createforTest(webSocketFactory.createWebSocket, "testUrl", "NameOfSession");
    });
    tearDown(() {
      underTest.close();
    });

    test("the websocket.close() should be called", () {
      return new Future.value().then((_) {
        webSocket.getLogs(callsTo("close")).verify(happenedOnce);
      });
    });
    test("a new Socket should be created", () {
      webSocketFactory.getLogs(callsTo("createWebSocket", "testUrl")).verify(happenedExactly(2));

    });
  });
}
