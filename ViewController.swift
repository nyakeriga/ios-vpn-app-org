import UIKit
import NetworkExtension

class ViewController: UIViewController {

    private let vpnBundleId = "com.example.iosvpn.PacketTunnel"
    private let vpnDescription = "SingBox VPN"

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
                print("Existing VPN configuration loaded")
                self.setupManager(existingManager)
            } else {
                print("No existing VPN configuration found. Creating a new one.")
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
                print("Error saving VPN configuration: \(error)")
            } else {
                print("VPN configuration saved successfully")
            }
        }
    }

    private func setupManager(_ manager: NETunnelProviderManager) {
        manager.isEnabled = true
        manager.saveToPreferences { error in
            if let error = error {
                print("Failed to enable VPN: \(error)")
            } else {
                print("VPN enabled")
            }
        }
    }

    // MARK: - Toggle VPN

    @objc private func toggleVPN() {
        NETunnelProviderManager.loadAllFromPreferences { managers, error in
            if let error = error {
                print("Error loading VPN managers: \(error)")
                return
            }

            guard let manager =
