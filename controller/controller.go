package main

import (
	"log"
	"math"

	"github.com/simonvetter/modbus"
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
	log.Println(math.Float32frombits(outbits))

}
