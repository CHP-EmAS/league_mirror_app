import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:league_mirror/controller/NavigationController.dart';
import 'package:league_mirror/controller/locator.dart';

enum ConfirmAction { CANCEL, ACCEPT, OK }

class DialogPopup {
  static final NavigationService _navigationService = locator<NavigationService>();

  static Future<ConfirmAction> asyncOkDialog(String title, String content) {
    return showDialog<ConfirmAction>(
      context: _navigationService.navigatorKey.currentContext,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: new Text(title),
          content: new Text(content),
          elevation: 3,
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("Ok", style: TextStyle(color: Colors.lightBlue, fontSize: 18)),
              onPressed: () {
                _navigationService.pop(ConfirmAction.OK);
              },
            ),
          ],
        );
      },
    );
  }

  static Future<ConfirmAction> asyncMatchConfirmDialog(String title, String content) {
    return showDialog<ConfirmAction>(
      context: _navigationService.navigatorKey.currentContext,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: new Text(title),
          content: new Text(content),
          elevation: 3,
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("Annehmen", style: TextStyle(color: Colors.lightBlue, fontSize: 18)),
              onPressed: () {
                _navigationService.pop(ConfirmAction.ACCEPT);
              },
            ),
            new FlatButton(
              child: new Text("Ablehnen", style: TextStyle(color: Colors.lightBlue, fontSize: 18)),
              onPressed: () {
                _navigationService.pop(ConfirmAction.CANCEL);
              },
            ),
          ],
        );
      },
    );
  }

  static Future<void> asyncLoadingDialog(GlobalKey key, String loadingText) async {
    return showDialog<void>(
        context: _navigationService.navigatorKey.currentContext,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return new WillPopScope(
              onWillPop: () async => false,
              child: SimpleDialog(key: key, backgroundColor: Colors.grey[900], elevation: 3, children: <Widget>[
                Center(
                  child: Column(children: [
                    SpinKitThreeBounce(
                      color: Color.fromARGB(150, 255, 255, 255),
                      size: 30,
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      loadingText,
                      style: TextStyle(color:Colors.lightBlue, fontSize: 18),
                    )
                  ]),
                )
              ]));
        });
  }

}

