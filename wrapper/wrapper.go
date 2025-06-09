package wrapper

import (
	libbox "github.com/sagernet/sing-box"
	"github.com/nyakeriga/ios-vpn-app-org/wrapper/platform" // Adjust if needed
)

var service *libbox.Service

// StartVPN starts the VPN using a given config path
func StartVPN(configPath string) error {
	var err error
	service, err = libbox.NewService(configPath, &platform.iOSPlatform{})
	if err != nil {
		return err
	}
	return service.Start()
}

// StopVPN stops the VPN service
func StopVPN() {
	if service != nil {
		service.Close()
	}
}
