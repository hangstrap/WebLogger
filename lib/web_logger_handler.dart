library web_logger;
import "package:logging/logging.dart";
import 'package:jsonx/jsonx.dart' as Json;


import "dart:html";
import "dart:async";



class WebLoggerHandler {

  final CreateWebSocketFunction _createWebSocketFunction;
  final String hostUrl;
  final String sessionID;
  final StreamController _eventControler  = new StreamController.broadcast();
  
  Stream<Event> get events => _eventControler.stream; 

  WebSocket webSocket;
  var logSubscription;

  WebLoggerHandler(this.hostUrl, this.sessionID)
      : this._createWebSocketFunction = _createWebSocket {
    _init();
  }

  WebLoggerHandler.createforTest(this._createWebSocketFunction, this.hostUrl, this.sessionID) {
    _init();
  }

  void close() {
    logSubscription.cancel();
    webSocket.close();
  }
  void _init() {
    //Listen to logging events
    logSubscription = Logger.root.onRecord.listen((LogRecord rec) {
      _processLoggingEvent(rec);
    });
    
    webSocket = _createWebSocketFunction( hostUrl);
    
    webSocket.onOpen.first.then((_) {
      
      _eventControler.add( new Event( "webSocketOpened"));
       print("onOpen event has been fired - web socket is connected");
      _sendMessage("sessionID", sessionID);

      webSocket.onError.forEach((e) {
        print("Web socket error type:${e.type} ${webSocket.readyState}");
        webSocket.close();
        _init();
      });
    });
  }

  _processLoggingEvent(LogRecord rec) {
    if (webSocket.readyState == WebSocket.OPEN) {
      _sendMessage("logRecord", rec);
    }
  }

  _sendMessage(String type, Object data) {

    Message message = new Message(type, data);
    String json = Json.encode(message);
    print("About to send ${json}");
    webSocket.sendString(json);
  }

}
/**Expose function type for unit testing*/
typedef WebSocket CreateWebSocketFunction(String url);

/** instance of [CreateWebSocketFunction] */
WebSocket _createWebSocket(String url)=>new WebSocket(url);



class Message<T> {
  String type;
  T data;
  Message(this.type, this.data);
}
