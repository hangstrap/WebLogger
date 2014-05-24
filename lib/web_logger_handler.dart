library web_logger;
import "package:logging/logging.dart";
import "dart:html";
import 'dart:convert';


class WebLoggerHandler {
  final WebSocket webSocket;
  final String sessionID;

  WebLoggerHandler(String hostUrl, this.sessionID): webSocket = new WebSocket(hostUrl) {
    _init();
  }

  WebLoggerHandler.createforTest(this.webSocket, this.sessionID) {
    _init();
  }

  void _init() {
    //Listen to logging events
    Logger.root.onRecord.listen((LogRecord rec) {
      _processLoggingEvent(rec);
    });
    webSocket.onOpen.first.then((e) {

      print("connected ${e.type}");
      webSocket.onClose.first.then((_) {
        print("Connection disconnected to ${webSocket.url}.");
      });

      webSocket.onMessage.listen((e) => print(e.data));

      webSocket.sendString(JSON.encode({
        'sessionid': sessionID
      }));
    });
    webSocket.onError.forEach((e) {
      print("Web socket error type:${e.type} ${webSocket.readyState}");
    });
  }

  _processLoggingEvent(LogRecord rec) {
    if (webSocket.readyState == WebSocket.CONNECTING) {
      webSocket.send(rec);
    }
  }

}
