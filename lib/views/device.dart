import 'dart:async';

import 'package:flutter/material.dart';
import 'package:services_discovery/utils/route.dart';
import 'package:services_discovery/utils/screen.dart';
import 'package:webview_flutter/webview_flutter.dart';

class Device extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _DeviceState();
  }
}

class _DeviceState extends State<Device> {
  final Completer<WebViewController> _controller = Completer<WebViewController>();
  String _url = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Map<String,String> args = RouteHandler.getParamsFromRoute(context);
    _url = args['url'];
    print('url: $_url');
  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      body: Container(
        padding: EdgeInsets.only(top: ScreenUtils.getStatusBarH(context)),
        height: ScreenUtils.getScreenH(context),
        width: ScreenUtils.getScreenW(context),
        child: WebView(
          initialUrl: _url,
          javascriptMode: JavascriptMode.unrestricted,
          onWebViewCreated: (WebViewController webViewController){
            _controller.complete(webViewController);
          },
        ),
      ),
    );
  }
}