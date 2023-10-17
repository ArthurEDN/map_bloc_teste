import 'package:flutter/material.dart';

class SearchAutoCompleteWidgetVisibilityController extends ValueNotifier<bool>{
  SearchAutoCompleteWidgetVisibilityController() : super(false);

  void setSearchAutoCompleteWidgetVisible() {
    value = true;
    notifyListeners();
  }
  void setSearchAutoCompleteWidgetInvisible(){
    value = false;
    notifyListeners();
  }
}