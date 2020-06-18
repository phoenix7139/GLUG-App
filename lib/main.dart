import 'package:flutter/material.dart';
import 'package:glug_app/screens/blog_screen.dart';
import 'package:glug_app/screens/event_screen.dart';
import 'package:glug_app/screens/firebase_messaging_demo_screen.dart';
import 'package:glug_app/screens/home_screen.dart';
import 'package:glug_app/screens/linit_screen.dart';
import 'package:glug_app/screens/members_screen.dart';
import 'package:glug_app/screens/notification.dart';

void main() => runApp(MainApp());

class MainApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "GLUG App",
      theme: ThemeData(
        primaryColor: Color(0xFF303C42),
      ),
      home: HomeScreen(),
      routes: {
        HomeScreen.id: (context) => HomeScreen(),
        EventScreen.id: (context) => EventScreen(),
        MembersScreen.id: (context) => MembersScreen(),
        BlogScreen.id: (context) => BlogScreen(),
        LinitScreen.id: (context) => LinitScreen(),
      },
    );
  }
}

// Color(0xFF303C42)