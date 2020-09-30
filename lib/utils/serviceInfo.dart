class ServiceInfo {
  String name;
  List<String> ips = [];
  int port;

  ServiceInfo({
    this.name: '',
    this.ips,
    this.port: 80,
  });

  void addIp(ip){
    if (!this.ips.contains(ip)) {
      this.ips.add(ip);
    }
  }

  ServiceInfo copyWith(ServiceInfo ser){
    return ServiceInfo(
      name: ser.name ?? this.name,
      ips: ser.ips ?? this.ips,
      port: ser.port ?? this.port, 
    );
  }

  String toString()=>
    'name: $name, \n    ips: $ips, port: $port';

}