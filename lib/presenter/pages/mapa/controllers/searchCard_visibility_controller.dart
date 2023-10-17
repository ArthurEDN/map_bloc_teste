import 'package:flutter/material.dart';

class SearchCardVisibilityController extends ValueNotifier<bool> {
  SearchCardVisibilityController(): super(true);

  void setSearchCardVisible(){
    value = true;
    notifyListeners();
  }
  void setSearchCardInvisible(){
    value = false;
    notifyListeners();
  }
}