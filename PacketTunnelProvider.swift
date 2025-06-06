import NetworkExtension
import os.log
import Singbox // Import your Go framework bridge

class PacketTunnelProvider: NEPacketTunnelProvider {

    private let logger = OSLog(subsystem: "com.ns.vpn", category: "PacketTunnel")
    private var isSimulationMode = false

    override func startTunnel(options: [String : NSObject]?, completionHandler: @escaping (Error?) -> Void) {
        print("=== VPN Starting ===")
        print("Startup parameters: \(options ?? [:])")
        os_log("Starting VPN tunnel...", log: logger, type: .info)

        // VPN Configuration JSON
        let configJSON = """
        {
          "log": {
            "level": "info"
          },
          "inbounds": [
            {
              "type": "tun",
              "tag": "tun-in",
              "interface_name": "utun233",
              "inet4_address": "172.19.0.1/30",
              "mtu": 1500,
              "auto_route": true,
              "strict_route": true
            }
          ],
          "outbounds": [
            {
              "type": "vmess",
              "tag": "vmess-out",
              "server": "r3.wy888.us",
              "server_port": 443,
              "uuid": "b831381d-6324-4d53-ad4f-8cda48b30811",
              "security": "aes-128-gcm",
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
            }
          ],
          "route": {
            "auto_detect_interface": true
          },
          "dns": {
            "servers": [
              {
                "tag": "dns-remote",
                "address": "https://1.1.1.1/dns-query"
              },
              {
                "tag": "dns-local",
                "address": "8.8.8.8"
              }
            ]
          }
        }
        """

        print("VPN configuration prepared")
        print("Configuration length: \(configJSON.count) characters")

        // Network Settings
        let settings = NEPacketTunnelNetworkSettings(tunnelRemoteAddress: "172.19.0.2")
        settings.ipv4Settings = NEIPv4Settings(addresses: ["172.19.0.1"], subnetMasks: ["255.255.255.252"])
        settings.mtu = 1500
        settings.dnsSettings = NEDNSSettings(servers: ["8.8.8.8", "1.1.1.1"])

        print("Network settings configured, applying settings...")

        setTunnelNetworkSettings(settings) { error in
            if let error = error {
                print("❌ Failed to apply network settings: \(error.localizedDescription)")
                os_log("Failed to apply tunnel settings: %{public}@", log: self.logger, type: .error, error.localizedDescription)
                completionHandler(error)
                return
            }

            print("✅ Network settings applied successfully, starting SingBox engine...")

            let result = configJSON.withCString { cString in
                let pointer = UnsafeMutablePointer(mutating: cString)
                print("Pointer debug information:")
                print("  - Pointer address: \(String(format: "0x%llx", UInt(bitPattern: pointer)))")
                print("  - First 64 chars: \(String(cString: cString).prefix(64))")
                return StartSingbox(pointer)
            }

            print("StartSingbox call completed, return code: \(result)")

            if result != 0 {
                print("🚨 SINGBOX ENGINE STARTUP FAILED!")
                print("Error Code: \(result)")
                switch result {
                case 1:
                    print(" • JSON parsing error – check configuration format.")
                case 2:
                    print(" • Engine creation failed – possible system/Go runtime issue.")
                default:
                    print(" • Unknown error – code: \(result)")
                }

                print("⚠️ Activating simulation mode for fallback.")
                self.isSimulationMode = true
                os_log("Singbox failed to start, entering simulation mode. Code: %d", log: self.logger, type: .fault, result)
                completionHandler(nil)
            } else {
                print("✅ SingBox engine started successfully")
                self.isSimulationMode = false
                os_log("SingBox started successfully.", log: self.logger, type: .info)
                completionHandler(nil)
            }
        }
    }

    override func stopTunnel(with reason: NEProviderStopReason, completionHandler: @escaping () -> Void) {
        print("=== VPN Stopping ===")
        print("Stop reason: \(reason)")

        switch reason {
        case .userInitiated: print("User initiated stop.")
        case .providerFailed: print("Provider failed.")
        case .noNetworkAvailable: print("No network available.")
        case .unrecoverableNetworkChange: print("Unrecoverable network change.")
        case .configurationFailed: print("Configuration failed.")
        case .idleTimeout: print("Idle timeout.")
        case .configurationRemoved: print("Configuration removed.")
        case .connectionFailed: print("Connection failed.")
        case .appUpdate: print("App update.")
        case .internalError: print("Internal error.")
        default: print("Other reason: \(reason.rawValue)")
        }

        os_log("Stopping VPN tunnel...", log: logger, type: .info)

        if !isSimulationMode {
            print("Stopping SingBox engine...")
            StopSingbox()
            print("✅ SingBox engine stopped.")
        } else {
            print("⚠️ Simulation mode - Skipping engine stop.")
        }

        os_log("Singbox stopped.", log: logger, type: .info)
        completionHandler()
    }
}
