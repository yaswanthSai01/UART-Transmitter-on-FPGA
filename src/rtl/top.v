//////////////////////////////////////////////////////////////////////////////
//
// Project: UART Transmitter with Debouncing
// Module: top.v
// Description:
//   This is the top-level module for a UART (Universal Asynchronous
//   Receiver/Transmitter) Transmitter. It integrates a debouncing circuit
//   for a push-button input (btn1) to generate a clean 'transmit' signal,
//   and then feeds this signal along with data from switches (sw) to the
//   core UART transmitter module.
//
//   It provides debug outputs for key internal signals for easier
//   on-chip analysis (e.g., using ILA if targeting FPGA).
//
// Author: Kotyada Yaswanth Sai
// About: EE undergraduate at NIT Rourkela, interested in Digital Design
//        and Computer Architecture.
//
//////////////////////////////////////////////////////////////////////////////

module top(
input [7:0]sw,
input btn0,
input btn1,
input clk,
output TxD,
output TxD_debug,
output transmit_debug,
output button_debug,
output clk_debug
);

wire transmit; // Internal wire for the debounced transmit signal

// Assign debug outputs
assign TxD_debug = TxD;
assign transmit_debug = transmit;
assign button_debug = btn1;
assign clk_debug = clk;


// Instantiate the debouncing module for the transmit button
transmit_debouncing D2 (.clk(clk), .btn1(btn1), .transmit(transmit));

// Instantiate the UART transmitter core module
transmitter T1 (.clk(clk), .reset(btn0),.transmit(transmit),.TxD(TxD),.data(sw));


endmodule
