package main

/*
#include <stdlib.h>
*/
import "C"

import (
	"context"
	"fmt"
	"os"
	"sync"

	libbox "github.com/sagernet/sing-box/experimental/libbox"
)

type dummyPlatform struct{}

func (d *dummyPlatform) Log(level, message string) {
	fmt.Printf("[libbox][%s] %s\n", level, message)
}

func (d *dummyPlatform) GetConfigFilePath() string {
	return "" // not used since we're passing config as path below
}

func (d *dummyPlatform) UsePlatformDefaultInterfaceMonitor() bool {
	return true
}

var (
	service   *libbox.BoxService
	ctx       context.Context
	cancel    context.CancelFunc
	serviceMu sync.Mutex
)

//export StartSingbox
func StartSingbox(configPath *C.char) C.int {
	serviceMu.Lock()
	defer serviceMu.Unlock()

	if service != nil {
		fmt.Println("Sing-box already running")
		return 1
	}

	cfg := C.GoString(configPath)
	ctx, cancel = context.WithCancel(context.Background())

	var err error
	service, err = libbox.NewService(cfg, &dummyPlatform{})
	if err != nil {
		fmt.Fprintf(os.Stderr, "Failed to create service: %v\n", err)
		return 1
	}

	go func() {
		if err := service.Start(ctx); err != nil {
			fmt.Fprintf(os.Stderr, "Sing-box service error: %v\n", err)
		}
	}()

	fmt.Println("Sing-box started.")
	return 0
}

//export StopSingbox
func StopSingbox() {
	serviceMu.Lock()
	defer serviceMu.Unlock()

	if cancel != nil {
		cancel()
		cancel = nil
	}

	if service != nil {
		_ = service.Close()
		service = nil
		fmt.Println("Sing-box stopped.")
	}
}

func main() {}


