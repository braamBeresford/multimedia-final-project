`timescale 1ns / 1ps

module DCT #(parameter DCT_val = 8)(input logic clk,
			input wire  [7:0] p0 [DCT_val-1:0][DCT_val-1:0], //Oppted for parallel input for improves efficiency
			input wire  [7:0] p1 [DCT_val-1:0][DCT_val-1:0], //Oppted for parallel input for improves efficiency


			output logic [7:0] out [DCT_val-1:0][DCT_val-1:0]
			);

	logic [7:0] macro_block1 [DCT_val-1:0][DCT_val-1:0]; // Matrix that holds the 8x8 block for processing
	logic [7:0] macro_block2 [DCT_val-1:0][DCT_val-1:0]; // Matrix that holds the 8x8 block for processing

	reg [7:0] result [DCT_val-1:0][DCT_val-1:0]; // Matrix that holds the 8x8 block for processing


	always_ff @(posedge clk) begin
		macro_block1 <= p0;
		macro_block2 <= p1;
		out <= result;
	end

	integer i,j,k;
	always_comb begin
		  for(i=0;i < DCT_val-1;i=i+1)
            for(j=0;j < DCT_val-1;j=j+1)
                for(k=0;k < DCT_val-1;k=k+1)
                	result[i][j] += macro_block1[i][k] * macro_block2[k][j];
	end

endmodule