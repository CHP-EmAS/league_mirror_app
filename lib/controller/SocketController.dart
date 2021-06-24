import 'dart:async';

import 'package:socket_io_client/socket_io_client.dart' as IO;

class StreamSocket{
  final _socketResponse= StreamController<String>();

  void Function(String) get addResponse => _socketResponse.sink.add;

  Stream<String> get getResponse => _socketResponse.stream;

  void dispose(){
    _socketResponse.close();
  }
}

StreamSocket streamSocket =StreamSocket();

class SocketController {
  static String errorCode = "";
  static String errorMessage = "";

  static bool _connected = false;

  static IO.Socket _socket;

  static Function _onConnect = () {return;};
  static Function _onError = () {return;};
  static Function _onQueueEvent = (dynamic data) async {return;};

  static Future<bool> connect(String ip) async {

    Uri url = new Uri.http(ip + ":5000", "/");
    print(url.toString());

   _socket = IO.io(url.toString(), <String, dynamic> {
     "transports": ["websocket"],
     "autoConnect": false
   });

   _socket.connect();

   _socket.onConnect((data) {
     _onConnect();
   });

   _socket.on('queueEvent', (data) => _onQueueEvent(data));
   _socket.onDisconnect((_) => print('disconnect'));
   _socket.onConnectError((data) => print(data));

  }

  static bool sendCommand(String cmd, String method) {
    _socket.emit("command", '{"method": "' + method + '", "uri": "' + cmd + '"}');
    return true;
  }

  static void setOnConnect(Function onConnect) {
     _onConnect = onConnect;
  }

  static void setOnQueueEvent(Function onQueueEvent(dynamic data)) {
    _onQueueEvent = onQueueEvent;
  }
}
