//////////////////////////////////////////////////////////////////////////////
//
// Project: UART Transmitter with Debouncing
// Module: transmitter.v
// Description:
//   This module implements the core UART (Universal Asynchronous Receiver/Transmitter)
//   transmitter functionality. It takes 8-bit parallel data and converts it
//   into a serial bitstream for transmission, adhering to standard UART
//   protocol (start bit, 8 data bits, stop bit).
//
// Author: Kotyada Yaswanth Sai
// About: EE undergraduate at NIT Rourkela, interested in Digital Design
//        and Computer Architecture.
//
//////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps // Specifies the time unit and precision for simulation

module transmitter(
input clk,          // UART input clock
input reset,        // Reset signal
input transmit,     // Button signal to trigger the UART communication
input [7:0] data,   // 8-bit data to be transmitted
output reg TxD      // Transmitter serial output. TxD will be held high during reset, or when no transmissions are taking place. 
    );

// Internal variables
reg [3:0] bitcounter;       // 4-bit counter to track the 10 bits being transmitted (0 to 9)
reg [13:0] counter;         // 14-bit counter for baud rate generation (e.g., counts up to 10415 for 9600 baud @ 100MHz)
reg state, nextstate;       // Current and next state variables for the FSM (0: Idle, 1: Transmit)
// 10 bits data needed to be shifted out during transmission.
// The least significant bit is initialized with the binary value '0' (a start bit).
// A binary value '1' is introduced in the most significant bit (a stop bit).
reg [9:0] rightshiftreg; 
reg shift;                  // Control signal to enable right-shifting of data
reg load;                   // Control signal to load data into the shift register and add start/stop bits
reg clear;                  // Control signal to reset the bitcounter for a new transmission

// UART transmission logic (Baud Rate Generator and Shift Register Control)
always @ (posedge clk) 
begin 
    if (reset) begin // Asynchronous reset asserted
        state <= 1'b0;      // State is idle (state = 0)
        counter <= 14'd0;   // Baud rate counter is reset to 0 
        bitcounter <= 4'd0; // Bit counter for transmission is reset to 0
    end else begin
        counter <= counter + 1; // Baud rate counter increments every clock cycle
        if (counter >= 14'd10415) begin // If baud rate period is reached (for 9600 baud @ 100MHz)
            state <= nextstate;         // Transition to the next state determined by FSM
            counter <= 14'd0;           // Reset baud rate counter for the next bit period
            if (load) begin
                rightshiftreg <= {1'b1, data, 1'b0}; // Load data with Start (0) and Stop (1) bits
            end
            if (clear) begin
                bitcounter <= 4'd0; // Reset bit counter
            end
            if (shift) begin // If shift is asserted (one bit period has passed)
                rightshiftreg <= rightshiftreg >> 1; // Right-shift the data to output the next bit
                bitcounter <= bitcounter + 1;        // Increment bit counter
            end
        end
    end
end 

// State machine for UART transmission control
// This block is sensitive to the clock and determines control signals and next state
always @ (posedge clk) begin // Triggered by positive edge of clock
    // Default assignments to avoid latches and ensure proper behavior when not active
    load <= 1'b0;
    shift <= 1'b0;
    clear <= 1'b0;
    TxD <= 1'b1; // TxD is high (idle state) by default

    case (state)
        // IDLE State
        1'b0: begin 
            if (transmit) begin // If transmit signal is asserted (button pressed)
                nextstate <= 1'b1; // Move to TRANSMIT state
                load <= 1'b1;      // Assert load to prepare data for transmission
            end else begin // If transmit is not asserted
                nextstate <= 1'b0; // Stay in IDLE state
                TxD <= 1'b1;       // Keep TxD high (idle)
            end
        end
        // TRANSMIT State
        1'b1: begin 
            if (bitcounter >= 4'd10) begin // Check if all 10 bits (start, 8 data, stop) have been transmitted
                nextstate <= 1'b0; // Transmission complete, move back to IDLE state
                clear <= 1'b1;     // Assert clear to reset bitcounter for next transmission
            end else begin // If transmission is not complete
                nextstate <= 1'b1;     // Stay in TRANSMIT state
                TxD <= rightshiftreg[0]; // Output the current LSB of the shift register (next bit to transmit)
                shift <= 1'b1;         // Assert shift to move to the next bit for the next period
            end
        end
        default: nextstate <= 1'b0; // Default case for safety, go to IDLE
    endcase
end

endmodule
