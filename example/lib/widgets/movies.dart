import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:netflix_appbar_example/widgets/resources/movies.dart';

class Movies extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _Movies();
  }
}

class _Movies extends State<Movies> {
  double get height => MediaQuery.of(context).size.height;

  double get mainImageHeight => this.height * 0.8;

  double get width => MediaQuery.of(context).size.width;

  int mainImageIndex;

  @override
  void initState() {
    super.initState();
    if (mainImageIndex == null) {
      int len = ListOfMovies["images"].length;
      mainImageIndex = Random().nextInt(len);
      print("new Movies() state");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(children: [
        Container(
            height: this.mainImageHeight,
            child: Stack(
              children: [
                Positioned(
                  top: 0,
                  width: this.width,
                  height: this.mainImageHeight,
                  left: 0,
                  child: Image.network(
                    ListOfMovies["images"][mainImageIndex],
                    fit: BoxFit.fitHeight,
                  ),
                ),
                Positioned(
                    top: 0,
                    width: this.width,
                    height: this.mainImageHeight,
                    left: 0,
                    child: Container(
                        foregroundDecoration: BoxDecoration(
                            gradient: LinearGradient(
                                stops: [
                          0.3,
                          0.5,
                          0.8
                        ],
                                colors: [
                          Colors.black.withOpacity(1),
                          Colors.black.withOpacity(0.2),
                          Colors.black.withOpacity(0.0),
                        ],
                                end: Alignment.topCenter,
                                begin: Alignment.bottomCenter,
                                tileMode: TileMode.clamp)))),
                Positioned(
                    top: 0,
                    width: this.width,
                    height: this.mainImageHeight,
                    left: 0,
                    child: Container(
                      margin:
                          EdgeInsets.only(top: (this.mainImageHeight / 2) - 25),
                      height: 50,
                      child: Padding(
                          padding: EdgeInsets.only(left: 15, right: 15),
                          child: Center(
                            child: Text(
                              ListOfMovies["titles"][mainImageIndex] ?? "",
                              textAlign: TextAlign.center,
                              style:
                                  movieStyle(60, bold: false, mainTitle: true),
                            ),
                          )),
                    )),
                Positioned(
                    top: this.mainImageHeight - 70,
                    width: this.width,
                    height: 70,
                    left: 0,
                    child: Flex(
                        mainAxisAlignment: MainAxisAlignment.center,
                        direction: Axis.horizontal,
                        children: [
                          Padding(
                            child: Container(
                              height: 70,
                              child: Flex(
                                  direction: Axis.vertical,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    FlatButton(
                                      child: Column(children: [
                                        Icon(
                                          Icons.add,
                                          color: Colors.white,
                                        ),
                                        Text(
                                          "Action",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontFamily: "Dr1"),
                                        )
                                      ]),
                                      color: Colors.transparent,
                                      onPressed: () {},
                                    )
                                  ]),
                            ),
                            padding: EdgeInsets.only(left: 0, right: 0),
                          ),
                          Padding(
                            child: Container(
                                height: 70,
                                child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      FlatButton(
                                        child: Row(children: [
                                          Icon(
                                            Icons.play_circle_fill,
                                            color: Colors.white,
                                            size: 40,
                                          ),
                                          SizedBox(
                                            width: 5,
                                          ),
                                          Text(
                                            "Play Movie",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 17,
                                                fontFamily: "Dr1"),
                                          )
                                        ]),
                                        color: Colors.transparent,
                                        onPressed: () {},
                                      ),
                                    ])),
                            padding: EdgeInsets.only(left: 0, right: 0),
                          ),
                          Padding(
                            child: Container(
                                height: 70,
                                child: Flex(
                                    direction: Axis.vertical,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      FlatButton(
                                        child: Column(children: [
                                          Icon(
                                            Icons.info_outline,
                                            color: Colors.white,
                                          ),
                                          Text(
                                            "Action",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontFamily: "Dr1"),
                                          )
                                        ]),
                                        color: Colors.transparent,
                                        onPressed: () {},
                                      ),
                                    ])),
                            padding: EdgeInsets.only(left: 0, right: 0),
                          ),
                        ])),
              ],
            )),
        SizedBox(
          height: 10,
        ),
        for (var i = 0; i < 15; i++)
          Padding(
              child: Column(children: [
                Text(
                  "Row $i",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontFamily: "Dr3",
                      fontSize: 20,
                      color: Colors.white),
                ),
                SizedBox(
                  height: 20,
                ),
                SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(children: [
                      for (var j = 0; j < 10; j++)
                        Padding(
                            padding: EdgeInsets.only(left: 10, right: 10),
                            child: Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: Colors.white, width: 2)),
                                child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Padding(
                                        child: Text(
                                          "Movie -  $j",
                                          textAlign: TextAlign.center,
                                          style: movieStyle(17, bold: false),
                                        ),
                                        padding:
                                            EdgeInsets.only(left: 5, right: 5),
                                      )
                                    ])))
                    ]))
              ]),
              padding: EdgeInsets.only(left: 10, right: 10, bottom: 30))
      ]),
    );
  }
}

TextStyle movieStyle(double fontSize,
    {Color color = Colors.white, bool bold = false, bool mainTitle = false}) {
  return TextStyle(
      fontFamily: !mainTitle ? "Dr1" : "nfont",
      fontSize: fontSize,
      color: color,
      fontWeight: bold ? FontWeight.bold : FontWeight.normal);
}
