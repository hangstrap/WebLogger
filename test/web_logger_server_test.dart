library web_logger_server_test;

import 'dart:async';
import 'dart:io';
import 'package:unittest/unittest.dart';
import 'package:route/server.dart' show Router;


import 'package:web_logger/web_logger_server.dart' as web_logger_server;
import 'package:mock/mock.dart';


class MockHttpServer extends Mock implements HttpServer {}

class MockStreamListener extends Mock implements Stream {}

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

void webSocketHandlerFunction(WebSocket webSocket) {}

void main() {

  MockStreamListener mockStreamListener;
  MockStream mockStream;
  MockRouter mockRouter;
  MockHttpServer mockHttpServer;

  group("createWebSocketRouter procedure", () {

    setUp(() {
      mockHttpServer = new MockHttpServer();
      mockStreamListener = new MockStreamListener();
      mockStream = new MockStream(mockStreamListener);
      mockRouter = new MockRouter(mockStream);

      Router testCreateRouterFactoryFunction(HttpServer server) {
        return mockRouter;
      }
      //replace the factory method with the test method
      web_logger_server.createRouterFactoryFunction = testCreateRouterFactoryFunction;
    });
    test("should return a new router", () {

      Router result = web_logger_server.createWebSocketRouter(mockHttpServer, "ws", webSocketHandlerFunction);
      expect(result, equals(mockRouter));
    });

    test("router should have the correct context added to it", () {

      web_logger_server.createWebSocketRouter(mockHttpServer, "ws", webSocketHandlerFunction);
      mockRouter.getLogs(callsTo("serve", "ws")).verify(happenedOnce);
    });

    test("should add a WebSocketTransfomer as a transformer to the context", () {

      web_logger_server.createWebSocketRouter(mockHttpServer, "ws", webSocketHandlerFunction);

      mockStream.getLogs(callsTo("transform", new isInstanceOf<WebSocketTransformer>())).verify(happenedOnce);

    });

    test("the transfomer listen() method should call the handler", () {

      web_logger_server.createWebSocketRouter(mockHttpServer, "ws", webSocketHandlerFunction);

      mockStreamListener.getLogs(callsTo("listen", equals(webSocketHandlerFunction))).verify(happenedOnce);
    });
  });
}
