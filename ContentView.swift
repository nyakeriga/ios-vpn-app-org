import SwiftUI
import NetworkExtension

struct ContentView: View {
    @State private var status: String = "Disconnected"

    var body: some View {
        VStack(spacing: 30) {
            Text("VPN Status: \(status)")
                .font(.headline)

            Button("Connect VPN") {
                toggleVPN()
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(12)
        }
        .padding()
    }

    func toggleVPN() {
        NETunnelProviderManager.loadAllFromPreferences { managers, error in
            guard error == nil, let manager = managers?.first else {
                print("Failed to load VPN config: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            let session = manager.connection as? NETunnelProviderSession
            if session?.status == .connected {
                session?.stopTunnel()
                status = "Disconnected"
            } else {
                do {
                    try session?.startTunnel()
                    status = "Connected"
                } catch {
                    print("Start tunnel failed: \(error.localizedDescription)")
                }
            }
        }
    }
}
