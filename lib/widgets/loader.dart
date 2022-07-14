import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Loader extends StatelessWidget {
  final bool isFullScreen;
  final bool isfullScreenWithBackgroundTransparent;
  final bool isLoading;
  final Color? loaderColor;
  final double loaderSize;

  const Loader({
    Key? key,
    this.isFullScreen = false,
    this.isfullScreenWithBackgroundTransparent = false,
    this.isLoading = false,
    this.loaderColor,
    this.loaderSize = 10,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      if (!isFullScreen) {
        return CupertinoActivityIndicator(
            animating: true,
            radius: loaderSize,
            color: loaderColor ?? Theme.of(context).primaryColor);
      } else {
        return Container(
          color: isfullScreenWithBackgroundTransparent
              ? Colors.transparent
              : Colors.black54,
          alignment: Alignment.center,
          child: CupertinoActivityIndicator(
              radius: loaderSize,
              animating: true,
              color: loaderColor ?? Theme.of(context).primaryColor),
        );
      }
    } else {
      return const SizedBox(
        height: 0,
        width: 0,
      );
    }
  }
}
