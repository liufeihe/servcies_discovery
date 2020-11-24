package ltd.lebai.services_discovery.bonsoir

import android.net.nsd.NsdServiceInfo
import ltd.lebai.services_discovery.bonsoir.discovery.ResolvedServiceInfo
import java.util.*

/**
 * Sent to the event channel when there is no error.
 *
 * @param id The response id.
 * @param service The response service.
 */
data class SuccessObject(private val id: String, private val service: NsdServiceInfo? = null) {
    /**
     * Converts the current instance into a map.
     *
     * @param resolvedServiceInfo The resolved service info (if any).
     *
     * @return The map.
     */
    fun toJson(resolvedServiceInfo: ResolvedServiceInfo? = null): Map<String, Any> {
        val json: HashMap<String, Any> = HashMap()
        json["id"] = id
        if(service != null) {
            json["service"] = serviceToJson(service, resolvedServiceInfo ?: ResolvedServiceInfo(service))
        }
        return json
    }

    /**
     * Converts a given service to a map.
     *
     * @param service The service.
     * @param resolvedServiceInfo The resolved service info.
     *
     * @return The map.
     */
    private fun serviceToJson(service: NsdServiceInfo, resolvedServiceInfo: ResolvedServiceInfo = ResolvedServiceInfo(service)): Map<String, Any?> {
        return mapOf(
                "service.name" to service.serviceName,
                "service.type" to service.serviceType,
                "service.port" to resolvedServiceInfo.port,
                "service.ip" to resolvedServiceInfo.ip
        )
    }
}
