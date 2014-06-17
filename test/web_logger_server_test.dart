library web_logger_server_test;

import 'dart:async';
import 'dart:io';
import 'package:unittest/unittest.dart';
import 'package:route/server.dart' show Router;


import 'package:web_logger/web_logger_server.dart';
import 'package:logging/logging.dart';
import 'package:mock/mock.dart';
import 'package:jsonx/jsonx.dart' as Json;

class MockHttpServer extends Mock implements HttpServer {}

class MockStreamListener extends Mock implements Stream {
  MockStream() {

  }
}
class MockStream extends Mock implements Stream {
  MockStream(MockStreamListener mockStreamListener) {
    when(callsTo("transform")).alwaysReturn(mockStreamListener);
  }
}

class MockRouter extends Mock implements Router {
  MockRouter(MockStream mockStream) {
    when(callsTo("serve", "ws")).alwaysReturn(mockStream);
  }
}

void handleWebSocket(WebSocket webSocket) {

}

void main() {

  group("createWebSocketRouter procedure", () {

    test("should return a new router", () {



      Router result = createWebSocketRouter(new MockHttpServer(), "ws", handleWebSocket);
      expect(result, isNotNull);
    });

    test("should add the correct context", () {

      MockRouter mockRouter = new MockRouter(new MockStream(new MockStreamListener()));
      addWebSocketContext(mockRouter, "ws", handleWebSocket);
      mockRouter.getLogs(callsTo("serve", "ws")).verify(happenedOnce);
    });

    test("should add a WebSocketTransfomer as a transformer", () {

      MockStream mockStream = new MockStream(new MockStreamListener());
      MockRouter mockRouter = new MockRouter(mockStream);
      addWebSocketContext(mockRouter, "ws", handleWebSocket);
      mockStream.getLogs(callsTo("transform", anything)).verify(happenedOnce);
      mockStream.getLogs(callsTo("transform", new isInstanceOf<WebSocketTransformer>())).verify(happenedOnce);

    });

    test("the transfomer listen() method should call the handler", () {

      MockStreamListener mockStreamListener = new MockStreamListener();
      MockRouter mockRouter = new MockRouter(new MockStream(mockStreamListener));
      addWebSocketContext(mockRouter, "ws", handleWebSocket);

      mockStreamListener.getLogs(callsTo("listen", anything)).verify(happenedOnce);
      mockStreamListener.getLogs(callsTo("listen", new isInstanceOf<HandleWebSocket>())).verify(happenedOnce);
      mockStreamListener.getLogs(callsTo("listen", equals( handleWebSocket))).verify( happenedOnce);
    });
  });
}
