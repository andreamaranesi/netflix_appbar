import 'package:flutter/material.dart';

class AboutUs extends StatefulWidget {
  @override
  _AboutUs createState() => _AboutUs();
}

class _AboutUs extends State<AboutUs> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "Andrea Maranesi",
            style: TextStyle(
                fontFamily: "Dr1",
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 30),
          )
        ],
      ),
    );
  }
}
