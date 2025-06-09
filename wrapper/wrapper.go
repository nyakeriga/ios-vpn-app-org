package wrapper

import (
    libbox "github.com/sagernet/sing-box"
    "github.com/nyakeriga/ios-vpn-app-org/wrapper/platform" // ← use your actual repo path
)

var service *libbox.Service

// StartVPN initializes and starts the Sing‑box service using the given config file.
func StartVPN(configPath string) error {
    var err error
    service, err = libbox.NewService(configPath, &platform.iOSPlatform{})
    if err != nil {
        return err
    }
    return service.Start()
}

// StopVPN cleanly shuts down the Sing‑box service if it's running.
func StopVPN() {
    if service != nil {
        service.Close()
    }
}
