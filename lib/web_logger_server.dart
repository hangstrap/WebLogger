library web_logger_server;

import 'dart:io';
import 'dart:convert';
import 'package:route/server.dart' show Router;

typedef void HandleWebSocket(WebSocket webSocket);

Router createWebSocketRouter(HttpServer server, String context, HandleWebSocket handler) {

  var router = new Router(server);

  addWebSocketContext( router, context, handler);

  return router;
}

/**Exposed for unit testing */
void addWebSocketContext( Router router,  String context, HandleWebSocket handler) {
  
  // The client will connect using a WebSocket. Upgrade requests to websocket and
  // forward them to handler
  router.serve(context).transform(new WebSocketTransformer()).listen(handler);
}


/**
 * simply dumps any incomming client log messages to the console
 */ 
void consoleWebLoggerHandler(WebSocket webSocket) {
  
  webSocket.map((string) => JSON.decode(string)).listen((json) {
    print(json);
  }, 
  onError: (error) {
    print('Bad WebSocket request ${error}');
  });
}
