import 'package:flutter/material.dart';
import 'package:map_bloc_teste/presenter/pages/mapa/controllers/search_auto_complete_widget_visibility_controller.dart';

class CustomSearchCardWidget extends StatelessWidget {
  final String title;
  final ThemeData theme;
  final SearchAutoCompleteWidgetVisibilityController autoCompleteWidgetVisibilityController;

  const CustomSearchCardWidget({
    Key? key,
    required this.title,
    required this.autoCompleteWidgetVisibilityController,
    required this.theme,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
        children: [
          IconButton(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            hoverColor: Colors.transparent,
            padding: EdgeInsets.zero,
            icon: const Icon(Icons.arrow_back),
            color: theme.primaryColor,
            onPressed: () async {
              await Future.delayed(const Duration(milliseconds: 500)).then((value){
                Navigator.popUntil(context, (route) => route.settings.name == "/nav");
              });
            },
          ),
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF757575),
              fontSize: 20,
              fontWeight: FontWeight.normal,
              fontFamily: 'Open Sans'
            ),
          ),
          const Spacer(),
          IconButton(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              hoverColor: Colors.transparent,
              padding: EdgeInsets.zero,
              icon: Icon(Icons.search, color: theme.primaryColor,),
              onPressed: autoCompleteWidgetVisibilityController.setSearchAutoCompleteWidgetVisible,
          ),
        ]
    );
  }
}
