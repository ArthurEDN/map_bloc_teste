import 'package:flutter/material.dart';

class CustomBottomNavigationItemWidget extends StatelessWidget {
  final String title;
  final IconData icon;
  final ThemeData theme;
  final int indexItem;
  final Function() onPressFunc;
  final ValueNotifier<Brightness> brightness;
  final ValueNotifier<int> currentPageIndex;

  const CustomBottomNavigationItemWidget({
    Key? key,
    required this.title,
    required this.icon,
    required this.theme,
    required this.indexItem,
    required this.onPressFunc,
    required this.brightness,
    required this.currentPageIndex,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressFunc,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: Column(
          children: [
            Expanded(
              child: currentPageIndex.value == indexItem
                  ? Icon(
                      icon,
                      color: theme.primaryColor,
                      size: 32.0,
                    )
                  : Icon(
                      icon,
                      size: 30.0,
                      color: brightness.value == Brightness.dark
                              ? const Color(0xFFBDBDBD)
                              : const Color(0xFF000000),
                  ),
            ),
            Expanded(
              child: currentPageIndex.value == indexItem
                  ? Text(
                      title,
                      style: TextStyle(
                        color: theme.primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    )
                  : Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: brightness.value == Brightness.dark
                            ? const Color(0xFFBDBDBD)
                            : const Color(0xFF000000),
                      ),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
