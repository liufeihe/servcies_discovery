import 'package:flutter/widgets.dart';

class ScreenUtils {

  static double _designW = 375;
  static double _designH = 667;

  static double getScreenDensity(BuildContext context) {
    return MediaQuery.of(context).devicePixelRatio;
  }

  static double getScreenW(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  static double getScreenH(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  static double getStatusBarH(BuildContext context) {
    return MediaQuery.of(context).padding.top;
  }

  static double getContentH(BuildContext context) {
    return getScreenH(context)-getStatusBarH(context)-60;//CfgConstant.HEADER_BAR_HEIGHT;
  }

  static double getBottomBarH(BuildContext context) {
    return MediaQuery.of(context).padding.bottom;
  }

  static double getScaleW(BuildContext context, double size) {
    double screenW = getScreenW(context);
    if (context==null || screenW==0.0) {
      return size;
    }
    return size * screenW / _designW;
  }

  static double getScaleH(BuildContext context, double size) {
    double screenH = getScreenH(context);
    if (context==null || screenH==0.0) {
      return size;
    }
    return size * screenH / _designH;
  }

}