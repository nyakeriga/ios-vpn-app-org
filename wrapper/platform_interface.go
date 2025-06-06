package main

import (
	"fmt"
	"os"

	libbox "github.com/sagernet/sing-box/experimental/libbox"
)

type iosPlatform struct{}

func (p *iosPlatform) Log(level, message string) {
	fmt.Printf("[libbox][%s] %s\n", level, message)
}

func (p *iosPlatform) GetConfigFilePath() string {
	return ""
}

func (p *iosPlatform) UsePlatformDefaultInterfaceMonitor() bool {
	return false
}

func (p *iosPlatform) AutoDetectInterfaceControl(fd int32) error {
	return nil
}

func (p *iosPlatform) UsePlatformAutoDetectInterfaceControl() bool {
	return false
}

func (p *iosPlatform) OpenTun(options libbox.TunOptions) (int32, error) {
	return libbox.GetTunnelFileDescriptor(), nil
}

func (p *iosPlatform) WriteLog(message string) {
	fmt.Printf("[libbox] %s\n", message)
}

func (p *iosPlatform) UseProcFS() bool {
	return false
}

func (p *iosPlatform) GetAssetFile(name string) ([]byte, error) {
	return nil, os.ErrNotExist
}

func (p *iosPlatform) GetAssetFilePath(name string) string {
	return ""
}

func (p *iosPlatform) IsNetworkAvailable() bool {
	return true
}

func (p *iosPlatform) GetOutboundNetworkName() string {
	return "en0" // or "utun0" depending on iOS tunnel
}

func (p *iosPlatform) GetAppDataDir() string {
	return "/tmp"
}

func (p *iosPlatform) ShouldHandleConnectionInGo(fd int32) bool {
	return false
}

func (p *iosPlatform) GetConnectionFD(conn interface{}) int32 {
	return -1
}

func (p *iosPlatform) IsPersistentConnection(conn interface{}) bool {
	return false
}

func (p *iosPlatform) OnPersistentConnectionClosed(conn interface{}) {}
