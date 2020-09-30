import 'package:flutter/material.dart';

class RouteHandler {
  static Future<void> goTo(context, routeName, {arguments}) async {
    await Navigator.pushNamed(context, routeName, arguments: arguments);
  }
  static void replaceRouteWith(context, routeName, {arguments}) {
    Navigator.pushReplacementNamed(context, routeName, arguments: arguments);
  }

  static dynamic getParamsFromRoute(context) {
    return ModalRoute.of(context).settings.arguments;
  }
  
  static void popOnce(context, [arguments]) {
    Navigator.pop(context, arguments);
  }
  static void popUntil(context, routeName) {
    Navigator.popUntil(context, ModalRoute.withName(routeName));
  }
  static void popAllAndGoTo(context, routeName) {
    Navigator.pushNamedAndRemoveUntil(context, routeName, (route)=>false);
  }
  
}