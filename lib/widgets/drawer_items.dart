import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:glug_app/resources/firestore_provider.dart';
import 'package:glug_app/screens/ContactUs.dart';
import 'package:glug_app/screens/about_us_screen.dart';
import 'package:glug_app/screens/attendance_tracker_screen.dart';
import 'package:glug_app/screens/dashboard.dart';
import 'package:glug_app/screens/display.dart';
import 'package:glug_app/screens/members_screen.dart';

import 'error_widget.dart';

class DrawerItems extends StatefulWidget {
  @override
  _DrawerItems createState() => _DrawerItems();
}

class _DrawerItems extends State<DrawerItems> {
  FirestoreProvider _provider;
  String _userID;

  @override
  void initState() {
    _provider = FirestoreProvider();
    _getUserID();
    super.initState();
  }

  @override
  void dispose() {
    _provider = null;
    super.dispose();
  }

  void _getUserID() async {
    _userID = await _provider.getCurrentUserID();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      // Important: Remove any padding from the ListView.
      padding: EdgeInsets.zero,
      children: <Widget>[
        GestureDetector(
          child: StreamBuilder(
            stream: _provider.fetchUserData(),
            builder: (BuildContext context,
                AsyncSnapshot<DocumentSnapshot> snapshot) {
              if (snapshot.hasData) {
                DocumentSnapshot userData = snapshot.data;
                print(userData);
                return UserAccountsDrawerHeader(
                  accountName: Text(
                    userData.exists
                        ? userData["name"]
                        : "Guest $_userID".substring(0, 15) + "...",
                    style: TextStyle(fontFamily: "Montserrat"),
                  ),
                  accountEmail: Text(
                    userData.exists ? userData["email"] : "",
                    style: TextStyle(fontFamily: "Montserrat"),
                  ),
                  currentAccountPicture: CircleAvatar(
                    radius: 30.0,
                    backgroundImage: userData.exists
                        ? NetworkImage(userData["photoUrl"])
                        : AssetImage("images/glug_logo.jpeg"),
                  ),
                );
              } else if (snapshot.hasError)
                return Center(child: errorWidget("No data found"));
              else
                return Center(child: CircularProgressIndicator());
            },
          ),
          onTap: () {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => Dashboard()));
          },
        ),
        ListTile(
          leading: Icon(Icons.home),
          title: Text("Home"),
          onTap: () {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => Display()));
          },
        ),
        ListTile(
          leading: Icon(FontAwesomeIcons.userFriends),
          title: Text("Our team"),
          onTap: () {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => MembersScreen()));
          },
        ),
        ListTile(
          leading: Icon(Icons.info_outline),
          title: Text("About Us"),
          onTap: () {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => AboutUS()));
          },
        ),
        ListTile(
          leading: Icon(Icons.contacts),
          title: Text("Contact Us"),
          onTap: () {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => ContactUs()));
          },
        ),
        ListTile(
          leading: Icon(Icons.track_changes),
          title: Text("Attendance Tracker"),
          onTap: () {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => AttendanceTrackerScreen()));
          },
        ),
      ],
    );
  }
}
