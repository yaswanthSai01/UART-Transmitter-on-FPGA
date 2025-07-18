# UART Transmitter on FPGA

This repository contains a Verilog HDL implementation of a **UART Transmitter**, integrated with a **button debouncing** module. The design is implemented on the **Basys 3 FPGA** board and demonstrates simple and reliable serial communication.

## Overview

The UART transmitter sends 8-bit parallel data serially over the `TxD` line. A push-button triggers the transmission, and a debouncer ensures clean input without false triggers due to switch bounce.

## Files

- `top.v` – Top module combining transmitter and debouncer.
- `transmitter.v` – UART logic with baud rate generation and data framing (start, 8 data bits, stop).
- `transmit_debouncing.v` – Digital debouncing for the button input.
- `top_tb.v` – Testbench to simulate overall functionality.

## Features

- UART transmission with configurable baud rate.
- 8-bit parallel to serial conversion.
- Clean push-button trigger using debouncing.
- Simulation-ready and FPGA-tested.
- Debug signals for easier verification.

## Tools & Setup

- **HDL**: Verilog
- **FPGA Tool**: Xilinx Vivado
- **Board**: Basys 3 (Artix-7)
- **Serial Terminal**: Tera Term / PuTTY

## Demo Steps

1. Set data using `sw[7:0]` on Basys 3.
2. Press `btn1` to send data.
3. `TxD` sends serial data via USB-UART.
4. Observe received data in Tera Term.

---

Feel free to fork or modify the project. Contributions and suggestions are welcome!
