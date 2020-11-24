package ltd.lebai.services_discovery.bonsoir.discovery

import android.net.nsd.NsdManager
import android.net.nsd.NsdServiceInfo
import android.os.Handler
import android.os.Looper
import android.util.Log
import ltd.lebai.services_discovery.bonsoir.BonsoirPlugin
import ltd.lebai.services_discovery.bonsoir.SuccessObject
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel

/**
 * Allows to find NSD services on local network.
 *
 * @param id The listener identifier.
 * @param printLogs Whether to print debug logs.
 * @param onDispose Triggered when this instance is being disposed.
 * @param nsdManager The NSD manager.
 * @param messenger The Flutter binary messenger.
 */
class BonsoirDiscoveryListener(
        private val id: Int,
        private val printLogs: Boolean,
        private val onDispose: Runnable,
        private val nsdManager: NsdManager,
        messenger: BinaryMessenger
) : NsdManager.DiscoveryListener {

    /**
     * The current event channel.
     */
    private val eventChannel: EventChannel = EventChannel(messenger, "${BonsoirPlugin.channel}.discovery.$id")

    /**
     * The current event sink.
     */
    private var eventSink: EventChannel.EventSink? = null

    /**
     * The current resolver instance.
     */
    private val resolver: Resolver

    /**
     * Initializes this instance.
     */
    init {
        eventChannel.setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, eventSink: EventChannel.EventSink) {
                this@BonsoirDiscoveryListener.eventSink = eventSink
            }

            override fun onCancel(arguments: Any?) {
                eventSink = null
            }
        })
        resolver = Resolver(nsdManager, ::onServiceResolved, ::onFailedToResolveService)
    }

    override fun onDiscoveryStarted(regType: String) {
        if (printLogs) {
            Log.d(BonsoirPlugin.tag, "[$id] Bonsoir discovery started : $regType")
        }

        Handler(Looper.getMainLooper()).post {
            eventSink?.success(SuccessObject("discovery_started").toJson())
        }
    }

    override fun onStartDiscoveryFailed(serviceType: String, errorCode: Int) {
        if (printLogs) {
            Log.d(BonsoirPlugin.tag, "[$id] Bonsoir failed to start discovery : $errorCode")
        }

        Handler(Looper.getMainLooper()).post {
            eventSink?.error("discovery_error", "Bonsoir failed to start discovery", errorCode)
        }
        dispose()
    }

    override fun onServiceFound(service: NsdServiceInfo) {
        if (printLogs) {
            Log.d(BonsoirPlugin.tag, "[$id] Bonsoir has found a service : $service")
        }

        Handler(Looper.getMainLooper()).post {
            eventSink?.success(SuccessObject("discovery_service_found", service).toJson(resolver.getResolvedServiceIpAddress(service)))
        }

        resolver.onServiceFound(service)
    }

    override fun onServiceLost(service: NsdServiceInfo) {
        val resolvedServiceInfo: ResolvedServiceInfo = resolver.getResolvedServiceIpAddress(service)
        resolver.onServiceLost(service)

        if (printLogs) {
            Log.d(BonsoirPlugin.tag, "[$id] A Bonsoir service has been lost : $service")
        }

        Handler(Looper.getMainLooper()).post {
            eventSink?.success(SuccessObject("discovery_service_lost", service).toJson(resolvedServiceInfo))
        }
    }

    override fun onDiscoveryStopped(serviceType: String) {
        if (printLogs) {
            Log.d(BonsoirPlugin.tag, "[$id] Bonsoir discovery stopped : $serviceType")
        }

        Handler(Looper.getMainLooper()).post {
            eventSink?.success(SuccessObject("discovery_stopped").toJson())
        }
        //dispose(false)
    }

    override fun onStopDiscoveryFailed(serviceType: String, errorCode: Int) {
        if (printLogs) {
            Log.d(BonsoirPlugin.tag, "[$id] Bonsoir has encountered an error while stopping the discovery : $errorCode")
        }

        Handler(Looper.getMainLooper()).post {
            eventSink?.error("discovery_error", "Bonsoir has encountered an error while stopping the discovery", errorCode)
        }
        //dispose()
    }

    /**
     * Triggered when a service has been resolved.
     */
    private fun onServiceResolved(service: NsdServiceInfo) {
        if (printLogs) {
            Log.d(BonsoirPlugin.tag, "[$id] Bonsoir has resolved a service : $service")
        }

        Handler(Looper.getMainLooper()).post {
            eventSink?.success(SuccessObject("discovery_service_resolved", service).toJson(resolver.getResolvedServiceIpAddress(service)))
        }
    }

    /**
     * Triggered when a service failed to resolve.
     */
    private fun onFailedToResolveService(service: NsdServiceInfo, errorCode: Int) {
        if (printLogs) {
            Log.d(BonsoirPlugin.tag, "[$id] Bonsoir has failed to resolve a service : $errorCode")
        }

        Handler(Looper.getMainLooper()).post {
            eventSink?.success(SuccessObject("discovery_service_resolve_failed", service).toJson(resolver.getResolvedServiceIpAddress(service)))
        }
    }

    /**
     * Disposes the current class instance.
     */
    fun dispose(stopDiscovery: Boolean = true) {
        if (stopDiscovery) {
            nsdManager.stopServiceDiscovery(this)
        }
        resolver.dispose()
        onDispose.run()
    }
}
