# Powerplant server

## Overview (goals)

Communicates over modbus to clients, ideally takes input variables that can change the state of the powerplant.
These states may be functions that change over time.
Every second, the code is re-run and the state of the powerplant is updated.
Communication will (hopefully) be in modbus, just to be a nightmare.