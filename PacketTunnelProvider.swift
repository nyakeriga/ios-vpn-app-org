import NetworkExtension

class PacketTunnelProvider: NEPacketTunnelProvider {

    var process: Process?

    override func startTunnel(options: [String : NSObject]?, completionHandler: @escaping (Error?) -> Void) {
        let tunnelFd = packetFlow.value(forKeyPath: "socket.fileDescriptor") as! Int32

        guard let singboxPath = Bundle.main.path(forResource: "sing-box", ofType: nil, inDirectory: "EmbeddedSingBox") else {
            completionHandler(NSError(domain: "SingboxNotFound", code: 404))
            return
        }

        let process = Process()
        process.launchPath = singboxPath
        process.arguments = ["run", "-c", "/path/to/config.json"]
        process.standardInput = FileHandle(fileDescriptor: tunnelFd)
        process.standardOutput = FileHandle.nullDevice
        process.standardError = FileHandle.nullDevice

        do {
            try process.run()
            self.process = process
            completionHandler(nil)
        } catch {
            completionHandler(error)
        }
    }

    override func stopTunnel(with reason: NEProviderStopReason, completionHandler: @escaping () -> Void) {
        process?.terminate()
        completionHandler()
    }
}
