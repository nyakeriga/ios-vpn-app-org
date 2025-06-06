import NetworkExtension
import os.log
import Singbox
import Foundation

class PacketTunnelProvider: NEPacketTunnelProvider {

    private let logger = OSLog(subsystem: "com.ns.vpn", category: "PacketTunnel")
    private var isSimulationMode = false
    private var logFileHandle: FileHandle?
    private var packetCountTimer: Timer?

    override func startTunnel(options: [String : NSObject]?, completionHandler: @escaping (Error?) -> Void) {
        print("=== VPN Starting ===")
        log("VPN Start: \(options ?? [:])")

        setupFileLogging()

        // VPN Configuration JSON (same as before)
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

        // Tunnel settings
        let settings = NEPacketTunnelNetworkSettings(tunnelRemoteAddress: "172.19.0.2")
        settings.ipv4Settings = NEIPv4Settings(addresses: ["172.19.0.1"], subnetMasks: ["255.255.255.252"])
        settings.mtu = 1500
        settings.dnsSettings = NEDNSSettings(servers: ["8.8.8.8", "1.1.1.1"])

        log("Applying tunnel settings...")

        setTunnelNetworkSettings(settings) { error in
            if let error = error {
                self.log("❌ Tunnel settings error: \(error.localizedDescription)")
                completionHandler(error)
                return
            }

            self.log("✅ Tunnel settings applied. Starting Singbox...")

            let result = configJSON.withCString { cString in
                let pointer = UnsafeMutablePointer(mutating: cString)
                return StartSingbox(pointer)
            }

            if result != 0 {
                self.log("🚨 StartSingbox failed (code \(result)) – falling back to simulation mode.")
                self.isSimulationMode = true
                completionHandler(nil)
            } else {
                self.log("✅ Singbox started successfully.")
                self.isSimulationMode = false
                self.startPacketLogging()
                completionHandler(nil)
            }
        }
    }

    override func stopTunnel(with reason: NEProviderStopReason, completionHandler: @escaping () -> Void) {
        log("=== VPN Stopping: Reason \(reason.rawValue) ===")

        if !isSimulationMode {
            StopSingbox()
            log("✅ Singbox engine stopped.")
        }

        packetCountTimer?.invalidate()
        logFileHandle?.closeFile()
        logFileHandle = nil

        completionHandler()
    }

    // MARK: - Helpers

    private func setupFileLogging() {
        let fileManager = FileManager.default
        let logsURL = fileManager.containerURL(forSecurityApplicationGroupIdentifier: "group.com.ns.vpn")?.appendingPathComponent("vpn.log")

        if let url = logsURL {
            if !fileManager.fileExists(atPath: url.path) {
                fileManager.createFile(atPath: url.path, contents: nil, attributes: nil)
            }
            do {
                logFileHandle = try FileHandle(forWritingTo: url)
                logFileHandle?.seekToEndOfFile()
                log("📄 Log file initialized at \(url.path)")
            } catch {
                print("⚠️ Failed to open log file: \(error)")
            }
        }
    }

    private func log(_ message: String) {
        let timestamp = ISO8601DateFormatter().string(from: Date())
        let fullMessage = "[\(timestamp)] \(message)\n"
        print(fullMessage)

        if let data = fullMessage.data(using: .utf8) {
            logFileHandle?.write(data)
        }
    }

    private func startPacketLogging() {
        packetCountTimer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: true) { [weak self] _ in
            self?.log("📊 Checking packet counts...")
        }

        DispatchQueue.global(qos: .background).async { [weak self] in
            var totalPackets = 0
            while true {
                guard let strongSelf = self else { return }
                if let packet = strongSelf.packetFlow.readPackets()?.first {
                    totalPackets += 1
                    if totalPackets % 100 == 0 {
                        strongSelf.log("📦 Total packets seen: \(totalPackets)")
                    }
                } else {
                    usleep(10000) // 10ms
                }
            }
        }
    }
}
