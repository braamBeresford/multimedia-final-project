`timescale 1ns / 1ps

module tb;
	parameter SIZE = 4;
	parameter CYCLE_50 = 20;  //50mhz cycle
    // Inputs
    logic [7:0] A [SIZE-1:0][SIZE-1:0];
    logic [7:0] B [SIZE-1:0][SIZE-1:0];
    // Outputs
    logic [7:0] result [SIZE-1:0][SIZE-1:0];
    logic clk;
    // Instantiate the Unit Under Test (UUT)
    DCT #(.DCT_val(SIZE)) uut (
        .p0(A), 
        .p1(B), 
        .out(result),
        .clk(clk)
    );

    initial begin
    	clk <= 0;
    	forever #(CYCLE_50/2) clk = ~clk;
	end

    initial begin
        // Apply Inputs
        // A = 0;  B = 0;  #100;
        A = '{'{8'h00, 8'h01, 8'h02, 8'h03},
               '{8'h04, 8'h05, 8'h06, 8'h07},
               '{8'h08, 8'h09, 8'h0a, 8'h0b},
               '{8'h0c, 8'h0d, 8'h0e, 8'h0f}}; // assign to full arrayd
        B = '{'{8'h00, 8'h01, 8'h02, 8'h03},
               '{8'h04, 8'h05, 8'h06, 8'h07},
               '{8'h08, 8'h09, 8'h0a, 8'h0b},
               '{8'h0c, 8'h0d, 8'h0e, 8'h0f}}; // assign to full array


    end		
      
endmodule