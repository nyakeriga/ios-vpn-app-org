package platform

import (
	"github.com/sagernet/sing-box/experimental/libbox"
)

type iOSPlatform struct{}

// ✅ NE VPN will manage the tunnel, we stub this
func (p *iOSPlatform) OpenTunnel(options libbox.TunnelOptions) (int32, error) {
	// iOS does not support dynamic tunnel interfaces from Go
	return -1, nil
}

func (p *iOSPlatform) UsePlatformAutoDetectInterfaceControl() bool {
	return false
}

func (p *iOSPlatform) AutoDetectInterfaceControl(fd int32) error {
	return nil
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

