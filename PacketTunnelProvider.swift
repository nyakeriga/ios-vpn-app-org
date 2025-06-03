import NetworkExtension
import os.log

class PacketTunnelProvider: NEPacketTunnelProvider {

    private var singboxProcess: Process?
    private let logger = OSLog(subsystem: Bundle.main.bundleIdentifier ?? "VPNApp", category: "PacketTunnel")

    override func startTunnel(options: [String : NSObject]?, completionHandler: @escaping (Error?) -> Void) {
        // Define the path for the Sing-box configuration
        let configDirectory = FileManager.default.temporaryDirectory
        let configPath = configDirectory.appendingPathComponent("singbox-config.json")

        // Define the Sing-box configuration
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

        // Write the configuration to the temporary file
        do {
            try configJSON.write(to: configPath, atomically: true, encoding: .utf8)
        } catch {
            os_log("Failed to write Sing-box configuration: %{public}@", log: logger, type: .error, error.localizedDescription)
            completionHandler(error)
            return
        }

        // Locate the Sing-box binary in the app bundle
        guard let singboxPath = Bundle.main.path(forResource: "sing-box", ofType: nil) else {
            let error = NSError(domain: "PacketTunnelProvider", code: 1, userInfo: [NSLocalizedDescriptionKey: "Sing-box binary not found in app bundle."])
            os_log("Sing-box binary not found.", log: logger, type: .error)
            completionHandler(error)
            return
        }

        // Initialize and configure the Sing-box process
        singboxProcess = Process()
        singboxProcess?.executableURL = URL(fileURLWithPath: singboxPath)
        singboxProcess?.arguments = ["run", "-c", configPath.path]
        singboxProcess?.standardOutput = FileHandle.nullDevice
        singboxProcess?.standardError = FileHandle.nullDevice

        // Start the Sing-box process
        do {
            try singboxProcess?.run()
        } catch {
            os_log("Failed to start Sing-box process: %{public}@", log: logger, type: .error, error.localizedDescription)
            completionHandler(error)
            return
        }

        // Configure the virtual network settings
        let tunnelNetworkSettings = NEPacketTunnelNetworkSettings(tunnelRemoteAddress: "10.0.0.1")
        tunnelNetworkSettings.ipv4Settings = NEIPv4Settings(addresses: ["10.0.0.2"], subnetMasks: ["255.255.255.0"])
        tunnelNetworkSettings.mtu = 1500
        tunnelNetworkSettings.dnsSettings = NEDNSSettings(servers: ["8.8.8.8"])

        // Apply the network settings
        setTunnelNetworkSettings(tunnelNetworkSettings) { [weak self] error in
            if let error = error {
                os_log("Failed to set tunnel network settings: %{public}@", log: self?.logger ?? .default, type: .error, error.localizedDescription)
                completionHandler(error)
            } else {
                os_log("Tunnel network settings applied successfully.", log: self?.logger ?? .default, type: .info)
                completionHandler(nil)
            }
        }
    }

    override func stopTunnel(with reason: NEProviderStopReason, completionHandler: @escaping () -> Void) {
        // Terminate the Sing-box process if it's running
        if let process = singboxProcess, process.isRunning {
            process.terminate()
            os_log("Sing-box process terminated.", log: logger, type: .info)
        }
        completionHandler()
    }
}
