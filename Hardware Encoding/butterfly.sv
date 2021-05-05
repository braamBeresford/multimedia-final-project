module butterfly(input logic [7:0] in0, in1, 
				output logic [7:0] add, sub);

	always_comb
	begin
		add = in0 + in1;
		sub = in0 - in1; 
	end

endmodule : butterfly