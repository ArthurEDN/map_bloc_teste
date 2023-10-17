import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class SingleTouchRecognizerWidget extends StatelessWidget {
  final Widget child;
  SingleTouchRecognizerWidget({required this.child});

  @override
  Widget build(BuildContext context) {
    return RawGestureDetector(
      gestures: <Type,GestureRecognizerFactory> {
        _SingleTouchRecognizer:
        GestureRecognizerFactoryWithHandlers<_SingleTouchRecognizer>(
                () => _SingleTouchRecognizer(),
                (_SingleTouchRecognizer instance) {}
        )
      },
      child: child,
    );
  }
}

class _SingleTouchRecognizer extends OneSequenceGestureRecognizer {
  int _p = 0;

  @override
  void addAllowedPointer(PointerDownEvent event) {
    startTrackingPointer(event.pointer);
    if (_p == 0) {
      resolve(GestureDisposition.rejected);
      _p = event.pointer;
    } else {
      resolve(GestureDisposition.accepted);
    }
  }

  @override
  void handleEvent(PointerEvent event) {
    if (!event.down && event.pointer == _p) {
      _p = 0;
    }
  }

  @override
  String get debugDescription => throw UnimplementedError();

  @override
  void didStopTrackingLastPointer(int pointer) {}
}