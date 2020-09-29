import 'package:services_discovery/bonsoir/bonsoir_class.dart';
import 'package:services_discovery/bonsoir/broadcast/broadcast_event.dart';
import 'package:services_discovery/bonsoir/service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Allows to broadcast a service on the network.
class BonsoirBroadcast extends BonsoirClass<BonsoirBroadcastEvent> {
  /// The service to broadcast.
  final BonsoirService service;

  /// Creates a new Bonsoir broadcast instance.
  BonsoirBroadcast({
    bool printLogs = kDebugMode,
    @required this.service,
  }) : super(
          classType: 'broadcast',
          printLogs: printLogs,
        );

  @override
  @protected
  BonsoirBroadcastEvent transformPlatformEvent(dynamic event) {
    Map<dynamic, dynamic> data = Map<String, dynamic>.from(event);
    return BonsoirBroadcastEvent.fromJson(data);
  }

  @override
  @protected
  Map<String, dynamic> toJson() => {
        ...super.toJson(),
        ...service.toJson(),
      };
}
