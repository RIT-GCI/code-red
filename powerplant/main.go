package main

import (
	"log"
	"math"
	"time"

	"github.com/simonvetter/modbus"
)

// Example handler object, passed to the NewServer() constructor above.
type modbusHandler struct {
	// these are here to hold client-provided (written) values, for both coils and
	// holding registers
	coils [100]bool

	// holding registers are 16-bit values, so we use uint16
	holdingRegisters [100]uint16
}

type powerplant struct {
	// reactivity is the amount of powerplant output change per second
	reactivity float32
	// output is the current powerplant output
	output float32
	// target is the desired powerplant output
	target float32
	// safety is the maximum deviation from target allowed
	// Operating range is always 10% of safety.
	safety float32
}

var (
	// plant is the powerplant object
	// todo: store this in modbus somewhere
	plant = &powerplant{
		reactivity: 0,
		output:     100,
		target:     100,
		safety:     20,
	}
)

func main() {
	var server *modbus.ModbusServer
	var err error

	// create the handler object
	handler := &modbusHandler{}

	// create the server object
	server, err = modbus.NewServer(&modbus.ServerConfiguration{
		// listen on localhost port 5502
		URL: "tcp://localhost:5502",
		// close idle connections after 30s of inactivity
		Timeout: 30 * time.Second,
		// accept 5 concurrent connections max.
		MaxClients: 5,
	}, handler)
	if err != nil {
		log.Fatalln(err)
	}

	err = server.Start()
	if err != nil {
		log.Fatalln(err)
	}
	plant.updateOutput()
}

// Not implemented
func (h *modbusHandler) HandleDiscreteInputs(req *modbus.DiscreteInputsRequest) (
	res []bool, err error) {
	return nil, nil
}

// Not implemented
func (h *modbusHandler) HandleInputRegisters(req *modbus.InputRegistersRequest) ([]uint16,
	error) {
	return nil, nil
}

// Not implemented
func (h *modbusHandler) HandleHoldingRegisters(req *modbus.HoldingRegistersRequest) (
	res []uint16, err error) {
	return nil, nil
}

func (h *modbusHandler) HandleCoils(req *modbus.CoilsRequest) ([]bool, error) {
	log.Printf("coils request: %#v", *req)
	// This switch calls go functions for any modbus function desired.
	switch req.Addr {
	case 65:
		return plant.queryOutputModbus(req.Quantity)
	default:
		return nil, modbus.ErrIllegalFunction
	}
}

// queryOutputModbus queries the powerplant output and returns a []bool and error
// which is accepted by modbus
func (p *powerplant) queryOutputModbus(quantity uint16) (res []bool, err error) {
	if quantity > 32 {
		return nil, modbus.ErrIllegalDataValue
	}
	for i := 0; i < int(quantity); i++ {
		res = append(res, math.Float32bits(p.output)&(1<<uint(i)) != 0)
	}
	return
}

// updateOutput updates the powerplant output based on the target and reactivity.
// The reactivity is added to the sine of the current time (minutes in the hour,
// scaled to 0-1) to get the new output.
func (p *powerplant) updateOutput() {
	for {
		p.output = p.output + p.reactivity + float32(.01*
			math.Sin(float64(time.Now().Minute())/60.0*2*math.Pi))
		log.Println("current output:", p.output)
		time.Sleep(1 * time.Second)
	}
}
