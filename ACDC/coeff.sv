// Code your design here


module coeff #(B=64, C=511)(input logic signed[11:0] val_array[B], input clk, output logic [C:0]code, input logic start, input logic rst, output logic done);
  //640 max code length (8x8x10)
  
  parameter EOB = 4'b1010;
  
  logic [4:0] m;
  logic [15:0] huff;
  logic [5:0] huff_size;
  logic [15:0] curr_bit;
  logic check_done;
  logic signed[11:0] DC_prev;
  logic signed[11:0] value;
  logic signed[11:0] val_vli;
  logic [6:0] i;
  logic [6:0] run_length;
  logic eob_set;
  logic eob_start;
 
  wire next;
  wire wait_s;
  wire dc_vlc;
  wire dc_vli;
  wire ac_coeff;
  wire ac_vlc;
  wire ac_vli;
  
  
// State Machine
  enum logic [2:0] {
    WAIT = 3'b000,
    DC_VLC = 3'b001,
    DC_VLI = 3'b010,
    AC_COEFF = 3'b011,
    AC_VLC = 3'b100,
    AC_VLI = 3'b101,
    DONE = 3'b110} state_c, state_n;
  
  always_ff @(posedge clk) begin //debug ff for checking values on clock edge
//    $display("m=%d, state=%b, i=%d, huff_size=%d, value=%d, RL=%d, check=%b", m, state_c, i, huff_size, value, run_length, check_done);
//    $display("%d", DC_prev);
//    $display("code_sv=%b",code);
  end
  
  always_ff @( posedge clk, posedge rst) begin
    if(rst) begin
      state_c <= WAIT;
      i <= 0;
      DC_prev = 0;
    end 
	else
      state_c <= state_n;
    
    if(done)
      i = 0;
    else if(next)
      i++;
    
    if(i == 0)
      value <= val_array[i] - DC_prev;
    else
      value <= val_array[i];
    if(state_n == DONE)
      DC_prev = val_array[0];
  end
  
  always_comb begin
    case(state_c)
      WAIT:		begin
        												
        												done = 0;
        												eob_start = 0;
        		if(start)								state_n = DC_VLC; //go to dc vlc in start
      			else									state_n = WAIT; //loop to wait until start signal
      			end 
      DC_VLC:	if(huff_size == 0 && check_done)		state_n = DC_VLI; //move to vli encoding when huffman code has been added
      			else									state_n = DC_VLC;
      DC_VLI:	if(m == 0)								state_n = AC_COEFF; //after adding m LSB's, count zeros
      			else									state_n = DC_VLI;
      
      AC_COEFF:	begin        												
        		if(i == B)								state_n = DONE; //received 0, inc count, take next value
        		else if (value == 0)					state_n = AC_COEFF; //at end of zig-zag, move to done state
      			else									state_n = AC_VLC; //val_in not 01 or 10
      			end
      
      AC_VLC:	begin       												
       			if(huff_size == 0 && check_done)		state_n = AC_VLI; //huffman code added to bitstream, start ac vli encoding
        		else									state_n = AC_VLC;
      			end

      AC_VLI:	if(m == 0)								state_n = AC_COEFF; //m LSB's added, look for zeros
      			else									state_n = AC_VLI;
      
      DONE:		begin
        		if(eob_set)								state_n = WAIT;
        		else begin								eob_start = 1;
                  										state_n = DONE;
                end
        												done = 1; //set done bit
     			end
    endcase 
  end
    
  
  
  
  
  
  
  
  assign wait_s = state_c == WAIT;
  assign dc_vlc = state_c == DC_VLC;
  assign dc_vli = state_c == DC_VLI;
  assign ac_coeff = state_n == AC_COEFF;
  assign ac_vlc = state_c == AC_VLC;
  assign ac_vli = state_c == AC_VLI;
  
  
  
//end state machine

  assign next = (state_c == DC_VLI && state_n == AC_COEFF) || (state_c == AC_VLI && state_n == AC_COEFF) || (state_n == AC_COEFF && value == 0);

  
  always @(posedge clk) begin //VLC Loop
    if (wait_s) begin //reset value while in WAIT
      huff_size = 0;
      curr_bit = C;
      code = 0;
      check_done = 0;
    end
    else if(ac_coeff)
      check_done = 0; 
    else if(dc_vlc || ac_vlc) begin
      if(huff_size>0) begin
      check_done = 1;
      code[curr_bit] = huff[huff_size-1];
      curr_bit = curr_bit - 1;
      huff_size = huff_size - 1;
      end
    end
    
    if(eob_start && !eob_set) begin
      code[curr_bit] = 1;
      code[curr_bit-1] = 0;
      code[curr_bit-2] = 1;
      code[curr_bit-3] = 0;
      eob_set = 1;
    end
    else
      eob_set = 0;
  end
  
  always @(posedge clk) begin //VLI Loop
    if(dc_vli || ac_vli) begin
      if(value<0)
        val_vli = value - 1;
      else
        val_vli = value;
      if(m>0) begin
        code[curr_bit] = val_vli[m-1];
        curr_bit = curr_bit - 1;
        m = m-1;
        run_length = 0;
      end
    end
    
    


  end

    always @(posedge clk) begin //AC Coefficient check
    if(dc_vlc)
      run_length = 0;
    else if (ac_coeff) begin
      if(value == 0)
        run_length = run_length + 1;
      
    end
    end 
  
  always @(posedge clk) begin //Huffman Tables
//DC
    if (dc_vlc && !check_done) begin
    if (value == 0) begin
        huff = 2'b01;
        huff_size = 2;
        m = 0;
    end
    else if (value == -1 || value == 1) begin
      huff = 3'b010;
      huff_size = 3;
      m = 1;
    end
    else if ((value >= -3 && value <= -2) || (value >= 2 && value <= 3)) begin
      huff = 3'b011;
      huff_size = 3;
      m = 2;
    end
    else if ((value >= -7 && value <= -4) || (value >= 4 && value <= 7)) begin
      huff = 3'b100;
      huff_size = 3;
      m = 3;
    end
    else if ((value >= -15 && value <= -8) || (value >= 8 && value <= 15)) begin
      huff = 3'b101;
      huff_size = 3;
      m = 4;
    end
    else if ((value >= -31 && value <= -16) || (value >= 16 && value <= 31)) begin
      huff = 3'b110;
      huff_size = 3;
      m = 5;
    end
    else if ((value >= -63 && value <= -32) || (value >= 32 && value <= 63)) begin
      huff = 4'b1110;
      huff_size = 4;
      m = 6;
    end
    else if ((value >= -127 && value <= -64) || (value >= 64 && value <= 127)) begin
      huff = 5'b11110;
      huff_size = 5;
      m = 7;
    end
    else if ((value >= -255 && value <= -128) || (value >= 128 && value <= 255)) begin
      huff = 6'b111110;
      huff_size = 6;
      m = 8;
    end
    else if ((value >= -511 && value <= -256) || (value >= 256 && value <= 511)) begin
      huff = 7'b1111110;
      huff_size = 7;
      m = 9;
    end
    else if ((value >= -1023 && value <= -512) || (value >= 512 && value <= 1023)) begin
      huff = 8'b11111110;
      huff_size = 8;
      m = 10;
    end
    else if ((value >= -2047 && value <= -1024) || (value >= 1024 && value <= 2047)) begin
      huff = 9'b111111110;
      huff_size = 9;
      m = 11;
    end     
  end
//AC  
    else if (!dc_vlc && !check_done) begin
//      $display("test, %d", value);
    if (value == 0) begin
        m = 0;
    end
    else if (value == -1 || value == 1) begin
      m = 1;
    end
    else if ((value >= -3 && value <= -2) || (value >= 2 && value <= 3)) begin
      m = 2;
    end
    else if ((value >= -7 && value <= -4) || (value >= 4 && value <= 7)) begin
      m = 3;
    end
    else if ((value >= -15 && value <= -8) || (value >= 8 && value <= 15)) begin
      m = 4;
    end
    else if ((value >= -31 && value <= -16) || (value >= 16 && value <= 31)) begin
      m = 5;
    end
    else if ((value >= -63 && value <= -32) || (value >= 32 && value <= 63)) begin
      m = 6;
    end
    else if ((value >= -127 && value <= -64) || (value >= 64 && value <= 127)) begin
      m = 7;
    end
    else if ((value >= -255 && value <= -128) || (value >= 128 && value <= 255)) begin
      m = 8;
    end
    else if ((value >= -511 && value <= -256) || (value >= 256 && value <= 511)) begin
      m = 9;
    end
    else if ((value >= -1023 && value <= -512) || (value >= 512 && value <= 1023)) begin
      m = 10;
    end

    end
  end
  
  always @(posedge clk) begin //AC Huff Table
    if(ac_vlc && !check_done) begin
      if(value == 0)
        run_length = run_length + 1;
      else
      unique case (run_length)
        0: begin
          unique case (m)
              1:begin 	huff = 2'b00;
                		huff_size = 2;
              end
              2:begin 	huff = 2'b01;
                		huff_size = 2;
              end
              3:begin	huff = 3'b100;
                		huff_size = 3;
              end
              4:begin	huff = 4'b1011;
                		huff_size = 4;
              end
              5:begin	huff = 5'b11010;
                  		huff_size = 5;
              end
              6:begin	huff = 7'b1111000;
                		huff_size = 7;
              end
              7:begin	huff = 8'b11111000;
                		huff_size = 8;
              end
              8:begin	huff = 10'b1111110110;
                		huff_size = 10;
              end
              9:begin	huff = 16'b1111111110000010;
                		huff_size = 16;
              end
              10:begin	huff = 16'b1111111110000011;
                		huff_size = 16;
              end
           endcase 
        end
        1: begin
          unique case (m)
              1:begin	huff = 4'b1100;
                		huff_size = 4;
              end
              2:begin	huff = 5'b11011;
                		huff_size = 5;
              end
              3:begin	huff = 8'b11110001;
                		huff_size = 8;
              end
              4:begin	huff = 9'b111110110;
                		huff_size = 9;
              end
              5:begin	huff = 11'b11111110110;
                		huff_size = 11;
              end
              6:begin	huff = 16'b1111111110000100;
                		huff_size = 16;
              end
              7:begin	huff = 16'b1111111110000101;
                		huff_size = 16;
              end
              8:begin	huff = 16'b1111111110000110;
                		huff_size = 16;
              end
              9:begin	huff = 16'b1111111110000111;
                		huff_size = 16;
              end
              10:begin	huff = 16'b1111111110001000;
                		huff_size = 16;
              end
           endcase 
        end
        2: begin
          unique case (m)
              1:begin	huff = 5'b11100;
                		huff_size = 5;
              end
              2:begin	huff = 8'b11111001;
                		huff_size = 8;
              end
              3:begin	huff = 10'b1111110111;
                		huff_size = 10;
              end
              4:begin	huff = 12'b111111110100;
                		huff_size = 12;
              end
              5:begin	huff = 16'b1111111110001001;
                		huff_size = 16;
              end
              6:begin	huff = 16'b1111111110001010;
                		huff_size = 16;
              end
              7:begin	huff = 16'b1111111110001011;
                		huff_size = 16;
              end
              8:begin	huff = 16'b1111111110001100;
                		huff_size = 16;
              end
              9:begin	huff = 16'b1111111110001101;
                		huff_size = 16;
              end
              10:begin	huff = 16'b1111111110001110;
                		huff_size = 16;
              end
           endcase 
        end
        3: begin
          unique case (m)
              1:begin	huff = 6'b111010;
                		huff_size = 6;
              end
              2:begin	huff = 9'b111110111;
                		huff_size = 9;
              end
              3:begin	huff = 12'b111111110101;
                		huff_size = 12;
              end
              4:begin	huff = 16'b1111111110001111;
                		huff_size = 16;
              end
              5:begin	huff = 16'b1111111110010000;
                		huff_size = 16;
              end
              6:begin	huff = 16'b1111111110010001;
                		huff_size = 16;
              end
              7:begin	huff = 16'b1111111110010010;
                		huff_size = 16;
              end
              8:begin	huff = 16'b1111111110010011;
                		huff_size = 16;
              end
              9:begin	huff = 16'b1111111110010100;
                		huff_size = 16;
              end
              10:begin	huff = 16'b1111111110010101;
                		huff_size = 16;
              end
           endcase 
        end
        4: begin
          unique case (m)
              1:begin	huff = 6'b111011;
                		huff_size = 6;
              end
              2:begin	huff = 10'b1111111000;
                		huff_size = 10;
              end
              3:begin	huff = 16'b1111111110010110;
                		huff_size = 16;
              end
              4:begin	huff = 16'b1111111110010111;
                		huff_size = 16;
              end
              5:begin	huff = 16'b1111111110011000;
                		huff_size = 16;
              end
              6:begin	huff = 16'b1111111110011001;
                		huff_size = 16;
              end
              7:begin	huff = 16'b1111111110011010;
                		huff_size = 16;
              end
              8:begin	huff = 16'b1111111110011011;
                		huff_size = 16;
              end
              9:begin	huff = 16'b1111111110011100;
                		huff_size = 16;
              end
              10:begin	huff = 16'b1111111110011101;
                		huff_size = 16;
              end
           endcase 
        end
        5: begin
          unique case (m)
              1:begin	huff = 7'b1111010;
                		huff_size = 7;
              end
              2:begin	huff = 11'b11111110111;
                		huff_size = 11;
              end
              3:begin	huff = 16'b1111111110011110;
                		huff_size = 16;
              end
              4:begin	huff = 16'b1111111110011111;
                		huff_size = 16;
              end
              5:begin	huff = 16'b1111111110100000;
                		huff_size = 16;
              end
              6:begin	huff = 16'b1111111110100001;
                		huff_size = 16;
              end
              7:begin	huff = 16'b1111111110100010;
                		huff_size = 16;
              end
              8:begin	huff = 16'b1111111110100011;
                		huff_size = 16;
              end
              9:begin	huff = 16'b1111111110100100;
                		huff_size = 16;
              end
              10:begin	huff = 16'b1111111110100101;
                		huff_size = 16;
              end
           endcase 
        end
        6: begin
          unique case (m)
              1:begin	huff = 7'b1111011;
                		huff_size = 7;
              end
              2:begin	huff = 12'b111111110110;
                		huff_size = 12;
              end
              3:begin	huff = 16'b1111111110100110;
                		huff_size = 16;
              end
              4:begin	huff = 16'b1111111110100111;
                		huff_size = 16;
              end
              5:begin	huff = 16'b1111111110101000;
                		huff_size = 16;
              end
              6:begin	huff = 16'b1111111110101001;
                		huff_size = 16;
              end
              7:begin	huff = 16'b1111111110101010;
                		huff_size = 16;
              end
              8:begin	huff = 16'b1111111110101011;
                		huff_size = 16;
              end
              9:begin	huff = 16'b1111111110101100;
                		huff_size = 16;
              end
              10:begin	huff = 16'b1111111110101101;
                		huff_size = 16;
              end
           endcase 
        end
        7: begin
          unique case (m)
              1:begin	huff = 8'b11111010;
                		huff_size = 8;
              end
              2:begin	huff = 12'b111111110111;
                		huff_size = 12;
              end
              3:begin	huff = 16'b1111111110101110;
                		huff_size = 16;
              end
              4:begin	huff = 16'b1111111110101111;
                		huff_size = 16;
              end
              5:begin	huff = 16'b1111111110110000;
                		huff_size = 16;
              end
              6:begin	huff = 16'b1111111110110001;
                		huff_size = 16;
              end
              7:begin	huff = 16'b1111111110110010;
                		huff_size = 16;
              end
              8:begin	huff = 16'b1111111110110011;
                		huff_size = 16;
              end
              9:begin	huff = 16'b1111111110110100;
                		huff_size = 16;
              end
              10:begin	huff = 16'b1111111110110101;
                		huff_size = 16;
              end
           endcase 
        end
        8: begin
          unique case (m)
              1:begin	huff = 9'b111111000;
                		huff_size = 9;
              end
              2:begin	huff = 15'b111111111000000;
                		huff_size = 15;
              end
              3:begin	huff = 16'b1111111110110110;
                		huff_size = 16;
              end
              4:begin	huff = 16'b1111111110110111;
                		huff_size = 16;
              end
              5:begin	huff = 16'b1111111110111000;
                		huff_size = 16;
              end
              6:begin	huff = 16'b1111111110111001;
                		huff_size = 16;
              end
              7:begin	huff = 16'b1111111110111010;
                		huff_size = 16;
              end
              8:begin	huff = 16'b1111111110111011;
                		huff_size = 16;
              end
              9:begin	huff = 16'b1111111110111100;
                		huff_size = 16;
              end
              10:begin	huff = 16'b1111111110111101;
                		huff_size = 16;
              end
           endcase 
        end
        9: begin
          unique case (m)
              1:begin	huff = 9'b111111001;
                		huff_size = 9;
              end
              2:begin	huff = 16'b1111111110111110;
                		huff_size = 16;
              end
              3:begin	huff = 16'b1111111110111111;
                		huff_size = 16;
              end
              4:begin	huff = 16'b1111111111000000;
                		huff_size = 16;
              end
              5:begin	huff = 16'b1111111111000001;
                		huff_size = 16;
              end
              6:begin	huff = 16'b1111111111000010;
                		huff_size = 16;
              end
              7:begin	huff = 16'b1111111111000011;
                		huff_size = 16;
              end
              8:begin	huff = 16'b1111111111000100;
                		huff_size = 16;
              end
              9:begin	huff = 16'b1111111111000101;
                		huff_size = 16;
              end
              10:begin	huff = 16'b1111111111000110;
                		huff_size = 16;
              end
           endcase 
        end
        10: begin
          unique case (m)
              1:begin	huff = 9'b111111010;
                		huff_size = 9;
              end
              2:begin	huff = 16'b1111111111000111;
                		huff_size = 16;
              end
              3:begin	huff = 16'b1111111111001000;
                		huff_size = 16;
              end
              4:begin	huff = 16'b1111111111001001;
                		huff_size = 16;
              end
              5:begin	huff = 16'b1111111111001010;
                		huff_size = 16;
              end
              6:begin	huff = 16'b1111111111001011;
                		huff_size = 16;
              end
              7:begin	huff = 16'b1111111111001100;
                		huff_size = 16;
              end
              8:begin	huff = 16'b1111111111001101;
                		huff_size = 16;
              end
              9:begin	huff = 16'b1111111111001110;
                		huff_size = 16;
              end
              10:begin	huff = 16'b1111111111001111;
                		huff_size = 16;
              end
           endcase 
        end
        11: begin 
          unique case (m)
              1:begin	huff = 10'b1111111001;
                		huff_size = 10;
              end
              2:begin	huff = 16'b1111111111010000;
                		huff_size = 16;
              end
              3:begin	huff = 16'b1111111111010001;
                		huff_size = 16;
              end
              4:begin	huff = 16'b1111111111010010;
                		huff_size = 16;
              end
              5:begin	huff = 16'b1111111111010011;
                		huff_size = 16;
              end
              6:begin	huff = 16'b1111111111010100;
                		huff_size = 16;
              end
              7:begin	huff = 16'b1111111111010101;
                		huff_size = 16;
              end
              8:begin	huff = 16'b1111111111010110;
                		huff_size = 16;
              end
              9:begin	huff = 16'b1111111111010111;
                		huff_size = 16;
              end
              10:begin	huff = 16'b1111111111011000;
                		huff_size = 16;
              end
           endcase 
        end 
        12: begin 
          unique case (m)
              1:begin	huff = 10'b1111111010;
                		huff_size = 10;
              end
              2:begin	huff = 16'b1111111111011001;
                		huff_size = 16;
              end
              3:begin	huff = 16'b1111111111011010;
                		huff_size = 16;
              end
              4:begin	huff = 16'b1111111111011011;
                		huff_size = 16;
              end
              5:begin	huff = 16'b1111111111011100;
                		huff_size = 16;
              end
              6:begin	huff = 16'b1111111111011101;
                		huff_size = 16;
              end
              7:begin	huff = 16'b1111111111011110;
                		huff_size = 16;
              end
              8:begin	huff = 16'b1111111111011111;
                		huff_size = 16;
              end
              9:begin	huff = 16'b1111111111100000;
                		huff_size = 16;
              end
              10:begin	huff = 16'b1111111111100001;
                		huff_size = 16;
              end
           endcase 
        end 
        13: begin 
          unique case (m)
              1:begin	huff = 11'b11111111000;
                		huff_size = 11;
              end
              2:begin	huff = 16'b1111111111100010;
                		huff_size = 16;
              end
              3:begin	huff = 16'b1111111111100011;
                		huff_size = 16;
              end
              4:begin	huff = 16'b1111111111100100;
                		huff_size = 16;
              end
              5:begin	huff = 16'b1111111111100101;
                		huff_size = 16;
              end
              6:begin	huff = 16'b1111111111100110;
                		huff_size = 16;
              end
              7:begin	huff = 16'b1111111111100111;
                		huff_size = 16;
              end
              8:begin	huff = 16'b1111111111101000;
                		huff_size = 16;
              end
              9:begin	huff = 16'b1111111111101001;
                		huff_size = 16;
              end
              10:begin	huff = 16'b1111111111101010;
                		huff_size = 16;
              end
           endcase 
        end
        14: begin
          unique case (m)
              1:begin	huff = 16'b1111111111101011;
                		huff_size = 16;
              end
              2:begin	huff = 16'b1111111111101100;
                		huff_size = 16;
              end
              3:begin	huff = 16'b1111111111101101;
                		huff_size = 16;
              end
              4:begin	huff = 16'b1111111111101110;
                		huff_size = 16;
              end
              5:begin	huff = 16'b1111111111101111;
                		huff_size = 16;
              end
              6:begin	huff = 16'b1111111111110000;
                		huff_size = 16;
              end
              7:begin	huff = 16'b1111111111110001;
                		huff_size = 16;
              end
              8:begin	huff = 16'b1111111111110010;
                		huff_size = 16;
              end
              9:begin	huff = 16'b1111111111110011;
                		huff_size = 16;
              end
              10:begin	huff = 16'b1111111111110100;
                		huff_size = 16;
              end
           endcase 
        end
        15: begin
          unique case (m)
              1:begin	huff = 16'b1111111111110101;
                		huff_size = 16;
              end
              2:begin	huff = 16'b1111111111110110;
                		huff_size = 16;
              end
              3:begin	huff = 16'b1111111111110111;
                		huff_size = 16;
              end
              4:begin	huff = 16'b1111111111111000;
                		huff_size = 16;
              end
              5:begin	huff = 16'b1111111111111001;
                		huff_size = 16;
              end
              6:begin	huff = 16'b1111111111111010;
                		huff_size = 16;
              end
              7:begin	huff = 16'b1111111111111011;
                		huff_size = 16;
              end
              8:begin	huff = 16'b1111111111111100;
                		huff_size = 16;
              end
              9:begin	huff = 16'b1111111111111101;
                		huff_size = 16;
              end
              10:begin	huff = 16'b1111111111111110;
                		huff_size = 16;
              end
           endcase 
        end
      endcase

    end
      
  end
  
  
endmodule
  
