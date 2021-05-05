`timescale 1ns / 1ps

module DCT #(parameter DCT_height = 8, DCT_width = 8)(input logic clk, val_input, reset_n, 
			input logic [7:0] p0, p1, p2, p3, p4, p5, p6, p7, //Oppted for parallel input for improves efficiency

			output logic [15:0] d0, d1, d2, d3, d4, d5, d6, d7,
			output logic val_output
			);

	logic [7:0] a0, a1, a2, a3, s0, s1, s2, s3; // Add and subtractions from first stage butterfly

	logic [7:0] a10, a11, s10, s11; // Add and subtractions from second stage butterfly

	logic [7:0] a100,s100;                  // wire for 3-stage butterfly

	logic [7:0] matrix [7:0]; // Matrix that holds the 8x8 block for processing

	logic [15:0] s1C7,s1C1,s3C5,s3C3,s0C5,s0C3,s1C5,s1C3,s3C1,s3C7,s2C1,s2C7,s11C6,
					s11C2,s0C7,s0C1,s2C5,s2C3,s10C6,s10C2; // partial products

	logic [15:0] t0, t1, t2, t3, t4, t5, t6, t7;


	logic [7:0] C5= 8'h46,//0.55,                                                  // 0.55  // ci = cos (i*pi/2*N)
		   C6= 8'h31,//0.38,                                                  // 0.38
		   C7= 8'h18,//0.19,                                                  // 0.19
		   C4= 8'h5A,//0.70,
		   C3= 8'h6A,//0.83,                                                   // 0.83 // si = sin (i*pi/2*N)
		   C2= 8'h76,//0.92,                                                   // 0.92
		   C1= 8'h7D;//0.98;                                                   // 0.98 

	// This portion handles the inporting of memory and resets
	enum logic [1:0] {READY, COPY, OUTPUT} state;

	always_ff @(posedge clk or negedge reset_n) begin
		if(~reset_n) begin
			for(int i = 0; i <= 7; i++)
			begin
				matrix[i] = 0;
			end
			val_output <= 0;
			state <= READY;
		end 

		else begin
			 case(state)
			 	READY: begin
			 		if(val_input) begin
			 			matrix[0] <= p0;
						matrix[1] <= p1;
						matrix[2] <= p2;
						matrix[3] <= p3;
						matrix[4] <= p4;
						matrix[5] <= p5;
						matrix[6] <= p6;
						matrix[7] <= p7;
						state <= OUTPUT;
			 		end
			 		else begin state <= READY; end
			 	end
			 	OUTPUT: begin
			 		d0 <= t0;
			 		d1 <= t1;
			 		d2 <= t2;
			 		d3 <= t3;
			 		d4 <= t4;
			 		d5 <= t5;
			 		d6 <= t6;
			 		d7 <= t7;
			 		state <= READY;
				end

			endcase // state


		end
	end

	// always_ff @(posedge clk iff val_input or negedge reset_n) begin
	// 	if(~reset_n) begin  // Synthesizable reset logic
	// 		for(int i = 0; i <= 7; i++)begin
	// 			matrix[i] = 0;
	// 		end
	// 		state <= READY;
	// 	end


	// 	else begin
	// 		matrix[0] = p0;
	// 		matrix[1] = p1;
	// 		matrix[2] = p2;
	// 		matrix[3] = p3;
	// 		matrix[4] = p4;
	// 		matrix[5] = p5;
	// 		matrix[6] = p6;
	// 		matrix[7] = p7;
	// 	end
	// 	val_output = 1'b0;
	// end
	
	// First stage butterfly
		butterfly b0(.in0(matrix[0]), .in1(matrix[1]), .add(a0), .sub(s0));
		butterfly b1(.in0(matrix[3]), .in1(matrix[4]), .add(a1), .sub(s1));
		butterfly b2(.in0(matrix[1]), .in1(matrix[6]), .add(a2), .sub(s2));
		butterfly b3(.in0(matrix[2]), .in1(matrix[5]), .add(a3), .sub(s3));

		// Second stage butterfly
		butterfly b4(.in0(a0), .in1(a1), .add(a10), .sub(s10));
		butterfly b5(.in0(a2), .in1(a3), .add(a11), .sub(s11));
		
		// Third stage butterfly
	    butterfly b6(.in0 (a10), .in1 (a11), .add (a100), .sub(s100));
	always_comb
	begin
		
		

		

		s1C7 = s1*C7;
	    s1C1 = s1*C1;
	    s0C7 = s0*C7;
	    s0C1 = s0*C1;
	    s3C5 = s3*C5;
	    s3C3 = s3*C3;
	    s2C5 = s2*C5;
	    s2C3 = s2*C3;
	    s0C5 = s0*C5;
	    s0C3 = s0*C3;
	    s1C5 = s1*C5;
	    s1C3 = s1*C3;
	    s3C1 = s3*C1;
	    s3C7 = s3*C7;
	    s2C1 = s2*C1;
	    s2C7 = s2*C7;

	    

	    s11C6 = s11*C6;
	    s11C2 = s11*C2;
	    s10C6 = s10*C6;
	    s10C2 = s10*C2;

	    t0 = (a100*C4);       //X(0)
	    t4 = (s100*C4);       //X(4)

	    t2 = s11C6+s10C2;     //X(2)
	    t6 = s10C6-s11C2;     //X(6)

	    t1 = s1C7+s0C1+s3C5+s2C3;      //X(1)
	    t7 = s3C3-s2C5+s0C7-s1C1;      //X(7)

	    t3 = s0C3-s1C5-s2C7-s3C1;      //X(3)
	    t5 = s0C5+s1C3-s2C1+s3C7;      //X(5)

	end
endmodule