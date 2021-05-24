module quantization(input  wire  [7:0][7:0][10:0] in_matrix,   // add signed to these i/o's?
	            output logic [7:0][7:0][10:0] out_matrix);

	    // row 0
	    assign out_matrix[0][0] = in_matrix[0][0] / 16;
	    assign out_matrix[0][1] = in_matrix[0][1] / 11;
	    assign out_matrix[0][2] = in_matrix[0][2] / 10;
	    assign out_matrix[0][3] = in_matrix[0][3] / 16;
	    assign out_matrix[0][4] = in_matrix[0][4] / 24;
	    assign out_matrix[0][5] = in_matrix[0][5] / 40;
	    assign out_matrix[0][6] = in_matrix[0][6] / 51;
	    assign out_matrix[0][7] = in_matrix[0][7] / 61;

	    // row 1
	    assign out_matrix[1][0] = in_matrix[1][0] / 12;
	    assign out_matrix[1][1] = in_matrix[1][1] / 12;
	    assign out_matrix[1][2] = in_matrix[1][2] / 14;
	    assign out_matrix[1][3] = in_matrix[1][3] / 19;
	    assign out_matrix[1][4] = in_matrix[1][4] / 26;
	    assign out_matrix[1][5] = in_matrix[1][5] / 58;
	    assign out_matrix[1][6] = in_matrix[1][6] / 60;
	    assign out_matrix[1][7] = in_matrix[1][7] / 55;

	    // row 2
	    assign out_matrix[2][0] = in_matrix[2][0] / 14;
	    assign out_matrix[2][1] = in_matrix[2][1] / 13;
	    assign out_matrix[2][2] = in_matrix[2][2] / 16;
	    assign out_matrix[2][3] = in_matrix[2][3] / 24;
	    assign out_matrix[2][4] = in_matrix[2][4] / 40;
	    assign out_matrix[2][5] = in_matrix[2][5] / 57;
	    assign out_matrix[2][6] = in_matrix[2][6] / 69;
	    assign out_matrix[2][7] = in_matrix[2][7] / 56;

	    // row 3
	    assign out_matrix[3][0] = in_matrix[3][0] / 14;
	    assign out_matrix[3][1] = in_matrix[3][1] / 17;
	    assign out_matrix[3][2] = in_matrix[3][2] / 22;
	    assign out_matrix[3][3] = in_matrix[3][3] / 29;
	    assign out_matrix[3][4] = in_matrix[3][4] / 51;
	    assign out_matrix[3][5] = in_matrix[3][5] / 87;
	    assign out_matrix[3][6] = in_matrix[3][6] / 80;
	    assign out_matrix[3][7] = in_matrix[3][7] / 62;

	    // row 4
	    assign out_matrix[4][0] = in_matrix[4][0] / 18;
	    assign out_matrix[4][1] = in_matrix[4][1] / 22;
	    assign out_matrix[4][2] = in_matrix[4][2] / 37;
	    assign out_matrix[4][3] = in_matrix[4][3] / 56;
	    assign out_matrix[4][4] = in_matrix[4][4] / 68;
	    assign out_matrix[4][5] = in_matrix[4][5] / 109;
	    assign out_matrix[4][6] = in_matrix[4][6] / 103;
	    assign out_matrix[4][7] = in_matrix[4][7] / 77;

	    // row 5
	    assign out_matrix[5][0] = in_matrix[5][0] / 24;
	    assign out_matrix[5][1] = in_matrix[5][1] / 35;
	    assign out_matrix[5][2] = in_matrix[5][2] / 55;
	    assign out_matrix[5][3] = in_matrix[5][3] / 64;
	    assign out_matrix[5][4] = in_matrix[5][4] / 81;
	    assign out_matrix[5][5] = in_matrix[5][5] / 104;
	    assign out_matrix[5][6] = in_matrix[5][6] / 113;
	    assign out_matrix[5][7] = in_matrix[5][7] / 92;

	    // row 6
	    assign out_matrix[6][0] = in_matrix[6][0] / 49;
	    assign out_matrix[6][1] = in_matrix[6][1] / 64;
	    assign out_matrix[6][2] = in_matrix[6][2] / 78;
	    assign out_matrix[6][3] = in_matrix[6][3] / 87;
	    assign out_matrix[6][4] = in_matrix[6][4] / 103;
	    assign out_matrix[6][5] = in_matrix[6][5] / 121;
	    assign out_matrix[6][6] = in_matrix[6][6] / 120;
	    assign out_matrix[6][7] = in_matrix[6][7] / 101;

	    // row 7
	    assign out_matrix[7][0] = in_matrix[7][0] / 72;
	    assign out_matrix[7][1] = in_matrix[7][1] / 92;
	    assign out_matrix[7][2] = in_matrix[7][2] / 95;
	    assign out_matrix[7][3] = in_matrix[7][3] / 98;
	    assign out_matrix[7][4] = in_matrix[7][4] / 112;
	    assign out_matrix[7][5] = in_matrix[7][5] / 100;
	    assign out_matrix[7][6] = in_matrix[7][6] / 103;
	    assign out_matrix[7][7] = in_matrix[7][7] / 99;

endmodule
