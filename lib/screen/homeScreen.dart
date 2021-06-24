import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:league_mirror/controller/NavigationController.dart';
import 'package:league_mirror/controller/SocketController.dart';
import 'package:league_mirror/controller/locator.dart';
import 'package:league_mirror/widget/dialog_popups.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HomeScreenState();
  }
}

class _HomeScreenState extends State<HomeScreen> {
  final NavigationService _navigationService = locator<NavigationService>();

  TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 20.0, color: Colors.black);
  String _queueStatus = "Nicht in Queue";
  String _estimatedTime = "";

  bool _matchFound = false;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    SocketController.setOnQueueEvent( (data) {
      Map<String, dynamic> responseData = jsonDecode(data);

      print(data);

      if (responseData.containsKey("state")) {
        switch(responseData["state"]) {
          case 0: //inQueue
            if (responseData.containsKey("timeElapsed") && responseData.containsKey("estimatedTime")) {

              int timeElapsed = responseData["timeElapsed"];
              int estimatedTime = double.parse(responseData["estimatedTime"].toString()).toInt();

              String elapsedMinute = (timeElapsed / 60).floor() < 10 ? "0" : "";
              elapsedMinute += (timeElapsed / 60).floor().toString();

              String elapsedSecond = (timeElapsed % 60).floor() < 10 ? "0" : "";
              elapsedSecond += (timeElapsed % 60).floor().toString();

              String estimatedMinute = (estimatedTime / 60).floor() < 10 ? "0" : "";
              estimatedMinute += (estimatedTime / 60).floor().toString();

              String estimatedSecond = (estimatedTime % 60).floor() < 10 ? "0" : "";
              estimatedSecond += (estimatedTime % 60).floor().toString();

              setState(() {
                _queueStatus = "In Queue: " + elapsedMinute + ":" + elapsedSecond;
                _estimatedTime = "geschätzt " + estimatedMinute + ":" + estimatedSecond;
              });
            }
            break;
          case 1: //outQueue
            setState(() {
              _queueStatus = "Nicht in Queue";
              _estimatedTime = "";
            });
            break;
          case 2: //found
            setState(() {
              _queueStatus = "Match gefunden!";
              _estimatedTime = "";
              _matchFound = true;
            });
            break;
        }
      }

      return;
    });
  }

  @override
  Widget build(BuildContext context) {

    final ButtonStyle styleAccept = ElevatedButton.styleFrom(textStyle: const TextStyle(fontSize: 20), primary: Colors.lightBlue);
    final ButtonStyle styleDecline = ElevatedButton.styleFrom(textStyle: const TextStyle(fontSize: 20), primary: Colors.redAccent);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "League Mirror",
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
              Text(
                "Queue Status",
                style: TextStyle(
                  color: Colors.grey,
                  letterSpacing: 2,
                  fontSize: 16,
                ),
              ),
              Text(
                _queueStatus,
                style: TextStyle(color: Colors.lightBlue, letterSpacing: 2, fontSize: 25, fontWeight: FontWeight.bold),
              ),
              _estimatedTime == "" ? Center() : Text(
                _estimatedTime,
                style: TextStyle(color: Colors.lightBlue, letterSpacing: 2, fontSize: 14, fontWeight: FontWeight.bold),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(flex: 1, child: Container(
                    margin: EdgeInsets.only(right: 5),
                    child: ElevatedButton(
                      style: styleDecline,
                      onPressed: _matchFound ? () {
                        SocketController.sendCommand("/lol-matchmaking/v1/ready-check/decline", "POST");
                        _matchFound = false;
                      } : null,
                      child: const Text('X'),
                    ),
                  )),
                  Expanded(flex: 5, child: ElevatedButton(
                    style: styleAccept,
                    onPressed: _matchFound ? () {
                      SocketController.sendCommand("/lol-matchmaking/v1/ready-check/accept", "POST");
                      _matchFound = false;
                    } : null,
                    child: const Text('Annehmen'),
                  )),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
