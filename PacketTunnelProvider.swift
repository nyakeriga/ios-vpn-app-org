import NetworkExtension
import os.log

class PacketTunnelProvider: NEPacketTunnelProvider {

    private let logger = OSLog(subsystem: Bundle.main.bundleIdentifier ?? "VPNApp", category: "PacketTunnel")

    override func startTunnel(options: [String : NSObject]?, completionHandler: @escaping (Error?) -> Void) {
        os_log("Starting VPN tunnel...", log: logger, type: .info)

        // Create the JSON config string (can be customized later)
        let configJSON = """
        {
          "log": {
            "level": "info"
          },
          "inbounds": [{
            "type": "tun",
            "tag": "tun-in",
            "interface_name": "utun2",
            "inet4_address": "10.0.0.2/24",
            "mtu": 1500,
            "auto_route": true,
            "strict_route": false
          }],
          "outbounds": [{
            "type": "vmess",
            "tag": "vmess-out",
            "server": "r3.wy888.us",
            "server_port": 443,
            "uuid": "b831381d-6324-4d53-ad4f-8cda48b30811",
            "security": "auto",
            "tls": {
              "enabled": true,
              "server_name": "r3.wy888.us"
            },
            "transport": {
              "type": "ws",
              "path": "/ray",
              "headers": {
                "Host": "r3.wy888.us"
              }
            }
          }],
          "route": {
            "auto_route": true,
            "geoip": true
          },
          "dns": {
            "servers": [
              {
                "tag": "dns-remote",
                "address": "8.8.8.8"
              }
            ]
          }
        }
        """

        // Set up virtual interface settings for the tunnel
        let settings = NEPacketTunnelNetworkSettings(tunnelRemoteAddress: "10.0.0.1")
        settings.ipv4Settings = NEIPv4Settings(addresses: ["10.0.0.2"], subnetMasks: ["255.255.255.0"])
        settings.mtu = 1500
        settings.dnsSettings = NEDNSSettings(servers: ["8.8.8.8"])

        setTunnelNetworkSettings(settings) { [weak self] error in
            guard let self = self else { return }

            if let error = error {
                os_log("Failed to apply tunnel settings: %{public}@", log: self.logger, type: .error, error.localizedDescription)
                completionHandler(error)
                return
            }

            // Start the embedded Sing-box engine
            let startResult = libbox_start(configJSON)
            if startResult != 0 {
                os_log("libbox_start() failed with code: %d", log: self.logger, type: .error, startResult)
                completionHandler(NSError(domain: "PacketTunnelProvider", code: Int(startResult), userInfo: [NSLocalizedDescriptionKey: "libbox_start failed"]))
            } else {
                os_log("Sing-box engine started successfully.", log: self.logger, type: .info)
                completionHandler(nil)
            }
        }
    }

    override func stopTunnel(with reason: NEProviderStopReason, completionHandler: @escaping () -> Void) {
        os_log("Stopping tunnel...", log: logger, type: .info)
        libbox_stop()
        os_log("Sing-box engine stopped.", log: logger, type: .info)
        completionHandler()
    }
}
