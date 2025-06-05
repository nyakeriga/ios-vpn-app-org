// wrapper.go
package main

import "C"
import (
    "fmt"
)

//export StartSingBox
func StartSingBox() {
    fmt.Println("Sing-box running in iOS")
    // Add Sing-box logic here if needed
}

func main() {}
