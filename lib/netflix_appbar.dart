import 'dart:async';
import 'dart:collection';
import 'package:after_layout/after_layout.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:page_transition/page_transition.dart';

class DrTextTransitionTitleObject {
  String _name, _heroTag;
  Widget _function;
  Widget _before;
  bool _personalized;
  Widget _overrideWidget;
  Function _overrideAction;
  Widget header;
  TextStyle style;
  double headerHeight;
  double paddingLeft;

  List<DrTextTransitionTitleObject> newTitles;

  DrTextTransitionTitleObject(String name, String heroTag, Widget function,
      {List<DrTextTransitionTitleObject> newTitles,
      bool personalized = false,
      Widget overrideWidget,
      Function overrideAction,
      TextStyle style,
      Widget header,
      double headerHeight,
      double paddingLeft = 0}) {
    this._name = name;
    this._function = function;
    this._personalized = personalized;
    this._overrideWidget = overrideWidget;
    this._overrideAction = overrideAction;
    if (this._personalized == true && this._overrideWidget == null)
      throw new Exception(
          "NetflixAppBar Exception: you can't set title as personalized but it's overrideWidget property as null");
    this._heroTag = heroTag;
    this.newTitles = newTitles;
    this.headerHeight = headerHeight;
    this.header = header;
    this.paddingLeft = paddingLeft;
    this.style = style;
  }

  set before(Widget before) => this._before = before;

  set current(Widget current) => this._function = current;

  String get name => this._name;

  bool get personalized => this._personalized;

  Widget get overrideWidget => this._overrideWidget;

  Function get overrideAction => this._overrideAction;

  set personalized(bool personalized) => this._personalized = personalized;

  set overrideWidget(Widget overrideWidget) =>
      this._overrideWidget = overrideWidget;

  set overrideAction(Function overrideAction) =>
      this._overrideAction = overrideAction;

  Widget get before => this._before;

  String get heroTag => this._heroTag;

  Widget get current => this._function;
}

/// Netflix Toolbar
///
/// @param children: The List of Widgets to display
/// @param background The Scaffold final background
/// @param mainImageUrl: The image in the FlexibleSpaceBar
/// @param titles: The titles to display associated to relative functions
/// @author Andrea Maranesi
/// @version 1.0

// ignore: must_be_immutable
class NetflixAppBar extends StatefulWidget {
  static const MethodChannel _channel = const MethodChannel('netflix_appbar');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static void goBack() {
    if (instance != null) instance.previousPage();
  }

  static BuildContext getContext() {
    if (instance != null) return instance.context;
    return null;
  }

  static NetflixAppBar getInstance() {
    if (instance != null) return instance.widget;
    return null;
  }

  static void notify() {
    if (instance != null) instance.notify();
  }

  static Queue<List<DrTextTransitionTitleObject>> previousTitles = new Queue();

  Color background, appBarColor;
  List<DrTextTransitionTitleObject> titles;
  TextStyle titleStyles;
  Widget leading;
  int duration;
  int dumping;
  bool pinned;
  double maxOpacity;
  double initialOpacity;
  double titlePaddingLeft;
  double titlePaddingRight;
  double titleActiveFontSize;
  double headerHeight;
  Widget header;
  MainAxisAlignment mainAxisAlignment;
  Function(ScrollController, String, NetflixAppBar) onScreenChange;

  NetflixAppBar(List<DrTextTransitionTitleObject> titles, int duration,
      {Widget header,
      double headerHeight = 0,
      Color background = Colors.transparent,
      Color appBarColor,
      int dumping = 100,
      double titlePaddingLeft = 16,
      double titlePaddingRight = 15,
      double titleActiveFontSize = 20,
      double maxOpacity = 0.6,
      double initialOpacity = 0,
      bool pinned = false,
      TextStyle titleStyles = const TextStyle(
          color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
      Widget leading,
      Function(ScrollController, String, NetflixAppBar) onScreenChange,
      MainAxisAlignment mainAxisAlignment}) {
    if (titles == null || titles.isEmpty)
      throw new Exception("NetflixAppBar error: titles cannot be empty!");
    if (appBarColor == null) appBarColor = Colors.purpleAccent.withOpacity(0.7);

    this.onScreenChange = onScreenChange;
    this.header = header;
    this.headerHeight = headerHeight;
    this.appBarColor = appBarColor;
    this.titleStyles = titleStyles;
    this.titlePaddingLeft = titlePaddingLeft;
    this.titlePaddingRight = titlePaddingRight;
    this.titleActiveFontSize = titleActiveFontSize;
    this.background = background;
    this.dumping = dumping;
    this.titles = titles;
    this.maxOpacity = maxOpacity;
    this.initialOpacity = initialOpacity;
    this.leading = leading;
    this.pinned = pinned;
    this.duration = duration;
    this.mainAxisAlignment = mainAxisAlignment;

    if (this.titles[0].header != null) {
      this.header = this.titles[0].header;
      this.headerHeight = this.titles[0].headerHeight ?? this.headerHeight;
    }
  }

  static _NetflixAppBar instance;

  @override
  State<StatefulWidget> createState() {
    instance = _NetflixAppBar();
    return instance;
  }
}

class _NetflixAppBar extends State<NetflixAppBar>
    with AfterLayoutMixin<NetflixAppBar> {
  double get height => MediaQuery.of(context).size.height;

  double get width => MediaQuery.of(context).size.width;

  double get paddingTop => MediaQuery.of(context).padding.top;

  double get imageHeight => this.height * 0.75;

  /// <= -1 => TOOLBAR INVISIBLE
  /// 0 => TOOLBAR COMPLETELY VISIBLE
  set dumpingPercentage(double value) => this._dumpingPercentage = value > 0
      ? 0
      : value < -1
          ? -1
          : value;

  get dumpingPercentage => this._dumpingPercentage;

  double get getToolbarHeight => (kToolbarHeight + this.paddingTop);

  bool onAnimation = false;
  bool pause = false;

  Widget firstChild, secondChild;

  int onTransition = -1;
  double lastPos = 0;
  double amount = 0;
  double _dumpingPercentage = 0;
  ScrollController controller = new ScrollController();

  Color appBarColor;

  bool firstScroll = true;

  void notify() => setState(() {});

  void checkState() {
    this.pause = widget.titles[0].before != null;
    if (this.pause) {
      this.onTransition = 0;

      this.onAnimation = true;

      new Timer(Duration(milliseconds: this.halfDuration), () {
        setState(() {
          this.pause = false;
          this.onTransition = -1;
          this.onAnimation = false;
        });
      });
    }
  }

  double initValue = -1;
  bool inertialCond = false;

  @override
  void initState() {
    super.initState();
    checkState();
    controller.addListener(() => checkController());
  }

  void checkController() {
    double pos = controller.position.pixels;
    setState(() {
      if (!widget.pinned) {
        if (pos - this.lastPos < 0) {
          /// USER IS SCROLLING UP
          if (this.dumpingPercentage > -1 &&
              this.dumpingPercentage < 0 &&
              this.firstScroll) {
            /// - 3 -
            ///USER WAS MOVING DOWN
            ///DECIDED TO SCROLL UP , WE JUST INVERTED THE - 2 - FORMULA
            this.dumpingPercentage =
                0 - (pos - this.amount) / widget.dumping.abs();
          } else if (this.firstScroll && this.dumpingPercentage == -1) {
            /// - 4 -
            ///USER SCROLL DOWN UNTIL HE ISN'T SEEING MORE THE TOOLBAR
            ///WE GO TO - 5 -
            this.firstScroll = false;
            this.amount = pos;
          } else if (!this.firstScroll && this.dumpingPercentage < 0) {
            ///  - 5 -
            /// WE WILL MAKE AGAIN VISIBLE GRADUALLY THE TOOLBAR WHILE USER IS SCROLLING UP
            this.dumpingPercentage =
                -1 + (this.amount - pos) / widget.dumping.abs();
          } else {
            /// - 6 -
            /// USER SEES COMPLETELY THE TOOLBAR
            /// WE'LL COME BACK TO THE - 1 - STEP WHEN HE'LL SCROLL DOWN AGAIN
            this.amount = pos;
            this.firstScroll = true;
          }
        } else {
          if (!this.firstScroll && this.dumpingPercentage > -1) {
            /// - 1 -
            /// WE ARE IN THE STEP 5 SITUATION
            /// USER BEGAN TO SCROLL DOWN
            this.dumpingPercentage =
                -1 + (this.amount - pos) / widget.dumping.abs();
          } else if (this.firstScroll) {
            /// - 2 -
            /// WE BEGIN TO MOVE DOWN
            if (this.amount != -1)
              this.dumpingPercentage =
                  0 - (pos - this.amount) / widget.dumping.abs();
          } else {
            /// - 3 -
            /// - 1 - FUNCTION MAKES THE TOOLBAR INVISIBLE
            this.firstScroll = true;
            this.amount = -1;
          }
        }
      } else {
        /// NECESSARY IF YOU CHANGE THE PINNED VALUE
        this.amount = pos;
      }

      this.lastPos = pos;
      double perc = pos / widget.dumping.abs();
      perc = perc > widget.maxOpacity
          ? widget.maxOpacity
          : perc <= widget.initialOpacity
              ? widget.initialOpacity
              : perc;
      this.appBarColor = widget.appBarColor.withOpacity(perc);
    });
  }

  int get halfDuration => (widget.duration / 2).round();

  int get oneThirdDuration => (widget.duration / 3).round();

  int get duration => widget.duration;

  double get appBarPaddingTop => (this.getToolbarHeight - kToolbarHeight);

  void changeScreen(newTitles, oldTitles) {
    if (oldTitles != null) NetflixAppBar.previousTitles.add(oldTitles);
    var newMe = new NetflixAppBar(newTitles, widget.duration,
        pinned: widget.pinned,
        header: widget.header,
        headerHeight: widget.headerHeight,
        dumping: widget.dumping,
        background: widget.background,
        maxOpacity: widget.maxOpacity,
        initialOpacity: widget.initialOpacity,
        appBarColor: widget.appBarColor,
        titleStyles: widget.titleStyles,
        titlePaddingLeft: widget.titlePaddingLeft,
        titlePaddingRight: widget.titlePaddingRight,
        titleActiveFontSize: widget.titleActiveFontSize,
        leading: widget.leading,
        onScreenChange: widget.onScreenChange);
    var newRoute = PageTransition(
        child: newMe,
        type: PageTransitionType.fade,
        duration: Duration(milliseconds: this.halfDuration));
    Navigator.pushReplacement(context, newRoute);
  }

  @override
  Widget build(BuildContext context) {
    if (this.firstChild == null) {
      this.firstChild =
          this.pause ? widget.titles[0].before : widget.titles[0].current;
      this.secondChild = widget.titles[0].current;
    }

    return WillPopScope(
      child: Scaffold(
          backgroundColor: widget.background,
          body: Stack(children: [
            AnimatedPositioned(
                duration: Duration(
                    milliseconds:
                        this.pause ? this.halfDuration : this.duration),
                top: this.onAnimation ? -this.height * 0.6 : 0,
                left: 0,
                curve: this.onAnimation
                    ? Curves.fastLinearToSlowEaseIn
                    : Curves.fastLinearToSlowEaseIn,
                width: this.width,
                height:
                    this.height + (this.onAnimation ? this.height * 0.2 : 0),
                child: AnimatedOpacity(
                    curve: Curves.linear,
                    opacity: this.onAnimation ? 0.2 : 1,
                    duration: Duration(
                        milliseconds:
                            this.pause ? this.oneThirdDuration : this.duration),
                    child: SingleChildScrollView(
                        controller: this.controller,
                        child: AnimatedCrossFade(
                          duration:
                              Duration(milliseconds: this.oneThirdDuration),
                          secondCurve: Curves.linear,
                          firstChild: firstChild,
                          secondChild: secondChild,
                          crossFadeState: this.pause
                              ? CrossFadeState.showFirst
                              : CrossFadeState.showSecond,
                        )))),
            Positioned(
              top: widget.header == null ? 0 : -this.appBarPaddingTop,
              left: 0,
              width: this.width,
              height: this.getToolbarHeight + widget.headerHeight,
              child: Stack(children: [
                AnimatedPositioned(
                    top: 0 -
                        (widget.header == null
                                ? this.getToolbarHeight
                                : widget.headerHeight - this.appBarPaddingTop) *
                            this.dumpingPercentage.abs(),
                    left: 0,
                    duration: Duration(milliseconds: 80),
                    curve: Curves.linearToEaseOut,
                    width: this.width,
                    height: this.getToolbarHeight + widget.headerHeight,
                    child: Container(
                        child: Column(children: [
                      AppBar(
                        toolbarHeight: kToolbarHeight + widget.headerHeight,
                        backgroundColor: this.appBarColor,
                        title: Column(children: [
                          if (widget.header != null) widget.header,
                          Padding(
                              child: Flex(
                                  direction: Axis.horizontal,
                                  mainAxisAlignment:
                                      widget.mainAxisAlignment != null
                                          ? widget.mainAxisAlignment
                                          : widget.titles.length > 2
                                              ? MainAxisAlignment.spaceBetween
                                              : MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    for (int i = 0;
                                        i < widget.titles.length;
                                        i++)
                                      Flexible(
                                        child: GestureDetector(
                                            onTap: () {
                                              var $this = widget.titles[i];
                                              if ($this.overrideAction != null)
                                                $this.overrideAction();
                                              else {
                                                if (i != 0 &&
                                                    this.onTransition == -1) {
                                                  setState(() {
                                                    this.onTransition = i;
                                                  });

                                                  this.controller.animateTo(
                                                      0.00,
                                                      duration: Duration(
                                                        milliseconds: this
                                                            .oneThirdDuration,
                                                      ),
                                                      curve: Curves.easeInBack);

                                                  new Timer(
                                                      Duration(
                                                          milliseconds: this
                                                              .halfDuration),
                                                      () {
                                                    List<DrTextTransitionTitleObject>
                                                        titles = new List.from(
                                                            widget.titles);
                                                    if ($this.newTitles !=
                                                            null &&
                                                        $this.newTitles
                                                            .isNotEmpty) {
                                                      titles =
                                                          ($this.newTitles);
                                                    } else {
                                                      var temp = titles[0];
                                                      titles[0] = titles[i];
                                                      titles[i] = temp;
                                                    }
                                                    titles[0].before =
                                                        this.secondChild;

                                                    this.changeScreen(
                                                        titles, widget.titles);
                                                  });
                                                }
                                              }
                                            },
                                            child: Hero(
                                              tag: widget.titles[i].heroTag,
                                              child: Padding(
                                                  child: Material(
                                                      color: Colors.transparent,
                                                      child: AnimatedOpacity(
                                                          duration: Duration(
                                                              milliseconds: this
                                                                  .halfDuration),
                                                          opacity: this.onTransition ==
                                                                  -1
                                                              ? 1
                                                              : this.onTransition !=
                                                                      i
                                                                  ? 0
                                                                  : 1,
                                                          child: widget
                                                                  .titles[i]
                                                                  .personalized
                                                              ? widget.titles[i]
                                                                  .overrideWidget
                                                              : AnimatedDefaultTextStyle(
                                                                  duration: Duration(
                                                                      milliseconds:
                                                                          this
                                                                              .halfDuration),
                                                                  child: Text(
                                                                      widget.titles[i].name ??
                                                                          ""),
                                                                  style: widget.titles[0].style != null
                                                                      ? widget
                                                                          .titles[0]
                                                                          .style
                                                                      : widget.titleStyles.copyWith(fontSize: this.onTransition == i ? widget.titleActiveFontSize : widget.titleStyles.fontSize, fontWeight: this.onTransition == i ? FontWeight.w600 : FontWeight.w200)))),
                                                  padding: EdgeInsets.only(left: widget.titles[i].paddingLeft)),
                                            )),
                                      )
                                  ]),
                              padding: EdgeInsets.only(
                                  left: widget.titlePaddingLeft,
                                  right: widget.titlePaddingRight)),
                        ]),
                        leading: widget.leading,
                      )
                    ]))),
              ]),
            ),
            Positioned(
              top: 0,
              left: 0,
              width: this.width,
              height: this.appBarPaddingTop,
              child: Container(
                color: this.appBarColor,
              ),
            )
          ])),
      onWillPop: () async {
        if (NetflixAppBar.previousTitles.isEmpty)
          return true;
        else
          this.previousPage();
        return false;
      },
    );
  }

  void previousPage() {
    if (NetflixAppBar.previousTitles.isNotEmpty) {
      setState(() {
        this.onTransition = 0;
      });
      var newTitles = NetflixAppBar.previousTitles.last;
      NetflixAppBar.previousTitles.removeLast();
      new Timer(Duration(milliseconds: this.halfDuration), () {
        this.changeScreen(newTitles, null);
      });
    }
  }

  @override
  void afterFirstLayout(BuildContext context) {
    checkController();
    if (widget.onScreenChange != null)
      widget.onScreenChange(controller, widget.titles[0].heroTag, widget);
  }
}
