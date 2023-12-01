package main

import (
	"log"
	"math"
	"time"

	"github.com/simonvetter/modbus"
)

const (
	targetpower = 100
	// margin is 10% of safety range
	margin               = float32(20 * .1)
	adjustment_step_size = 5
)

func main() {
	// init modbus client
	client, err := modbus.NewClient(&modbus.ClientConfiguration{
		URL: "tcp://localhost:5502",
	})
	if err != nil {
		log.Fatalln(err)
	}
	err = client.Open()
	if err != nil {
		log.Fatalln(err)
	}

	for {
		time.Sleep(1 * time.Second)

		// get the data from the powerplant and parse it out
		out, err := client.ReadRegisters(65, 2, modbus.HOLDING_REGISTER)
		if err != nil {
			log.Fatalln(err)
		}
		// convert to float32
		outbits := uint32(out[0])<<16 | uint32(out[1])

		log.Println("outbits:", math.Float32frombits(outbits))

		// Check the deviation from target
		deviation := float32(targetpower) - math.Float32frombits(outbits)
		// if the deviation is greater than the margin, prepare to adjust
		if float32(math.Abs(float64(deviation))) < margin {
			// no adjustment needed
			continue
		}

		// calculate the adjustment
		//adjustment := deviation * adjustment_step_size

		// TODO: write the adjustment to the powerplant

	}
}
