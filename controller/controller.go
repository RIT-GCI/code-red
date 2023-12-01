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
	margin               = 20 * .1
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
		out, err := client.ReadCoils(65, 32)
		if err != nil {
			log.Fatalln(err)
		}
		// convert to float32
		var outbits uint32
		for i := len(out) - 1; i >= 0; i-- {
			if out[i] {
				outbits |= 1 << uint(i)
			}
		}

		// Check the deviation from target
		deviation := float64(targetpower) - float64(outbits)
		// if the deviation is greater than the margin, prepare to adjust
		if math.Abs(deviation) < margin {
			// no adjustment needed
			continue
		}

		// calculate the adjustment
		//adjustment := deviation * adjustment_step_size

		// TODO: write the adjustment to the powerplant

	}
}
