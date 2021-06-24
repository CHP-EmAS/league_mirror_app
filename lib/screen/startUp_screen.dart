import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:league_mirror/controller/NavigationController.dart';
import 'package:league_mirror/controller/SocketController.dart';
import 'package:league_mirror/controller/locator.dart';
import 'package:league_mirror/widget/loading_button_widget.dart';

import 'package:network_info_plus/network_info_plus.dart';
import 'package:ping_discover_network/ping_discover_network.dart';

class StartUpScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _StartUpScreenState();
  }
}

class _StartUpScreenState extends State<StartUpScreen> {
  final NavigationService _navigationService = locator<NavigationService>();

  String _message = "";
  String _searchMessage = "Automatische Suche...";
  bool _failedToAutoSearch = false;

  TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 20.0, color: Colors.black);
  final _ipController = TextEditingController();

  @override
  void initState() {
    super.initState();
    networkScan();
  }

  Future<bool> connectWithSocket(String ip) async {
    print("Connecting to Socket <" + ip + ">....");

    setState(() {
      _searchMessage = "Verbinde mit " + ip;
    });

    await Future.delayed(const Duration(seconds: 1));

    SocketController.setOnConnect(() async {
      setState(() {
        _searchMessage = "Verbunden";
      });

      await Future.delayed(const Duration(seconds: 1));

      _navigationService.popAndPushNamed('/home');
    });

    await SocketController.connect(ip);

    return true;
  }

  Future<void> networkScan() async {

    await Future.delayed(const Duration(seconds: 2));

    final info = NetworkInfo();

    final String ip = await info.getWifiIP();
    final String subnet = ip.substring(0, ip.lastIndexOf('.'));
    final int port = 5000;

    print(ip + " " + subnet);

    String found = "";

    final stream = NetworkAnalyzer.discover2(subnet, port);
    stream.listen((NetworkAddress address) {
      if(address.exists) {
        connectWithSocket(address.ip);
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    final ipField = TextField(
      obscureText: false,
      style: style,
      controller: _ipController,
      decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          hintText: "IP manuell eingeben...",
          hintStyle: TextStyle(color: Colors.grey),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0))),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Verbindung zum League Mirror",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.grey[850],
        elevation: 0,
      ),
      backgroundColor: Colors.grey[900],
      body: Center(
        child: Container(
          child: ListView(
            padding: const EdgeInsets.all(36),
            children: <Widget>[
              SizedBox(
                height: 160.0,
                child: Image.asset(
                  "images/lol logo.png",
                  fit: BoxFit.contain,
                ),
              ),
              SizedBox(height: 30.0),
              _failedToAutoSearch
                  ? Icon(
                Icons.clear,
                color: Colors.red,
                size: 30,
              ) : SpinKitRipple(
                color: Colors.lime,
                size: 50,
                duration: Duration(seconds: 2),
              ),
              SizedBox(height: 15),
              Text(_searchMessage, textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Montserrat', fontSize: 20.0).copyWith(color: Colors.white, fontSize: 18)),
              SizedBox(height: 50),
              ipField,
              SizedBox(height: 25.0),
              Container(
                child: LoadingButton("Verbinden", "Verbinden", Colors.lightBlue, () async {
                  if (_ipController.text == "") return false;

                  return connectWithSocket(_ipController.text).then((success) {
                    if (success) {
                      _navigationService.popAndPushNamed('/startup');
                      return true;
                    } else {
                      setState(() {
                        _message = "Verbindung konnte nicht hergestellt werden";
                      });
                      return false;
                    }
                  });
                }),
              ),
              SizedBox(height: 25.0),
              Text(_message, textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Montserrat', fontSize: 20.0).copyWith(color: Colors.white, fontSize: 18)),
            ],
          ),
        ),
      ),
    );
  }
}
