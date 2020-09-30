import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:services_discovery/bonsoir/discovery/discovery.dart';
import 'package:services_discovery/bonsoir/discovery/discovery_event.dart';
import 'package:services_discovery/bonsoir/discovery/resolved_service.dart';
import 'package:services_discovery/multicast_dns/multicast_dns.dart';
import 'package:services_discovery/utils/serviceInfo.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'services discovery',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: '设备发现'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Map<String, ServiceInfo> servicesInfoMap = {};
  bool isStart = false;
  MDnsClient client;
  BonsoirDiscovery discovery;
  Timer timer;
  String serviceType = '_lebai._tcp';

  void _addService(service){
    var name = service['name'];
    var ips = service['ips'];
    var port = service['port'];
    ServiceInfo sInfo = servicesInfoMap[name];
    
    ips = ips!=null?ips:[];
    if (sInfo!=null) {
      for(var ip in ips){
        sInfo.addIp(ip);
      }
    } else {
      servicesInfoMap[name] = ServiceInfo(
        name: name,
        ips: ips,
        port: port
      );
    }

    setState(() {
      servicesInfoMap = servicesInfoMap;
    });
  }

  void _startDiscovery() {
    isStart = true;
    if (mounted) {
      setState(() {
        isStart = isStart;
      });
    }
    if (Platform.isAndroid) {
      _startMdnsClient();
    } else if (Platform.isIOS) {
      _startNsd();
    }
  }

  void _stopDiscovery(){
    isStart = false;
    servicesInfoMap = {};
    if (mounted) {
      setState(() {
        servicesInfoMap = servicesInfoMap;
        isStart = isStart;
      });
    }
    if (Platform.isAndroid) {
      _cancelMdnsClient();
    } else if (Platform.isIOS) {
      _cancelNsd();
    }
  }

  void _startNsd() async {
    // Once defined, we can start the discovery :
    discovery = BonsoirDiscovery(type: serviceType);
    await discovery.ready;
    await discovery.start();

    // If you want to listen to the discovery :
    discovery.eventStream.listen((event) {
      if (event.type == BonsoirDiscoveryEventType.DISCOVERY_SERVICE_RESOLVED) {
        print('Service found : ${event.service.toJson()}');
        if (event.service!=null && event.service is ResolvedBonsoirService) {
          ResolvedBonsoirService service = event.service;
          _addService({
            'name': service.name,
            'port': service.port,
            'ips': [service.ip],
          });
        } 
         
      } else if (event.type == BonsoirDiscoveryEventType.DISCOVERY_SERVICE_LOST) {
        print('Service lost : ${event.service.toJson()}');
      }
    });
  }
  void _cancelNsd() async {
    if (discovery!=null) {
      discovery.stop();
      discovery = null;
    }
  }

  void _startMdnsClient() async {
    client = MDnsClient();
    await client.start();
    _checkMdnsClient();
    timer = Timer.periodic(Duration(seconds: 5), (timer) async {
      _checkMdnsClient();
    });
  }
  void _cancelMdnsClient() async {
    if (client != null) {
      client.stop();
      client = null;
    }
    if (timer!=null) {
      timer.cancel();
      timer = null;
    }
  }
  void _checkMdnsClient() async {
    client.clear();
    await for (PtrResourceRecord ptr in client
        .lookup<PtrResourceRecord>(ResourceRecordQuery.serverPointer(serviceType))) {

      await for (SrvResourceRecord srv in client.lookup<SrvResourceRecord>(
          ResourceRecordQuery.service(ptr.domainName))) {

        await for (IPAddressResourceRecord ip
            in client.lookup<IPAddressResourceRecord>(
                ResourceRecordQuery.addressIPv4(srv.target))) {
          _addService({
            'name': _getName(srv.target),
            'port': srv.port,
            'ips': [ip.address.address],
          });  
        }
      }
    }
  }
  String _getName(String name){
    int idx = name.indexOf('.local');
    if (idx!=-1) {
      name = name.substring(0, idx);
    }
    return name;
  }

  List<Widget> _getWidgets(){
    List<Widget> widgets = [];
    widgets.add(Text('发现的设备：(${servicesInfoMap.length})'));
    List<String> texts = [];
    for(var service in servicesInfoMap.values){
      texts.add('$service');
    }
    texts.sort();
    for(int i=0; i<texts.length; i++){
      var text = texts[i];
      widgets.add(Padding(
        padding: EdgeInsets.fromLTRB(0,10,0,10),
        child: Text(
          '(${i+1}), $text',
        ),
      ));
    }
    return widgets;
  }

  @override
  void dispose() {
    _stopDiscovery();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: _getWidgets(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: isStart?Colors.red[300]:Colors.green[300],
        onPressed: (){
          if (isStart) {
            _stopDiscovery();
          } else {
            _startDiscovery();
          }
        },
        tooltip: isStart?'停止':'启动',
        child: Icon(isStart?Icons.stop:Icons.play_arrow),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
