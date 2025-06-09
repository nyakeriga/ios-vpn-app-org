package wrapper

import (
	libbox "github.com/sagernet/sing-box"
	"github.com/nyakeriga/ios-vpn-app-org/wrapper/platform" // Adjust if different
)

var service *libbox.Service

// StartVPN starts the VPN service
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

func (p *iOSPlatform) WriteLog(message string) {
	// No-op or send to NSLog if needed
}

func (p *iOSPlatform) UsePCSC() bool {
	return false // iOS does not support smartcard/PCSC
}

func (p *iOSPlatform) UsePlatformDefaultInterfaceMonitor() bool {
	return false
}

func (p *iOSPlatform) FindConnectionOwner(ipProtocol int32, sourceAddress string, sourcePort int32, destinationAddress string, destinationPort int32) (int32, error) {
	return 0, nil // iOS can't inspect connection ownership
}

func (p *iOSPlatform) PackageNameByUID(uid int32) (string, error) {
	return "", nil
}

func (p *iOSPlatform) UIDByPackageName(packageName string) (int32, error) {
	return 0, nil
}

func (p *iOSPlatform) UsePlatformInterfaceGetter() bool {
	return false
}

func (p *iOSPlatform) StartDefaultInterfaceMonitor(listener libbox.InterfaceUpdateListener) error {
	return nil
}

func (p *iOSPlatform) CloseDefaultInterfaceMonitor(listener libbox.InterfaceUpdateListener) error {
	return nil
}

func (p *iOSPlatform) GetInterfaces() (libbox.NetworkInterfaceIterator, error) {
	return nil, nil
}

func (p *iOSPlatform) UseNetworkExtension() bool {
	return true // ✅ Required for iOS NEVPN
}

func (p *iOSPlatform) ReadWIFIState() libbox.WIFIState {
	return libbox.WIFIState{} // ✅ Stubbed response
}

func (p *iOSPlatform) ClearWIFIStateCache() {
	// Nothing to clear
}

