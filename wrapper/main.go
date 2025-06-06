package main

import (
	libbox "github.com/sagernet/sing-box"
	"yourmodule/wrapper" // Replace with your actual Go module path
)

func main() {
	configPath := "/path/to/config.json" // Replace with actual config path
	service, err := libbox.NewService(configPath, &wrapper.iOSPlatform{})
	if err != nil {
		panic(err)
	}
	service.Start()
}


