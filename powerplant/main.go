package main

import (
	"log"
	"math"
	"time"

	"github.com/simonvetter/modbus"
)

// Example handler object, passed to the NewServer() constructor above.
type modbusHandler struct {
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
	log.Printf("coils request: %#v", *req)
	// This switch calls go functions for any modbus function desired.
	switch req.Addr {
	case 65:
		return plant.queryOutputModbus(req.Quantity)
	case 67:
		return plant.setReactivity(req)
	default:
		return nil, modbus.ErrIllegalFunction
	}
}

// Not implemented
func (h *modbusHandler) HandleCoils(req *modbus.CoilsRequest) ([]bool, error) {
	return nil, nil
}

// queryOutputModbus queries the powerplant output and returns a []uint16 and error
// which is accepted by modbus
func (p *powerplant) queryOutputModbus(quantity uint16) (res []uint16, err error) {
	if quantity > 2 {
		return nil, modbus.ErrIllegalDataValue
	}

	res = []uint16{uint16(math.Float32bits(p.output) >> 16),
		uint16(math.Float32bits(p.output))}
	// convert to two uint16s insde of res

	return
}

func (p *powerplant) setReactivity(req *modbus.HoldingRegistersRequest) ([]uint16, error) {
	if req.Quantity != 2 {
		return nil, modbus.ErrIllegalDataValue
	}

	if !req.IsWrite {
		return nil, modbus.ErrIllegalFunction
	}

	// Convert two uint16s to float32
	p.reactivity = math.Float32frombits(uint32(req.Args[0])<<16 |
		uint32(req.Args[1]))

	log.Println("reactivity set to:", p.reactivity)

	return req.Args, nil
}

// updateOutput updates the powerplant output based on the target and reactivity.
// The reactivity is added to the sine of the current time (minutes in the hour,
// scaled to 0-1) to get the new output.
func (p *powerplant) updateOutput() {
	for {
		p.output = p.output + p.reactivity + float32(.05*
			math.Sin((float64(
				time.Now().Minute())+(float64(time.Now().Second())/
				60.0))/60.0*2*math.Pi))
		log.Println("current output:", p.output)
		time.Sleep(1 * time.Second)
	}
}