import 'package:flutter/material.dart';

class BottomNavigationVisibilityController extends ValueNotifier<bool>{
  BottomNavigationVisibilityController() : super(true);

  void setBottomNavigationVisible(){
    value = true;
    notifyListeners();
  }
  void setBottomNavigationInvisible(){
    value = false;
    notifyListeners();
  }
}