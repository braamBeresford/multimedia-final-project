`timescale 1ns / 1ps

module DCT#(parameter DCT_val = 8)(input logic reset, val_input,
            input wire  [12:0] A1 [DCT_val-1:0][DCT_val-1:0], //Opted for parallel input for improves efficiency
            input wire  [12:0] B1 [DCT_val-1:0][DCT_val-1:0], //Opted for parallel input for improves efficiency

				input wire [12:0] x1,

            output logic [12:0] Res1 [DCT_val-1:0][DCT_val-1:0], 
            output logic val_output,
				output logic [12:0] y1
            );


    integer i,j,k;
    always@(posedge val_input or posedge reset)
    begin
        if(reset)begin
            i = 0;
            j = 0;
           
            for(i=0;i < DCT_val;i=i+1)
                for(j=0;j < DCT_val;j=j+1)
                Res1[i][j] <= 0;
        end
        else begin
                i = 0;
                j = 0;
                k = 0;
                //Matrix multiplication
                for(i=0;i < DCT_val;i=i+1)
                    for(j=0;j < DCT_val;j=j+1)
                        for(k=0;k < DCT_val;k=k+1)
                            Res1[i][j] = Res1[i][j] + (A1[i][k] * B1[k][j]);
                        
            end
    end 
	 
	 
	 assign y1=x1/23;
endmodule