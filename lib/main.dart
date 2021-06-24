import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:league_mirror/controller/locator.dart';
import 'package:league_mirror/screen/homeScreen.dart';
import 'package:league_mirror/screen/startUp_screen.dart';

import 'controller/NavigationController.dart';

void main() async {
  setupLocator();
  runApp(LeagueMirror());
}

class LeagueMirror extends StatefulWidget {
  const LeagueMirror();

  @override
  State<StatefulWidget> createState() {
    return _LeagueMirrorState();
  }
}

class _LeagueMirrorState extends State<LeagueMirror> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'LeagueMirror',
        theme: ThemeData(
          primaryColor: Colors.lime,
          accentColor: Colors.lime,
          brightness: Brightness.dark,
          accentColorBrightness: Brightness.dark,
          primaryColorBrightness: Brightness.dark,
        ),
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: [
          const Locale('de', 'DE'),
        ],
        navigatorKey: locator<NavigationService>().navigatorKey,
        home: StartUpScreen(),
        routes: <String, WidgetBuilder>{
          '/startup': (BuildContext context) => new StartUpScreen(),
          '/home': (BuildContext context) => new HomeScreen(),
        },
      );
  }
}