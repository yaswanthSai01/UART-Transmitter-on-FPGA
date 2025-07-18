//////////////////////////////////////////////////////////////////////////////
//
// Project: UART Transmitter with Debouncing
// Module: transmit_debouncing.v
// Description:
//   This module implements a digital debouncing circuit for a push-button
//   input. It synchronizes the asynchronous button press/release to the
//   system clock domain and then uses a counter-based approach to filter
//   out mechanical bounces. The 'transmit' output changes state only after
//   the button input has remained stable for a duration defined by the
//   'threshold' parameter.
//
// Author: Kotyada Yaswanth Sai
// About: EE undergraduate at NIT Rourkela, interested in Digital Design
//        and Computer Architecture.
//
//////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps // Specifies the time unit and precision for simulation

module transmit_debouncing #(parameter threshold = 100000) // Set parameter threshold to gauge how long button pressed
(
input clk,      // Clock signal
input btn1,     // Input button signal (raw, potentially bouncy)
output reg transmit // Debounced transmit signal
    );
    
reg button_ff1 = 1'b0; // First flip-flop for synchronizing button input
reg button_ff2 = 1'b0; // Second flip-flop for synchronizing button input
reg [30:0]count = 31'd0; // Counter for debouncing duration. Initialized to 0.

// First, synchronize the asynchronous 'btn1' signal to the 'clk' clock domain
// using a two-flip-flop synchronizer to prevent metastability issues.
always @(posedge clk) begin
    button_ff1 <= btn1;
    button_ff2 <= button_ff1;
end

// Debouncing logic: Increment/decrement a counter based on the synchronized
// button state. The 'transmit' output changes only when the counter
// crosses the defined 'threshold'.
always @(posedge clk) begin 
    if (button_ff2) begin // If the synchronized button is pressed (high)
        // Increment counter if it hasn't reached the maximum value (threshold)
        if (count < threshold) begin // Check if count is less than threshold to prevent overflow
            count <= count + 1;
        end
    end else begin // If the synchronized button is released (low)
        // Decrement counter if it's not already zero
        if (count > 31'd0) begin // Check if count is greater than 0 to prevent underflow
            count <= count - 1;
        end
    end

    // Determine the debounced 'transmit' output
    if (count == threshold) begin // If the counter has reached the threshold while button is pressed
        transmit <= 1'b1; // Debounced signal is high (button is stably pressed)
    end else if (count == 31'd0) begin // If the counter has reached zero while button is released
        transmit <= 1'b0; // Debounced signal is low (button is stably released)
    end
    // If count is between 0 and threshold, 'transmit' holds its previous value (implied by reg)
    // This creates the hysteresis for debouncing.
end

endmodule
