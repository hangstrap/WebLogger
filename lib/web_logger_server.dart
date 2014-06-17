library web_logger_server;

import 'dart:io';
import 'dart:convert';
import 'package:route/server.dart' show Router;

typedef void WebSocketHandlerFunction(WebSocket webSocket);

Router createWebSocketRouter(HttpServer server, String context, WebSocketHandlerFunction handler) {

  var router = createRouterFactoryFunction(server);
  //add a context that when called via http request, will be transformed into a webSocketRequest
  //and then passed onto the WebSocketHandler
  router.serve(context).transform(new WebSocketTransformer()).listen(handler);
  return router;
}

/**The followinf method have been added for unit testing */
typedef Router CreateRouterFactoryFunction(HttpServer server);
Router _realCreateRouterFactoryFunction(HttpServer server) {
  return new Router(server);
}
CreateRouterFactoryFunction createRouterFactoryFunction = _realCreateRouterFactoryFunction;


/**
 * simply dumps any incomming client log messages to the console
 */
void consoleWebLoggerHandler(WebSocket webSocket) {

  webSocket.map((string) => JSON.decode(string)).listen((json) {
    print(json);
  }, onError: (error) {
    print('Bad WebSocket request ${error}');
  });
}
