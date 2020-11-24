import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:bonsoir/bonsoir.dart';
import 'package:flutter/material.dart';
// import 'package:services_discovery/bonsoir/discovery/discovery.dart';
// import 'package:services_discovery/bonsoir/discovery/discovery_event.dart';
// import 'package:services_discovery/bonsoir/discovery/resolved_service.dart';
import 'package:services_discovery/multicast_dns/multicast_dns.dart';
import 'package:services_discovery/utils/colorConstant.dart';
import 'package:services_discovery/utils/route.dart';
import 'package:services_discovery/utils/screen.dart';
import 'package:services_discovery/utils/serviceInfo.dart';
import 'package:services_discovery/views/device.dart';
import 'package:services_discovery/widgets/itemContainer.dart';

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
        primaryColor:  ColorConstant.themeRedColor,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: '机器人列表'),
      routes: {
        '/device': (context)=>Device(),
      }
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
  Map<String, int> servicesInfoMap = {};
  List<ServiceInfo> servicesInfoList = [];
  List<ServiceInfo> servicesInfoShowList = [];
  bool isStart = false;
  MDnsClient client;
  BonsoirDiscovery discovery;
  Timer timer;
  String serviceType = '_lebai._tcp';
  String _netIp = '';

  void _addService(service) async {
    var name = service['name'];
    var ips = service['ips'];
    var port = service['port'];
    ips = ips!=null?ips:[];

    _netIp = await getNetworkIpFromConnect();

    int idx = servicesInfoMap[name];
    if (idx!=null) {
      ServiceInfo sInfo = servicesInfoList[idx];
      for(var ip in ips){
        sInfo.addIp(ip);
      }
    } else {
      servicesInfoMap[name] = servicesInfoList.length;
      servicesInfoList.add(ServiceInfo(
        name: name,
        ips: ips,
        port: port
      ));
    }

    servicesInfoShowList = [];
    for(int i=0; i<servicesInfoList.length; i++){
      servicesInfoShowList.add(ServiceInfo().copyWith(servicesInfoList[i]));
    }
    servicesInfoShowList.sort((left,right)=>left.name.compareTo(right.name));

    setState(() {
      servicesInfoMap = servicesInfoMap;
      servicesInfoList = servicesInfoList;
      servicesInfoShowList = servicesInfoShowList;
    });
  }

  void _startDiscovery() {
    isStart = true;
    if (mounted) {
      setState(() {
        isStart = isStart;
      });
    }
    _startMdnsClient();
    // _startNsd();
    // if (Platform.isAndroid) {
    //   _startMdnsClient();
    // } else if (Platform.isIOS) {
    //   _startNsd();
    // }
  }

  void _stopDiscovery(){
    isStart = false;
    servicesInfoShowList = [];
    servicesInfoList = [];
    servicesInfoMap = {};
    if (mounted) {
      setState(() {
        servicesInfoShowList = servicesInfoShowList;
        servicesInfoList = servicesInfoList;
        servicesInfoMap = servicesInfoMap;
        isStart = isStart;
      });
    }

    _cancelMdnsClient();
    // _cancelNsd();
    // if (Platform.isAndroid) {
    //   _cancelMdnsClient();
    // } else if (Platform.isIOS) {
    //   _cancelNsd();
    // }
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

  Future<String> getNetworkIpFromConnect() async {
    String netIp='';
    for (var interface in await NetworkInterface.list()) {
      for (var addr in interface.addresses) {
        if (addr.type == InternetAddressType.IPv4) {
          netIp = addr.address;
          break;
        }
      }
    }
    return netIp;
  }

  String _getIp(List<String> ips) {
    String ip = '';
    if (ips.length==1) {
      ip = ips[0];
      return ip;
    }

    List<int> dst = _getIpArrFromStr(_netIp);
    if (dst.length==0) {
      ip = ips[0];
      return ip;
    }

    List<List<int>> ipIntArr = [];
    for (int i=0; i<ips.length; i++) {
      List<int> temp = _getIpArrFromStr(ips[i]);
      if (temp.length==4) {
        ipIntArr.add(temp);
      }
    }
    
    List<int> ipSumArr = [];
    for(int i=0; i<ipIntArr.length; i++) {
      int sum=0, n;
      for(int j=0; j<dst.length; j++){
        n = (ipIntArr[i][j]-dst[j]).abs();
        ipIntArr[i][j] = n;
        sum += n * pow(255, dst.length-1-j);
      }
      ipSumArr.add(sum);
    }
    // print(ipIntArr);
    // print(ipSumArr);
    int idx = -1;
    if (ipSumArr.length>0) {
      int m = ipSumArr[0];
      idx = 0;
      for (int i=1; i<ipSumArr.length; i++) {
        if (m>ipSumArr[i]) {
          m = ipSumArr[i];
          idx = i;
        }
      }
    }
    if (idx!=-1) {
      ip = ips[idx];
    }
    return ip;
  }
  List<int> _getIpArrFromStr(String ipStr){
    List<String> ipStrList = ipStr.split('.');
    List<int> ipIntList = [];
    if (ipStrList.length==4) {
      for(int i=0; i<ipStrList.length; i++) {
      ipIntList.add(int.parse(ipStrList[i]));
    }
    }
    return ipIntList;
  }

  @override
  void initState() {
    Future.delayed(Duration(milliseconds: 100), (){
      _startDiscovery();
    });
    super.initState();
  }

  @override
  void dispose() {
    _stopDiscovery();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        toolbarHeight: 60,
      ),
      body: SingleChildScrollView(
        child: Container(
          color: ColorConstant.bgGreyColor1,
          height: ScreenUtils.getScreenH(context)-ScreenUtils.getStatusBarH(context)-60,
          child: ListView.builder(
            itemCount: servicesInfoShowList.length,
            itemBuilder: (context, index) {
              ServiceInfo service = servicesInfoShowList[index];
              return ListTile(
                contentPadding: EdgeInsets.zero,
                title: _DeviceItem(
                  idx: index,
                  name: service.name,
                  ip: _getIp(service.ips),
                  tapCallback: () {
                    var ip = _getIp(service.ips);
                    var port = service.port;
                    var url = 'http://$ip:$port/dashboard/#/login?code=1111&redirect=/main';
                    RouteHandler.goTo(context, '/device', arguments: {'url': url});
                  }
                ),
              );
            }
          ),
        )
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
        tooltip: isStart?'停止':'扫描',
        child: Icon(isStart?Icons.stop:Icons.play_arrow),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

void voidCallback(){}
class _DeviceItem extends StatelessWidget {
  final int idx;
  final String name;
  final String ip;
  final Function tapCallback;

  _DeviceItem({
    this.idx,
    this.name,
    this.ip,
    this.tapCallback: voidCallback,
  });

  String _trimName(String name) {
    var idx = name.indexOf('[');
    if (idx!=-1) {
      name = name.substring(0, idx);
    }
    return name;
  }
  // String _getIps(List<String> ips){    
  //   return ips.join('/');
  // }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        tapCallback();
      },
      child: ItemContainer(
        margin: EdgeInsets.fromLTRB(15, 3, 15, 3),
        item: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              '${_trimName(name)}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: WeightStyle.bold,
                color: ColorConstant.textBlack3,
              ),
            ),
            Container(
              margin: EdgeInsets.only(top:10),
              width: double.infinity,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    '$ip',
                    style: TextStyle(
                      fontSize: 12,
                      color: ColorConstant.textColorGreyDeep,
                    ),
                  ),
                  Text(
                    '${idx+1}',
                    style: TextStyle(
                      fontSize: 16,
                      color: ColorConstant.textColorBlackShallow,
                    ),
                  ),
                ],
              ),
            ),
          ],
        )
      ),
    );
  }
}
