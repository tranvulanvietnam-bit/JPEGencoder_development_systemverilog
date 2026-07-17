`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/10/2026 07:31:18 PM
// Design Name: 
// Module Name: tb_headerstuffflush
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module tb_headerstuffflush();

logic clk;
logic reset_n;

logic        valid_bram2header;
logic [15:0] width_bram2header;
logic [15:0] len_bram2header  ;
logic [23:0] pixelnum;

logic        ready_in, valid_in, endtoken_i, valid_out;
logic [7:0]  byte_in, byte_out;
initial clk = 0;
always #5 clk = ~clk;   // 100 MHz clock
///////////////////////////////////////////////////////////
// DUT
///////////////////////////////////////////////////////////

BRAM_widthlen_blknumb romdut(
    .clk        (clk),
    .reset_n    (reset_n),

    .valid_out  (valid_bram2header),

    .width      (width_bram2header),
    .len        (len_bram2header),
    .pixelnum   (pixelnum)
);
HEADER_STUFF_FLUSH outdut (
     .clk             (clk              ),      
     .reset_n         (reset_n          ),      
                                           
     .valid_in        (valid_in         ),      
     .ready_in        (ready_in         ),      
                                          
     .width           (width_bram2header),      
     .len             (len_bram2header  ),      
     .widlen_valid_in (valid_bram2header),
                    
     .endtoken_i      (endtoken_i     ), 
     .byte_in         (byte_in        ),
     .byte_out        (byte_out       ),
     .valid_out       (valid_out      )
);   
///////////////////////////////////////////////////////////
// Reset
///////////////////////////////////////////////////////////

    initial 
    begin
       //-------------------------------------
       // Initialization
       //-------------------------------------
        reset_n   = 0;
        valid_in  = 0;
        byte_in   = 0;
        endtoken_i = 0;
       //-------------------------------------
       // Reset
       //-------------------------------------
       repeat(5) @(posedge clk);
       reset_n = 1;
    ////////////////////////////////////////////////////////
    // SEND AND RECEIVE
    ////////////////////////////////////////////////////////
       //-----------------------------------
      // Normal bytes
      //-----------------------------------
      send_byte(8'b11110000, 0);
      send_byte(8'b10101010, 0);

      //-----------------------------------
      // Test byte stuffing (FF)
      //-----------------------------------
      send_byte(8'b11111111, 0);
      send_byte(8'b01011010, 0);

      //-----------------------------------
      // End token
      //-----------------------------------
      send_byte(8'b00001111, 1);//byteIn byteR = 10 byte_out = 250


  end

  //---------------------------------------
  // Task to send byte
  //---------------------------------------
  task send_byte(
     input [7:0] data, 
     input logic endtok
  );
  begin
     while(!ready_in)
         @(posedge clk);

     byte_in    = data;
     endtoken_i = endtok;
     valid_in   = 1;

     @(posedge clk);
     valid_in   = 0;
  end
  endtask
   
//-----------------------------------------------------------------
// Monitor
//-----------------------------------------------------------------
   initial 
   begin
      $display("time   valid_out  byte_in   byte_out counterheader byte_r valid_in ready_in state nstate");
   end
   always_ff @(posedge clk or negedge reset_n)
   begin
      if (valid_in && ready_in)
      begin
         $display("   VALID AND READY IN");
         $strobe ("   byte_r %d",outdut.byte_r);
      end
      
      if (valid_out)
      begin
         $display("   byte_r %d",outdut.byte_r);
         $strobe ("   byte_out %d",byte_out);
      end
      
      $display("%0t         %b          %d         %d       %d          %d         %d       %d          %d          %d",
                $time, valid_out, byte_in, byte_out,outdut.header_count,outdut.byte_r,outdut.valid_in,outdut.ready_in,outdut.state,outdut.next_state);
   end
//-----------------------------------------------------------------
endmodule
