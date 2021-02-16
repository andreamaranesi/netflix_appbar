import 'package:flutter/cupertino.dart';

class app with ChangeNotifier {
  String currentTitle;

  void setTitle(String title) {
    this.currentTitle = title;
    notifyListeners();
  }
}
