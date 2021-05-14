`timescale 1ns / 1ps

module tb;
	parameter SIZE = 4;
	parameter CYCLE_50 = 20;  //50mhz cycle
    // Inputs
    logic [12:0] A [SIZE-1:0][SIZE-1:0];
    logic [12:0] B [SIZE-1:0][SIZE-1:0];
    // Outputs
    logic [12:0] result [SIZE-1:0][SIZE-1:0];
    logic clk, val_in, val_out, reset;
    // Instantiate the Unit Under Test (UUT)
    DCT #(.DCT_val(SIZE)) uut (
        .val_input (val_in),
        .val_output(val_out),
        .A1(A), 
        .B1(B), 
        .Res1(result),
        .reset(reset)
        // .clk(clk)
    );

    initial begin
    	clk <= 0;
    	forever #(CYCLE_50/2) clk = ~clk;
	end

    initial begin
        // Apply Inputs
        // A = 0;  B = 0;  #100;
          val_in = 0;
          reset = 0;
          #(CYCLE_50*2)
          reset = 1;
          #(CYCLE_50*2)
          reset = 0;
        //   A = '{'{8'h00, 8'h01},
        //        '{8'h0c, 8'h0d}}; // assign to full arrayd
        // B = '{'{8'h00, 8'h03},
        //        '{8'h0c, 8'h0f}}; // assign to full array

        A = '{'{8'h00, 8'h01, 8'h02, 8'h03},
               '{8'h04, 8'h05, 8'h06, 8'h07},
               '{8'h08, 8'h09, 8'h0a, 8'h0b},
               '{8'h0c, 8'h0d, 8'h0e, 8'h0f}}; // assign to full arrayd
        B = '{'{8'h00, 8'h01, 8'h02, 8'h03},
               '{8'h04, 8'h05, 8'h06, 8'h07},
               '{8'h08, 8'h09, 8'h0a, 8'h0b},
               '{8'h0c, 8'h0d, 8'h0e, 8'h0f}}; // assign to full array

        
        #(CYCLE_50*3)
        val_in = 1;
        #CYCLE_50;
        val_in = 0;
        


    end		
      
endmodule