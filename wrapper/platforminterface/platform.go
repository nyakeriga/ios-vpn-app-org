package platform

import (
    "github.com/sagernet/sing-box/experimental/libbox"
)

type iOSPlatform struct{}

func (p *iOSPlatform) UsePlatformAutoDetectInterfaceControl() bool {
    return false
}

func (p *iOSPlatform) AutoDetectInterfaceControl(fd int32) error {
    return nil
}

func (p *iOSPlatform) OpenTunnel(options libbox.TunnelOptions) (int32, error) {
    // ✅ Correctly pass the options to create the tunnel descriptor
    return libbox.GetTimeTunnelDescriptor(&options)
}

func (p *iOSPlatform) WriteLog(message string) {
    return
}

func (p *iOSPlatform) UsePCSC() bool {
    return false // iOS 不支持读取智能卡
}

func (p *iOSPlatform) UsePlatformDefaultInterfaceMonitor() bool {
    return false
}

func (p *iOSPlatform) FindConnectionOwner(ipProtocol int32, sourceAddress string, sourcePort int32, destinationAddress string, destinationPort int32) (int32, error) {
    return 0, nil // iOS 无法直接通过连接查找所属者
}

func (p *iOSPlatform) PackageNameByUID(uid int32) (string, error) {
    return "", nil // iOS 没有直接的 UID-包名映射
}

func (p *iOSPlatform) UIDByPackageName(packageName string) (int32, error) {
    return 0, nil // iOS 没有直接的包名-UID映射
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
    // ✅ Return true so iOS uses NE VPN API
    return true
}

func (p *iOSPlatform) ReadWIFIState() libbox.WIFIState {
    // ✅ Provide stubbed/neutral WiFi state info
    return libbox.WIFIState{}
}

func (p *iOSPlatform) ClearWIFIStateCache() {
    // iOS 无需清除缓存（空实现）
}
