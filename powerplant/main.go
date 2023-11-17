package main

import (
	"log"
	"sync"
	"time"

	"github.com/simonvetter/modbus"
)

func main() {
	var server *modbus.ModbusServer
	var err error
	var eh *exampleHandler
	var ticker *time.Ticker

	// create the handler object
	eh = &exampleHandler{}

	// create the server object
	server, err = modbus.NewServer(&modbus.ServerConfiguration{
		// listen on localhost port 5502
		URL: "tcp://localhost:5502",
		// close idle connections after 30s of inactivity
		Timeout: 30 * time.Second,
		// accept 5 concurrent connections max.
		MaxClients: 5,
	}, eh)
	if err != nil {
		log.Fatalln(err)
	}

}

// Example handler object, passed to the NewServer() constructor above.
type modbusHandler struct {
	// this lock is used to avoid concurrency issues between goroutines, as
	// handler methods are called from different goroutines
	// (1 goroutine per client)
	lock sync.RWMutex

	// simple uptime counter, incremented in the main() above and exposed
	// as a 32-bit input register (2 consecutive 16-bit modbus registers).
	uptime uint32

	// these are here to hold client-provided (written) values, for both coils and
	// holding registers
	coils       [100]bool
	holdingReg1 uint16
	holdingReg2 uint16

	// this is a 16-bit signed integer
	holdingReg3 int16

	// this is a 32-bit unsigned integer
	holdingReg4 uint32
}
