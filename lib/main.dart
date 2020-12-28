import 'package:flutter/material.dart';

import 'label_scanner.dart';
import 'face_scanner.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(

      initialRoute: '/',
      routes: {
        '/label': (context) => LabelScanner(),
        '/face': (context) => FaceScanner(),
      },

      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Main Menu'),
      ),
      body: Center(
        child: Column (
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              child: Text('Label Scanner'),
              onPressed: () {
                Navigator.pushNamed(context, '/label');
              },
            ),
            ElevatedButton(
              child: Text('Face Scanner'),
              onPressed: () {
                Navigator.pushNamed(context, '/face');
              },
            ),
          ],
        )
      ),
    );
  }
}

