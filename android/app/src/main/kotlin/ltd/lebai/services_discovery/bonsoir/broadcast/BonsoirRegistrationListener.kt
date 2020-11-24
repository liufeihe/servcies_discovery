package ltd.lebai.services_discovery.bonsoir.broadcast

import android.net.nsd.NsdManager
import android.net.nsd.NsdServiceInfo
import android.util.Log
import ltd.lebai.services_discovery.bonsoir.BonsoirPlugin
import ltd.lebai.services_discovery.bonsoir.SuccessObject
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.EventChannel.EventSink

/**
 * Allows to broadcast a NSD service on local network.
 *
 * @param id The listener identifier.
 * @param printLogs Whether to print debug logs.
 * @param onDispose Triggered when this instance is being disposed.
 * @param nsdManager The NSD manager.
 * @param messenger The Flutter binary messenger.
 */
class BonsoirRegistrationListener(
        private val id: Int,
        private val printLogs: Boolean,
        private val onDispose: Runnable,
        private val nsdManager: NsdManager,
        messenger: BinaryMessenger
) : NsdManager.RegistrationListener {

    /**
     * The current event channel.
     */
    private val eventChannel: EventChannel = EventChannel(messenger, "${BonsoirPlugin.channel}.broadcast.$id")

    /**
     * The current event sink.
     */
    private var eventSink: EventSink? = null

    /**
     * Initializes this instance.
     */
    init {
        eventChannel.setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, eventSink: EventSink) {
                this@BonsoirRegistrationListener.eventSink = eventSink
            }

            override fun onCancel(arguments: Any?) {
                eventSink = null
            }
        })
    }

    override fun onServiceRegistered(service: NsdServiceInfo) {
        if (printLogs) {
            Log.d(BonsoirPlugin.tag, "[$id] Bonsoir service registered : $service")
        }
        eventSink?.success(SuccessObject("broadcast_started", service).toJson())
    }

    override fun onRegistrationFailed(service: NsdServiceInfo, errorCode: Int) {
        if (printLogs) {
            Log.d(BonsoirPlugin.tag, "[$id] Bonsoir service registration failed : $service, error code : $errorCode")
        }
        eventSink?.error("broadcast_error", "Bonsoir service registration failed.", errorCode)
        dispose()
    }

    override fun onServiceUnregistered(service: NsdServiceInfo) {
        if (printLogs) {
            Log.d(BonsoirPlugin.tag, "[$id] Bonsoir service broadcast stopped : $service")
        }
        eventSink?.success(SuccessObject("broadcast_stopped", service).toJson())
        //dispose(false)
    }

    override fun onUnregistrationFailed(service: NsdServiceInfo, errorCode: Int) {
        if (printLogs) {
            Log.d(BonsoirPlugin.tag, "[$id] Bonsoir service unregistration failed : $service, error code : $errorCode")
        }
        eventSink?.error("broadcast_error", "Bonsoir service unregistration failed.", errorCode)
        //dispose()
    }

    /**
     * Disposes the current class instance.
     */
    fun dispose(unregister: Boolean = true) {
        if(unregister) {
            nsdManager.unregisterService(this)
        }
        onDispose.run()
    }
}