import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:glug_app/models/event_model.dart';
import 'package:date_format/date_format.dart';
import 'package:glug_app/resources/firestore_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class EventInfo extends StatefulWidget {
  final Event event;
  EventInfo({Key key, @required this.event}) : super(key: key);

  @override
  _MyClassState createState() => _MyClassState(event);
}

class _MyClassState extends State<EventInfo> {
  final Event event;
  FirestoreProvider _provider;
  bool _isInterested = false;

  _MyClassState(this.event);

  final months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December'
  ];

  @override
  void initState() {
    _provider = new FirestoreProvider();
    _initInterested();
    super.initState();
  }

  @override
  void dispose() {
    _provider = null;
    super.dispose();
  }

  void _initInterested() async {
    var ins = await _provider.isInterested(event.title);
    setState(() {
      _isInterested = ins;
    });
  }

  String _getTime(String timing) {
    DateTime dateTime = DateTime.parse(timing).toLocal();
    var time = formatDate(dateTime, [HH, ':', nn, ':', ss]);
    return time;
  }

  Widget _getDate(String timing) {
    DateTime dateTime = DateTime.parse(timing).toLocal();
    var month = dateTime.month;
    var day = dateTime.day;
    var year = dateTime.year;
    var m = months[month - 1];
    Widget txt1 = Text(
      m.substring(0, 3),
      style: TextStyle(
        fontFamily: "Montserrat",
        fontSize: 18.0,
        fontWeight: FontWeight.bold,
      ),
    );
    Widget txt2 = Text(
      m.substring(3),
      style: TextStyle(
        fontFamily: "Montserrat",
        color: Colors.deepOrange,
        fontSize: 18.0,
        fontWeight: FontWeight.bold,
      ),
    );

    var date = " $day, $year";
    Widget txt3 = Text(
      date,
      style: TextStyle(
        fontFamily: "Montserrat",
        color: Colors.deepOrangeAccent,
        fontSize: 18.0,
        fontWeight: FontWeight.bold,
      ),
    );

    return Row(
      children: <Widget>[
        SizedBox(
          width: 10.0,
        ),
        txt1,
        txt2,
        txt3,
        SizedBox(
          width: 15.0,
        ),
        Icon(
          Icons.calendar_today,
          color: Colors.deepOrangeAccent,
        ),
        SizedBox(
          width: 20,
        )
      ],
    );
  }

  Widget _interestedButton() {
    return FlatButton(
        padding: EdgeInsets.fromLTRB(15, 10, 15, 10),
        color: Colors.deepOrangeAccent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18.0),
        ),
        child: Wrap(
          direction: Axis.horizontal,
          spacing: 0,
          children: <Widget>[
            Text(
              "Interested",
              style: TextStyle(
                fontFamily: "Montserrat",
                color: Colors.white,
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(
              width: 10,
            ),
            Icon(
              // Icons.favorite_border,
              _isInterested ? Icons.favorite : Icons.favorite_border,
              size: 20.0,
              color: Colors.white,
            ),
          ],
        ),
        onPressed: () {
          setState(() {
            if (!_isInterested) {
              _provider.addInterested(event.title.toString());
            } else {
              _provider.removeInterested(event.title.toString());
            }
            _isInterested = !_isInterested;
          });
        });
  }

  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              constraints: BoxConstraints.expand(
                height: 250.0,
              ),
              alignment: Alignment.bottomLeft,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: event.event_image != null
                      ? CachedNetworkImageProvider(event.event_image)
                      : AssetImage('images/glug_logo.jpeg'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Wrap(
                direction: Axis.vertical,
                spacing: 10,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(bottom: 90.0),
                    height: 50.0,
                    child: IconButton(
                      icon:Icon(Icons.arrow_back,) ,
                      color: Colors.white,
                      onPressed: () {
                        Navigator.of(context).pop(true);
                      },

                    ),
                  ),

                  Container(
                    margin: EdgeInsets.only(bottom: 20.0),
                    height: 50.0,
                    decoration: BoxDecoration(
                      color: Color.fromARGB(210, 255, 255, 255),
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(50.0),
                        bottomRight: Radius.circular(50.0),
                      ),
                    ),
                    child: _getDate(event.event_timing),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 20.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  Icons.watch_later,
                  color: Colors.red,
                ),
                SizedBox(
                  width: 5.0,
                ),
                Text(
                  _getTime(event.event_timing),
                  style: TextStyle(
                    fontFamily: "Montserrat",
                  ),
                ),
                SizedBox(
                  width: 10.0,
                ),
                Icon(Icons.location_on),
                SizedBox(
                  width: 5.0,
                ),
                Text(
                  event.venue != null ? event.venue : 'Online',
                  style: TextStyle(
                    fontFamily: "Montserrat",
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 15.0,
            ),
            _interestedButton(),
            SizedBox(
              height: 7.0,
            ),
            Html(
              data: event.description,
              //Optional parameters:
              padding: EdgeInsets.all(8.0),

              defaultTextStyle: TextStyle(fontFamily: "Montserrat"),
              linkStyle: const TextStyle(
                color: Colors.blue,
              ),
              useRichText: false,
              onLinkTap: (url) {
                print("Opening $url");
                _launchURL(url);
              },
              onImageTap: (src) {
                // Display the image in large form.
              },
            ),
            SizedBox(
              height: 25.0,
            ),
          ],
        ),
      ),
    );
  }
}
