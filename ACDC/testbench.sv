// Code your testbench here
// or browse Examples
`timescale 1ns/1ns

module tb ();
  
  parameter CYCLE = 100;
  parameter B = 64; 
  parameter C = 110;
  
  logic clk;
  logic done;
  logic signed [11:0] val_array[B];
  logic [C:0] code;
  logic next;
  logic start;
  logic rst;
  
  coeff #(.B(B), .C(C))coeff_0(.clk(clk), .val_array(val_array), .code(code), .start(start), .done(done), .rst(rst));
  
  initial begin //set up clk
    clk = 0;
    forever #(CYCLE/2) clk = ~clk;
  end
  
  initial begin
    rst = 1;
    #(CYCLE);
    rst = 0;
  end
    
  initial begin
//    val_array = {-33, 6, 7, 0, 0, 0, 3, -1, 0, 0, 0}; //shorter for testing
    val_array = {-49, 0, 0, -12, 0, -16, 0, 0, 0, 0, -1, 0, 9, 0, -1, 0, 0, 0, 0, 0, 0, 0, 0, -1, 0, -1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}; //longer for time test
//    val_array = 0;

  end
  
  initial begin
    #(2*CYCLE);
    start = 1;
    #(CYCLE);
    start = 0;
    #(CYCLE);
    while(!done) #(CYCLE);
      #(CYCLE);
//    val_array = {-82, 0, 0, -12, 0, -16, 0, 0, 0, 0, -1};
    $display("code=%b",code);
/*    #(CYCLE);
    start = 1;
    #(CYCLE);
    start = 0;
    #(CYCLE);
    while(!done) #(CYCLE);
    #(CYCLE);
     $display("code=%b",code);
    val_array = {-115, 6, 7, 0, 0, 0, 3, -1, 0, 0, 0};
     #(CYCLE);
    start = 1;
    #(CYCLE);
    start = 0;
    #(CYCLE);
    while(!done) #(CYCLE);
    #(CYCLE);
     $display("code=%b",code);
*/
    
  $stop;
  end

endmodule

