package platforminterface

import (
	"errors"
)

type IOSPlatform struct{}

func (p *IOSPlatform) UsePlatformAutoDetectInterfaceControl() bool {
	return false
}

func (p *IOSPlatform) AutoDetectInterfaceControl(uid int32) error {
	return nil
}

func (p *IOSPlatform) OpenTUNOptions(TunOptions) (any, error) {
	return nil, errors.New("OpenTUNOptions not implemented")
}

func (p *IOSPlatform) WriteLog(message string) {
	// Optionally write to NSLog or iOS log handler
}

func (p *IOSPlatform) UseProcFS() bool {
	return false
}

func (p *IOSPlatform) UsePlatformDefaultInterfaceMonitor() bool {
	return false
}

// ===== Missing 9 methods fully stubbed below =====

func (p *IOSPlatform) FindConnectionOwner(ipProtocol int32, sourceAddress string, sourcePort int32, destinationAddress string, destinationPort int32) (int32, error) {
	return 0, errors.New("FindConnectionOwner not implemented")
}

func (p *IOSPlatform) PackageNameByUid(uid int32) (string, error) {
	return "", errors.New("PackageNameByUid not implemented")
}

func (p *IOSPlatform) UIDByPackageName(packageName string) (int32, error) {
	return 0, errors.New("UIDByPackageName not implemented")
}

func (p *IOSPlatform) UsePlatformInterfaceGetter() bool {
	return false
}

func (p *IOSPlatform) StartDefaultInterfaceMonitor(listener InterfaceUpdateListener) error {
	return errors.New("StartDefaultInterfaceMonitor not implemented")
}

func (p *IOSPlatform) CloseDefaultInterfaceMonitor(listener InterfaceUpdateListener) error {
	return errors.New("CloseDefaultInterfaceMonitor not implemented")
}

func (p *IOSPlatform) GetInterfaces() (NetworkInterfaceIterator, error) {
	return nil, errors.New("GetInterfaces not implemented")
}

func (p *IOSPlatform) UnderNetworkExtension() bool {
	return true // or false depending on how you wrap sing-box
}

func (p *IOSPlatform) ReadWIFIState() *WIFIState {
	return nil
}

func (p *IOSPlatform) ClearDNSCache() {
	// Not needed or not supported on iOS
}

// ====== Optional definitions for types used above ======

type TunOptions struct {
	// Define according to sing-box’s TunOptions
}

type InterfaceUpdateListener interface {
	// Define interface methods if used
}

type NetworkInterfaceIterator interface {
	// Define iterator interface if used
}

type WIFIState struct {
	// Optional: Implement according to your app’s need
}
