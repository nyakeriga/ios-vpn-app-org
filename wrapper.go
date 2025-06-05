package main

import "C"

import (
	"log"
	"os"
	"path/filepath"

	"github.com/sagernet/sing-box"
)

//export StartSingBox
func StartSingBox() {
	// Locate config in app bundle (iOS)
	dir, err := os.Getwd()
	if err != nil {
		log.Fatalf("getwd failed: %v", err)
	}

	configPath := filepath.Join(dir, "config.json")
	log.Printf("Loading config: %s", configPath)

	engine, err := singbox.New(singbox.Options{
		ConfigPath: configPath,
	})
	if err != nil {
		log.Fatalf("failed to create engine: %v", err)
	}

	err = engine.Start()
	if err != nil {
		log.Fatalf("failed to start engine: %v", err)
	}

	log.Println("Sing-box started")
}

func main() {}
