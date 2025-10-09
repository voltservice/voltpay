package main

import (
	"log"
	"os"



	"github.com/GoogleCloudPlatform/functions-framework-go/funcframework"
	_ "voltpay_go"
)

func main() {
	port := os.Getenv("PORT")
	if port == "" { port = "9099" }
	if err := funcframework.Start(port); err != nil {
		log.Fatal(err)
	}
}
