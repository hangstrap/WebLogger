library web_logger;
import "package:logging/logging.dart";
import 'package:jsonx/jsonx.dart' as Json;

 
import "dart:html";


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
//    Logger.root.onRecord.listen((LogRecord rec) {
//      _processLoggingEvent(rec);
//    });
    webSocket.onOpen.first.then((_) {
//
     print("onOpen event has been fired - web socket is connected");
//      webSocket.onClose.first.then((_) {
//        print("Connection disconnected to ${webSocket.url}.");
//      });
//
//      webSocket.onMessage.listen((e) => print(e.data));
//
      _sendMessage( "sessionID", sessionID);
//    });
//    webSocket.onError.forEach((e) {
//      print("Web socket error type:${e.type} ${webSocket.readyState}");
    });
  }

  _processLoggingEvent(LogRecord rec) {
//    if (webSocket.readyState == WebSocket.CONNECTING) {
//      webSocket.send(rec);
//    }
  }
  
  _sendMessage( String type, Object data){
    
    Message message = new Message( type, data);
    String json = Json.encode( message);
    print( "About to send ${json}");
    webSocket.sendString( json);
print( "AAAA");
  }

}

class Message<T>{
  String type;
  T data;  
  Message( this.type, this.data);  
 }
