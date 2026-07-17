`timescale 1ns / 1ps

module design_3rd(
   input logic clk,
   input logic reset,  
   output logic [7:0] byte_out,
   output logic valid_out
);
//-----------------------------------

logic [15:0] width, len;
logic [23:0] pixelnum;
logic        valid01;

logic        reset_n;
assign reset_n = ~reset;

jpeg_meta_data jpeg_meta_data(
   .clk       (clk      ),
   .reset_n   (reset_n  ),
   
   .valid_out (valid01),
   
   .width     (width    ),
   .len       (len      ),
   .pixelnum  (pixelnum )
);

//-----------------------------------
logic valid12, ready12;
logic [7:0]  R,G,B;
logic endtoken1,endtoken2,endtoken3
,endtoken4,endtoken5,endtoken6,endtoken7;

BRAM_pixel dut1(
   .clk       (clk      ),
   .reset_n   (reset_n  ),
   
   .valid_in  (valid01  ),
   
   .pixelnum  (pixelnum ),
                 
   .valid_out (valid12  ),
   .ready_out (ready12  ),
   
   .R         (R        ), 
   .G         (G        ), 
   .B         (B        ),
   .endtoken  (endtoken1)
);


//-----------------------------------
logic valid23, ready23;
logic signed [15:0] Y [0:63];

rgb2y dut2 (
    .clk       (clk      ),
    .reset_n   (reset_n  ),
                         
    .valid_in  (valid12 ),
    .ready_in  (ready12 ),
    .R         (R ),
    .G         (G ),
    .B         (B ),
    .endtoken_i(endtoken1),
    
    .endtoken_o(endtoken2 )  ,
    .valid_out (valid23 )  ,
    .ready_out (ready23 )  ,
    .Y         (Y )
);
//-----------------------------------
logic valid34, ready34;
logic signed [15:0] Y_dct1d [0:63];

dct1d dut3 (
    .clk        (clk      ),
    .reset_n    (reset_n  ),   // Active-low reset
    
    .valid_in   (valid23  ),  // Valid input data (replaces start)
    .ready_in   (ready23  ),  // Ready to accept input
    
    .endtoken_i (endtoken2),
    .endtoken_o (endtoken3),
  
    .Y          (Y       ),
    .valid_out  (valid34 ), // Valid output data (replaces ack)
    .ready_out  (ready34 ), // Ready to accept output
    .Y_dct      (Y_dct1d   )
);

//-----------------------------------
logic signed [15:0] Y_dct2d [0:63];
logic valid45, ready45;

dct1d dut4 (
    .clk        (clk      ),
    .reset_n    (reset_n  ),   // Active-low reset
    
    .valid_in   (valid34      ),  // Valid input data (replaces start)
    .ready_in   (ready34  ),  // Ready to accept input
    
    .endtoken_i (endtoken3      ),
    .endtoken_o (endtoken4  ),
   
    .Y          (Y_dct1d      ),
    .valid_out  (valid45  ), // Valid output data (replaces ack)
    .ready_out  (ready45  ), // Ready to accept output
    .Y_dct      (Y_dct2d  )
);
//-----------------------------------
logic valid56, ready56;
logic signed [15:0] Y_quant [0:63];

quantization dut5 (
   .clk        (clk      ),
   .reset_n    (reset_n  ),  // Active-low reset
   
   .valid_in   (valid45  ),  // Valid input data (replaces start)
   .ready_in   (ready45  ),  // Ready to accept input
 
   .endtoken_i (endtoken4  ),
   .endtoken_o (endtoken5  ),
 
   .Y          (Y_dct2d  ),
   .valid_out  (valid56  ), // Valid output data (replaces ack)
   .ready_out  (ready56  ), // Ready to accept output
   .Y_out      (Y_quant  ) 
);
//-----------------------------------
logic valid67, ready67;
logic [15:0] huf, symbol;
logic [7:0]  huf_len, symbol_len; 
logic eob;
huf dut6 (
    .clk         (clk        ),
    .reset_n     (reset_n    ), // Active-low reset
   
    .valid_in    (valid56    ), // Valid input data (replaces start)
    .ready_in    (ready56    ), // Ready to accept input
   
    .Y           (Y_quant    ),
   
    .valid_out   (valid67    ), // Valid output data (replaces ack)
    .ready_out   (ready67    ), // Ready to accept output
   
    .endtoken_i  (endtoken5 ),
    .endtoken_o  (endtoken6 ),
   
    .huf         (huf        ),
    .huf_len     (huf_len    ),
    .symbol      (symbol     ),
    .symbol_len  (symbol_len ),
    .eob         (eob        )
);
//-----------------------------------
logic valid78, ready78;
logic [7:0]  byte_7;
Bit2Byte dut7 (
    .clk        (clk       ),
    .reset_n    (reset_n   ),
   
    .valid_in   (valid67   ),
    .ready_in   (ready67   ),
   
    .endtoken_i (endtoken6),
    .endtoken_o (endtoken7),
                 
    .huf        (huf       ),
    .huf_len    (huf_len   ),
    .symbol     (symbol    ),
    .symbol_len (symbol_len),
    .eob        (eob       ),
   
    .byte_out   (byte_7  ),
   
    .valid_out  (valid78  ),
    .ready_out  (ready78  )
);
//-----------------------------------
logic [7:0] byte_final;  
logic valid_out_final;        
HEADER_STUFF_FLUSH dut8 (
   .clk             (clk            ),
   .reset_n         (reset_n        ),
 
   .valid_in        (valid78        ),
   .ready_in        (ready78        ),
 
   .width           (width          ),
   .len             (len            ),
   .widlen_valid_in (valid01        ),
 
   .endtoken_i      (endtoken7      ),
   .byte_in         (byte_7         ),
   .byte_out        (byte_final     ),
   .valid_out       (valid_out_final)
);

assign byte_out = byte_final;
assign valid_out = valid_out_final;

endmodule
