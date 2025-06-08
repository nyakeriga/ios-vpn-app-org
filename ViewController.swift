import UIKit
import NetworkExtension
import SingBox

class ViewController: UIViewController {

    private let vpnBundleId = "com.example.iosvpn.PacketTunnel"
    private let vpnDescription = "SingBox VPN"
    private let vpn = LibboxwrapperVPN()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadOrCreateVPNConfig()
    }

    // MARK: - UI

    private func setupUI() {
        view.backgroundColor = .white
        let toggleButton = UIButton(type: .system)
        toggleButton.setTitle("Toggle VPN", for: .normal)
        toggleButton.addTarget(self, action: #selector(toggleVPN), for: .touchUpInside)
        toggleButton.frame = CGRect(x: 50, y: 200, width: 300, height: 50)
        toggleButton.center.x = view.center.x
        view.addSubview(toggleButton)
    }

    // MARK: - VPN Configuration

    private func loadOrCreateVPNConfig() {
        NETunnelProviderManager.loadAllFromPreferences { managers, error in
            if let error = error {
                print("Error loading VPN configurations: \(error)")
                return
            }

            if let existingManager = managers?.first(where: { $0.protocolConfiguration?.providerBundleIdentifier == self.vpnBundleId }) {
                print("✅ Existing VPN configuration loaded")
                self.setupManager(existingManager)
            } else {
                print("🔧 No existing VPN config. Creating new one.")
                self.createVPNConfig()
            }
        }
    }

    private func createVPNConfig() {
        let manager = NETunnelProviderManager()
        let protocolConfig = NETunnelProviderProtocol()
        protocolConfig.providerBundleIdentifier = vpnBundleId
        protocolConfig.serverAddress = "SingBox"
        manager.protocolConfiguration = protocolConfig
        manager.localizedDescription = vpnDescription
        manager.isEnabled = true

        manager.saveToPreferences { error in
            if let error = error {
                print("❌ Error saving VPN config: \(error)")
            } else {
                print("✅ VPN config saved")
            }
        }
    }

    private func setupManager(_ manager: NETunnelProviderManager) {
        manager.isEnabled = true
        manager.saveToPreferences { error in
            if let error = error {
                print("❌ Failed to enable VPN: \(error)")
            } else {
                print("✅ VPN enabled")
            }
        }
    }

    // MARK: - Toggle VPN

    @objc private func toggleVPN() {
        NETunnelProviderManager.loadAllFromPreferences { managers, error in
            if let error = error {
                print("❌ Error loading managers: \(error)")
                return
            }

            guard let manager = managers?.first(where: { $0.protocolConfiguration?.providerBundleIdentifier == self.vpnBundleId }) else {
                print("❌ No manager found")
                return
            }

            do {
                try manager.connection.startVPNTunnel()
                print("✅ VPN Tunnel started")
            } catch {
                print("❌ Failed to start tunnel via NETunnelProvider: \(error)")
            }

            // Use your custom static lib VPN wrapper
            let (_, startError) = self.vpn.startTunnel()
            if let startError = startError {
                print("❌ Tunnel failed via wrapper: \(startError)")
            } else {
                print("✅ Tunnel started via wrapper")
            }
        }
    }
}

