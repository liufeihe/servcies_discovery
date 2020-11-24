package ltd.lebai.services_discovery.bonsoir

import android.content.Context
import android.net.nsd.NsdManager
import android.net.nsd.NsdServiceInfo
import android.net.wifi.WifiManager
import androidx.annotation.NonNull
import ltd.lebai.services_discovery.bonsoir.broadcast.BonsoirRegistrationListener
import ltd.lebai.services_discovery.bonsoir.discovery.BonsoirDiscoveryListener
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.util.*


/**
 * Allows to handle method calls.
 *
 * @param applicationContext The application context.
 * @param multicastLock The current multicast lock.
 * @param messenger The binary messenger.
 */
class MethodCallHandler(
        private val applicationContext: Context,
        private val multicastLock: WifiManager.MulticastLock,
        private val messenger: BinaryMessenger
) : MethodChannel.MethodCallHandler {
    /**
     * Contains all registration listeners (Broadcast).
     */
    private val registrationListeners: HashMap<Int, BonsoirRegistrationListener> = HashMap()

    /**
     * Contains all discovery listeners (Discovery).
     */
    private val discoveryListeners: HashMap<Int, BonsoirDiscoveryListener> = HashMap()

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: MethodChannel.Result) {
        val nsdManager: NsdManager = applicationContext.getSystemService(Context.NSD_SERVICE) as NsdManager
        val id: Int = call.argument("id")!!
        when (call.method) {
            "broadcast.initialize" -> {
                registrationListeners[id] = BonsoirRegistrationListener(id, call.argument("printLogs")!!, Runnable {
                    multicastLock.release()
                    registrationListeners.remove(id)
                }, nsdManager, messenger)
                result.success(true)
            }
            "broadcast.start" -> {
                multicastLock.acquire()

                val service = NsdServiceInfo()
                service.serviceName = call.argument("service.name")
                service.serviceType = call.argument("service.type")
                service.port = call.argument("service.port")!!

                nsdManager.registerService(service, NsdManager.PROTOCOL_DNS_SD, registrationListeners[id])
                result.success(true)
            }
            "broadcast.stop" -> {
                registrationListeners[id]?.dispose()
                result.success(true)
            }
            "discovery.initialize" -> {
                discoveryListeners[id] = BonsoirDiscoveryListener(id, call.argument("printLogs")!!, Runnable {
                    multicastLock.release()
                    discoveryListeners.remove(id)
                }, nsdManager, messenger)
                result.success(true)
            }
            "discovery.start" -> {
                multicastLock.acquire()

                nsdManager.discoverServices(call.argument("type"), NsdManager.PROTOCOL_DNS_SD, discoveryListeners[id])
                result.success(true)
            }
            "discovery.stop" -> {
                discoveryListeners[id]?.dispose()
                result.success(true)
            }
            else -> result.notImplemented()
        }
    }

    /**
     * Disposes the current instance.
     */
    fun dispose() {
        for (registrationListener in ArrayList<BonsoirRegistrationListener>(registrationListeners.values)) {
            registrationListener.dispose()
        }
        for (discoveryListener in ArrayList<BonsoirDiscoveryListener>(discoveryListeners.values)) {
            discoveryListener.dispose()
        }
    }
}