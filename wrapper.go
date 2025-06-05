package main

/*
#include <stdlib.h>
*/
import "C"
import (
	"os"
	"os/signal"
	"syscall"

	singbox "github.com/sagernet/sing-box"
)

//export StartSingbox
func StartSingbox(configJson *C.char) C.int {
	cfgPath := "/tmp/sbox-config.json"
	_ = os.WriteFile(cfgPath, []byte(C.GoString(configJson)), 0644)

	go func() {
		singbox.Main([]string{"run", "-c", cfgPath})
	}()

	return 0
}

//export StopSingbox
func StopSingbox() {
	// Send interrupt signal to stop gracefully
	p, _ := os.FindProcess(os.Getpid())
	_ = p.Signal(syscall.SIGINT)
}

func main() {}
