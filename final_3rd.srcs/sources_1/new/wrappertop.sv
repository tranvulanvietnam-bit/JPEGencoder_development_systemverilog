`timescale 1ns / 1ps

module wrappertop(
   input logic sys_clk_p,
   input logic sys_clk_n,
   input logic reset
);
logic [7:0] byte_out;
logic valid_out      ;
logic clk;
       
   clk_wiz_0 clkwiz_inst
   (
   // Clock out ports
   .clk_out1(clk),     // output clk_out1
   // Status and control signals
   .reset(reset), // input reset
  // Clock in ports
   .clk_in1_p(sys_clk_p),    // input clk_in1_p
   .clk_in1_n(sys_clk_n)    // input clk_in1_n
   );

   design_3rd dut(
   .clk       (clk),
   .reset     (reset),
   .valid_out (valid_out),
   .byte_out  (byte_out)
   );
endmodule
