package main

import (
	"math"
	"reflect"
	"testing"

	"github.com/simonvetter/modbus"
)

func Test_modbusHandler_HandleDiscreteInputs(t *testing.T) {
	type args struct {
		req *modbus.DiscreteInputsRequest
	}
	tests := []struct {
		name    string
		h       *modbusHandler
		args    args
		wantRes []bool
		wantErr bool
	}{
		// Not implemented
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			gotRes, err := tt.h.HandleDiscreteInputs(tt.args.req)
			if (err != nil) != tt.wantErr {
				t.Errorf("modbusHandler.HandleDiscreteInputs() error = %v, wantErr %v", err, tt.wantErr)
				return
			}
			if !reflect.DeepEqual(gotRes, tt.wantRes) {
				t.Errorf("modbusHandler.HandleDiscreteInputs() = %v, want %v", gotRes, tt.wantRes)
			}
		})
	}
}

func Test_modbusHandler_HandleInputRegisters(t *testing.T) {
	type args struct {
		req *modbus.InputRegistersRequest
	}
	tests := []struct {
		name    string
		h       *modbusHandler
		args    args
		want    []uint16
		wantErr bool
	}{
		// Not implemented
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			got, err := tt.h.HandleInputRegisters(tt.args.req)
			if (err != nil) != tt.wantErr {
				t.Errorf("modbusHandler.HandleInputRegisters() error = %v, wantErr %v", err, tt.wantErr)
				return
			}
			if !reflect.DeepEqual(got, tt.want) {
				t.Errorf("modbusHandler.HandleInputRegisters() = %v, want %v", got, tt.want)
			}
		})
	}
}

func Test_modbusHandler_HandleHoldingRegisters(t *testing.T) {
	type args struct {
		req *modbus.HoldingRegistersRequest
	}
	tests := []struct {
		name    string
		h       *modbusHandler
		args    args
		wantRes []uint16
		wantErr bool
	}{
		// TODO: Add test cases.
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			gotRes, err := tt.h.HandleHoldingRegisters(tt.args.req)
			if (err != nil) != tt.wantErr {
				t.Errorf("modbusHandler.HandleHoldingRegisters() error = %v, wantErr %v", err, tt.wantErr)
				return
			}
			if !reflect.DeepEqual(gotRes, tt.wantRes) {
				t.Errorf("modbusHandler.HandleHoldingRegisters() = %v, want %v", gotRes, tt.wantRes)
			}
		})
	}
}

func Test_modbusHandler_HandleCoils(t *testing.T) {
	type args struct {
		req *modbus.CoilsRequest
	}
	tests := []struct {
		name    string
		h       *modbusHandler
		args    args
		want    []bool
		wantErr bool
	}{
		// Not implemented, no test cases
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			got, err := tt.h.HandleCoils(tt.args.req)
			if (err != nil) != tt.wantErr {
				t.Errorf("modbusHandler.HandleCoils() error = %v, wantErr %v", err, tt.wantErr)
				return
			}
			if !reflect.DeepEqual(got, tt.want) {
				t.Errorf("modbusHandler.HandleCoils() = %v, want %v", got, tt.want)
			}
		})
	}
}

func Test_powerplant_queryOutputModbus(t *testing.T) {
	type args struct {
		quantity uint16
	}
	tests := []struct {
		name    string
		p       *powerplant
		args    args
		wantRes []uint16
		wantErr bool
	}{
		// TODO: Add test cases.
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			gotRes, err := tt.p.queryOutputModbus(tt.args.quantity)
			if (err != nil) != tt.wantErr {
				t.Errorf("powerplant.queryOutputModbus() error = %v, wantErr %v", err, tt.wantErr)
				return
			}
			if !reflect.DeepEqual(gotRes, tt.wantRes) {
				t.Errorf("powerplant.queryOutputModbus() = %v, want %v", gotRes, tt.wantRes)
			}
		})
	}
}

func convert_float32_to_uint16(f float32) []uint16 {
	return []uint16{uint16(math.Float32bits(f) >> 16),
		uint16(math.Float32bits(f))}
}

func Test_powerplant_setReactivity(t *testing.T) {
	type args struct {
		req *modbus.HoldingRegistersRequest
	}
	tests := []struct {
		name    string
		p       *powerplant
		args    args
		want    []uint16
		wantErr bool
	}{
		{
			name: "setReactivity positive",
			p: &powerplant{
				output: 100,
			},
			want: convert_float32_to_uint16(.5),
			args: args{
				req: &modbus.HoldingRegistersRequest{
					Args:     convert_float32_to_uint16(.5),
					Quantity: 2,
					IsWrite:  true,
				},
			},
		},
		{
			name: "setReactivity negative",
			p: &powerplant{
				output: 100,
			},
			want: convert_float32_to_uint16(-.5),
			args: args{
				req: &modbus.HoldingRegistersRequest{
					Args:     convert_float32_to_uint16(-.5),
					Quantity: 2,
					IsWrite:  true,
				},
			},
		},
		{
			name: "setReactivity no write",
			p: &powerplant{
				output: 100,
			},
			args: args{
				req: &modbus.HoldingRegistersRequest{
					Quantity: 2,
					IsWrite:  false,
				},
			},
			wantErr: true,
		},
		{
			name: "setReactivity qty too high",
			p: &powerplant{
				output: 100,
			},
			args: args{
				req: &modbus.HoldingRegistersRequest{
					Quantity: 5,
					IsWrite:  true,
				},
			},
			wantErr: true,
		},
		{
			name: "setReactivity positive buffer overflow",
			p: &powerplant{
				output: 100,
			},
			wantErr: true,
			args: args{
				req: &modbus.HoldingRegistersRequest{
					Args:     convert_float32_to_uint16(.5),
					Quantity: 1,
					IsWrite:  true,
				},
			},
		},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {

			got, err := tt.p.setReactivity(tt.args.req)
			if (err != nil) != tt.wantErr {
				t.Errorf("powerplant.setReactivity() error = %v, wantErr %v", err, tt.wantErr)
				return
			}
			if !reflect.DeepEqual(got, tt.want) {
				t.Errorf("powerplant.setReactivity() = %v, want %v", got, tt.want)
			}
		})
	}
}

func Test_powerplant_updateOutput(t *testing.T) {
	tests := []struct {
		name string
		p    *powerplant
	}{
		// TODO: Add test cases.
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			tt.p.updateOutput()
		})
	}
}
