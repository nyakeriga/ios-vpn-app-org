package platform

import (
    "github.com/sgameet/sing-box/experimental/libbox"
)

type iOSPlatform struct{}

func (p *iOSPlatform) UsePlatformAutoDetectInterfaceControl() bool {
    return false
}

func (p *iOSPlatform) AutoDetectInterfaceControl(fd int32) error {
    return nil
}

func (p *iOSPlatform) OpenTunnel(options libbox.TunnelOptions) (int32, error) {
    return libbox.GetTimeTunnelDescriptor(&options) // ✅ Pass options instead of nil
}

func (p *iOSPlatform) WriteLog(message string) {
    println("[SingBox]", message) // ✅ Add simple log output
}

func (p *iOSPlatform) UsePCSC() bool {
    return false // iOS 无法使用PCSC
}

func (p *iOSPlatform) UsePlatformDefaultInterfaceMonitor() bool {
    return false
}

func (p *iOSPlatform) FindConnectionOwner(ipProtocol int32, sourceAddress string, sourcePort int32, destinationAddress string, destinationPort int32) (int32, error) {
    return 0, nil // iOS 无法追踪连接所属进程
}

func (p *iOSPlatform) PackageNameByUID(uid int32) (string, error) {
    return "", nil // iOS 没有UID和包名的概念
}

func (p *iOSPlatform) UIDByPackageName(packageName string) (int32, error) {
    return 0, nil // iOS 没有包名和UID的映射
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
    return true // ✅ iOS VPN推荐使用Network Extension
}

func (p *iOSPlatform) ReadWiFiState() libbox.WiFiState {
    return 0 // iOS 未知网络状态
}

func (p *iOSPlatform) ClearWQSCache() {
    // iOS 清除WQS缓存 (空实现)
}

