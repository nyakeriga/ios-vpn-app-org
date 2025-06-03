import UIKit
import NetworkExtension

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        configureVPN()
    }

    func configureVPN() {
        let manager = NETunnelProviderManager()
        let config = NETunnelProviderProtocol()
        config.providerBundleIdentifier = "com.example.iosvpn.PacketTunnel"
        config.serverAddress = "SingBox"
        manager.protocolConfiguration = config
        manager.localizedDescription = "SingBox VPN"
        manager.isEnabled = true

        manager.saveToPreferences { error in
            if let error = error {
                print("Error saving VPN: \(error)")
            } else {
                print("VPN configuration saved")
            }
        }
    }
}
