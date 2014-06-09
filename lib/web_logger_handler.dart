library web_logger;
import "package:logging/logging.dart";
import 'package:jsonx/jsonx.dart' as Json;


import "dart:html";
import "dart:async";



class WebLoggerHandler {

  Logger logger = new Logger("web_logger");
  final int reopenDelayMSec;
  final CreateWebSocketFunction _createWebSocketFunction;
  final String hostUrl;
  final String sessionID;
  final StreamController _eventControler = new StreamController.broadcast();
  Timer initTimer;

  Stream<Event> get events => _eventControler.stream;

  WebSocket webSocket;
  var logSubscription;

  WebLoggerHandler(this.hostUrl, this.sessionID)
      : this._createWebSocketFunction = _createWebSocket,
        this.reopenDelayMSec = 10000 {
    _init();
  }

  WebLoggerHandler.createforTest(this._createWebSocketFunction, this.hostUrl, this.sessionID)
      : this.reopenDelayMSec = 100 {
    _init();
  }

  void close() {

    logSubscription.cancel();
    if (webSocket != null) {
      webSocket.close();
    }
  }
  
  void _init() {

    //Listen to logging events
    logSubscription = Logger.root.onRecord.listen((LogRecord rec) {
      _processLoggingEvent(rec);
    });
    logger.fine("creating new WebSocket()");
    webSocket = _createWebSocketFunction(hostUrl);

    webSocket.onOpen.forEach((_) {

      _eventControler.add(new Event("webSocketOpened"));
      print("onOpen event has been fired - web socket is connected");
      _sendMessage("sessionID", sessionID);

      webSocket.onError.forEach((e) {
        _coseAndReopenSocket(e);
      });
      webSocket.onClose.forEach((e) {
        _coseAndReopenSocket(e);
      });
      //webSocket.onMessage.forEach( (e)=>print( "receved message ${e}"));
    });
  }

  void _coseAndReopenSocket(Event e) {


    //If necessary, start a timer to then reinitilise the socket
    if ((initTimer == null) || (initTimer.isActive == false)) {

      initTimer = new Timer(new Duration(milliseconds: reopenDelayMSec), () {

        logger.fine("Web socket error type:${e.type} ${webSocket.readyState}");
        logger.fine("closing web socket");
        close();
        webSocket = null;

        _init();
      });
    }
  }
  _processLoggingEvent(LogRecord rec) {
    if ((webSocket != null) && (webSocket.readyState == WebSocket.OPEN)) {
      _sendMessage("logRecord", rec);
    }
  }

  _sendMessage(String type, Object data) {

    Message message = new Message(type, data);
    String json = Json.encode(message);
    print("*** About to send ${json}");
    webSocket.sendString(json);
  }

}
/**Expose function type for unit testing*/
typedef WebSocket CreateWebSocketFunction(String url);

/** instance of [CreateWebSocketFunction] */
WebSocket _createWebSocket(String url) => new WebSocket(url);



class Message<T> {
  String type;
  T data;
  Message(this.type, this.data);
}
