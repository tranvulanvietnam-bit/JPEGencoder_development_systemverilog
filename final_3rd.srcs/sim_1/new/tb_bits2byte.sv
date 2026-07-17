`timescale 1ns / 1ps

module tb_bits2byte;
   // ----------------------------------------
   // DUT I/O signal
   // ----------------------------------------
   //----------------------------------------- 
   // Clock / Reset 
   //----------------------------------------- 
   logic clk; 
   logic reset_n; 
   initial clk = 0; 
   always #5 clk = ~clk; // 100 MHz clock
   //----------------------------------------- 
   // Handshake signals 
   //----------------------------------------- 
   logic valid_in; 
   logic ready_in; 
   logic valid_out; 
   logic ready_out;
   //-----------------------------------------
   // End token
   //-----------------------------------------
   logic endtoken_i; 
   logic endtoken_o;
   //-----------------------------------------
   // INPUT OUTPUT DATA
   //-----------------------------------------
   logic [15:0]        huf        ;            
   logic [7:0]         huf_len    ;
   logic [15:0]        symbol     ;         
   logic [7:0]         symbol_len ;     
   logic               eob        ;
   logic [7:0]         byte_out   ;          
   
   Bit2Byte dut (
      .clk              (clk       ),
      .reset_n          (reset_n   ),
      .valid_in         (valid_in  ),
      .ready_in         (ready_in  ),
      .valid_out        (valid_out ), 
      .ready_out        (ready_out ), 
      
      .byte_out         (byte_out  ),
      .endtoken_i       (endtoken_i),
      .endtoken_o       (endtoken_o),
      
      .huf              (huf       ),
      .huf_len          (huf_len   ),
      .symbol           (symbol    ),
      .symbol_len       (symbol_len),
      .eob              (eob       )   
   );
      logic [2:0] state;
      assign state          = dut.state;
      logic [38:0] buffer;
      logic [7:0]  buffer_len;
      logic [7:0]  buffer_len_next;
      assign buffer          = dut.buffer;
      assign buffer_len      = dut.buffer_len;
      assign buffer_len_next = dut.buffer_len_next;
      
      integer delay_count;
    initial 
    begin
       //-------------------------------------
       // Initialization
       //-------------------------------------
       reset_n     = 0;
       valid_in    = 0;
       ready_out   = 1;
       endtoken_i  = 0;       
       //-------------------------------------
       // Reset
       //-------------------------------------
       repeat(5) @(posedge clk);
       reset_n = 1;
       //-------------------------------------
       // send_block_and_receive 
       //-------------------------------------
//       // 1st case 1-2-1: IDLE->APpend->IDLE
//       send_symbol(
//       16'b0000000000000011,2,
//       16'b0000000000000001,2,
//       0,
//       0);// total len 4
//       send_symbol(
//       16'b0000000000000000,2,
//       16'b0000000000000001,1,
//       0,
//       0);// total len 3
//       send_symbol(
//       16'b0000000000000000,2,
//       16'b0000000000000001,1,
//       1,
//       0);// total len 7
         /////////////////////////////////////////////////////////
//       // 2nd test case 1-3-4: len > 7
//       send_symbol(
//       16'b0000000000010101,5,
//       16'b0000000000011101,5,
//       0,
//       0);// total len 10
        /////////////////////////////////////////////////////////
        // 3rd case 1-3-4-5-4-7 Byte->Out->Byte->Out
//       send_symbol(
//       16'b1111111100000000,16,
//       16'b0000000000000000, 0,
//       1,
//       0);// total len 20
//       send_symbol(
//       16'b1111111100000000,16,
//       16'b0011111100000001,14,
//       0,
//       0);// total len 30
         /////////////////////////////////////////////////////////
         // 4th input < 8 + END + "newlen = 0"
//       send_symbol(
//       16'b0000000000000011,2,
//       16'b0000000000000001,2,
//       0,
//       0);// total len 4
//       send_symbol(
//       16'b0000000000000000,2,
//       16'b0000000000000001,1,
//       0,
//       0);// total len 3
//       send_symbol(
//       16'b0000000000000000,2,
//       16'b0000000000000001,1,
//       1,
//       0);// total len 7
//       send_symbol(
//       16'b0000000000000000,0,
//       16'b0000000000000000,0,
//       0,
//       1);// total len 0 + END
         /////////////////////////////////////////////////////////
         // 5th case buffer > 7 + END 1 3 4 6
//       send_symbol(
//       16'b0000000000010101,5,
//       16'b0000000000011101,5,
//       0,
//       1);// total len 10        
       /////////////////////////////////////////////////////////
       // 6th case buffer > 7 + END + OuTLoop 1 3 4 5 4 6   
//       send_symbol(
//       16'b1111111100000000,16,
//       16'b0000000000000000, 0,
//       1,
//       1);// total len 20       
       /////////////////////////////////////////////////////////
       // 7th case buffer = 8 + END 
//       send_symbol(
//       16'b0000000011111111,8,
//       16'b0000000000000000, 0,
//       0,
//       1);// total len 8  
       /////////////////////////////////////////////////////////
       // 8th case buffer = 8 + END + Outloop
//       send_symbol(
//       16'b1111111111101101,16,
//       16'b0000000000000000, 0,
//       0,
//       1);// total len 16      
       //-------------------------------------
       // consume OUTPUT
       //-------------------------------------
       forever 
       begin
          @(posedge clk);

          if (valid_out)
          begin
            if (delay_count > 0)
            begin
                // keep backpressure
                ready_out   = 0;
                delay_count = delay_count - 1;
            end
            else
            begin
                // one-cycle handshake pulse
                ready_out = 1;

                // next random waiting time
                delay_count = $urandom_range(1,10);

            end
          end
          else
          begin
             ready_out <= 0;
          end
       end
    end
    //////////////////////////////////////////////////
    task automatic send_symbol
    (
       input [15:0] h,
       input [7:0]  h_len,
       input [15:0] s,
       input [7:0]  s_len,
       input        eob_i,
       input        endtoken
    );
    
       //-------------------------------------
       // Load input block
       //-------------------------------------
       @(posedge clk);

       while(!ready_in)
          @(posedge clk);
       huf        = h;
       huf_len    = h_len;
       symbol     = s;
       symbol_len = s_len;
       eob        = eob_i;
       endtoken_i = endtoken;
       
       //-------------------------------------
       // Send data
       //-------------------------------------
       valid_in   = 1;
       @(posedge clk);
       valid_in = 0;
    endtask
    
endmodule
