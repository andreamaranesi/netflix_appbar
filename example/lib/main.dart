import 'package:flutter/material.dart';
import 'package:netflix_appbar/netflix_appbar.dart';
import 'package:netflix_appbar_example/common/app.dart';
import 'package:netflix_appbar_example/common/styles.dart';
import 'package:netflix_appbar_example/widgets/about_us.dart';
import 'package:netflix_appbar_example/widgets/movies.dart';
import 'package:netflix_appbar_example/widgets/tvseries.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    app _app = new app();
    return ChangeNotifierProvider<app>.value(
        value: _app,
        child: Consumer<app>(builder: (context, value, child) {
          return MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: buildLightTheme(),
              darkTheme: buildDarkTheme(),
              home: MyHomePage(context));
        }));
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage(this.context);

  BuildContext context;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool firstTime = true;

  static app provider;

  @override
  void initState() {
    super.initState();

    var movies = new Movies();
    var tv = new Tv();

    titles.add(new DrTextTransitionTitleObject("Movies", "movies", movies,
        header: switchHeader("movies")));
    titles.add(new DrTextTransitionTitleObject("Tv Series", "tv", tv,
        newTitles: tvTitles, header: switchHeader("movies")));
    titles.add(new DrTextTransitionTitleObject("About Me", "about", AboutUs()));

    tvTitles.add(new DrTextTransitionTitleObject(
      "Tv Series",
      "tv",
      tv,
      newTitles: titles,
      header: switchHeader("tv"),
    ));
    tvTitles.add(new DrTextTransitionTitleObject("Movies", "movies", movies,
        newTitles: titles, paddingLeft: 30));
  }

  Widget switchHeader(String slug) {
    Widget rightWidget = Flexible(
      child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.search,
              color: Colors.white,
              size: 30,
            ),
            SizedBox(
              width: 20,
            ),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 1),
                shape: BoxShape.rectangle,
                image: DecorationImage(
                    image: NetworkImage(
                        'https://upload.wikimedia.org/wikipedia/commons/0/0b/Netflix-avatar.png'),
                    fit: BoxFit.fill),
              ),
            )
          ]),
    );

    Widget mainTitle = Flexible(
        child: ListenableProvider.value(
            value: Provider.of<app>(widget.context, listen: true),
            child: Consumer<app>(builder: (context, value, child) {
              return AnimatedDefaultTextStyle(
                  duration: Duration(milliseconds: 200),
                  style: TextStyle(
                      color: Colors.white, fontSize: 20, fontFamily: "Dr3"),
                  child: Text(value.currentTitle.toString()));
            })));

    Widget header = Container(
      height: headerHeight,
      child: Flex(
        direction: Axis.horizontal,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
              child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                Padding(
                    child: CircleAvatar(
                      backgroundColor: Colors.transparent,
                      child: Image.asset(
                        "assets/images/logo.png",
                      ),
                    ),
                    padding: EdgeInsets.only(right: 10)),
                mainTitle,
              ])),
          rightWidget
        ],
      ),
    );
    switch (slug) {
      case "tv":
        return Container(
          height: headerHeight,
          child: Flex(
            direction: Axis.horizontal,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                            child: CircleAvatar(
                              backgroundColor: Colors.transparent,
                              child: GestureDetector(
                                child: Icon(Icons.arrow_back_rounded,
                                    color: Colors.white),
                                onTap: () {
                                  NetflixAppBar.goBack();
                                },
                              ),
                            ),
                            padding: EdgeInsets.only(right: 10)),
                        mainTitle
                      ])),
              rightWidget,
            ],
          ),
        );
        break;
      default:
        return header;
    }
  }

  double headerHeight = 85;
  String currentSlug = "movies";

  List<DrTextTransitionTitleObject> titles = new List();
  List<DrTextTransitionTitleObject> tvTitles = new List();
  NetflixAppBar instance;

  @override
  Widget build(BuildContext context) {
    int milliseconds = 700;

    if (provider == null)
      provider = Provider.of<app>(widget.context, listen: false);

    TextStyle titleStyles = const TextStyle(
        fontFamily: "Dr1",
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.bold);

    instance = NetflixAppBar(
      titles,
      milliseconds,
      header: switchHeader(this.currentSlug),
      headerHeight: headerHeight,
      initialOpacity: 0,
      maxOpacity: 1,
      titlePaddingLeft: 15,
      titlePaddingRight: 10,
      dumping: 100,
      titleStyles: titleStyles,
      titleActiveFontSize: 21,
      appBarColor: Colors.black,
      background: Colors.black,
      onScreenChange:
          (ScrollController controller, String slug, NetflixAppBar instance) {
        print("Controller received correctly \n We are on $slug screen");
        this.currentSlug = slug;
        this.instance = NetflixAppBar.getInstance();
        var newTitles = this.instance.titles;

        provider.setTitle(newTitles[0].name);

        /*new Timer(Duration(milliseconds: 500), () {
          this.instance.titles[0].primaryStyle = new TextStyle(
              fontSize: 18, fontFamily: "Dr1", fontWeight: FontWeight.bold);
          NetflixAppBar.notify();
        });*/
      },
    );
    return instance;
  }
}