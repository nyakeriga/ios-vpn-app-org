package main

import (
	"log"

	"github.com/nyakeriga/singbox-wrapper/platforminterface"
	"github.com/sagernet/sing-box/experimental/libbox"
)

func main() {
	cfgPath := "/path/to/config.json" // Replace this with the actual path in iOS/macOS context

	service, err := libbox.NewService(cfgPath, &platforminterface.IOSPlatform{})
	if err != nil {
		log.Fatalf("Failed to create service: %v", err)
	}

	if err := service.Start(); err != nil {
		log.Fatalf("Service start failed: %v", err)
	}
}



