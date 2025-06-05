package main

/*
#include <stdlib.h>
*/
import "C"

import (
	"log"
	"os"
	"os/signal"
	"syscall"

	"github.com/sagernet/sing-box"
)

var app *singbox.App

//export StartSingbox
func StartSingbox(configJson *C.char) C.int {
	configStr := C.GoString(configJson)
	configFile := "/tmp/sbox-config.json"

	// Write the config file
	if err := os.WriteFile(configFile, []byte(configStr), 0644); err != nil {
		log.Printf("Failed to write config file: %v\n", err)
		return 1
	}

	opts := &singbox.Options{
		ConfigPath: configFile,
	}

	var err error
	app, err = singbox.New(opts)
	if err != nil {
		log.Printf("Failed to create sing-box app: %v\n", err)
		return 2
	}

	// Signal listener to gracefully close the app
	go func() {
		c := make(chan os.Signal, 1)
		signal.Notify(c, syscall.SIGINT, syscall.SIGTERM)
		<-c
		app.Close()
	}()

	if err := app.Start(); err != nil {
		log.Printf("Failed to start sing-box: %v\n", err)
		return 3
	}

	log.Printf("Sing-box started successfully.\n")
	return 0
}

//export StopSingbox
func StopSingbox() {
	if app != nil {
		app.Close()
		log.Printf("Sing-box stopped.\n")
	}
}

func main() {}
