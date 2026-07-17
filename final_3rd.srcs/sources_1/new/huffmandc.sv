`timescale 1ns / 1ps

module huf (
    input  logic               clk,
    input  logic               reset_n,   // Active-low reset
    
    input  logic               valid_in,  // Valid input data (replaces start)
    output logic               ready_in,  // Ready to accept input
    
    input  logic signed [15:0] Y [0:63],
    
    output logic               valid_out, // Valid output data (replaces ack)
    input  logic               ready_out, // Ready to accept output
    
    input  logic                endtoken_i,
    output logic                endtoken_o,
    
    output logic [15:0]        huf,
    output logic [7:0]         huf_len,
    output logic [15:0]        symbol,
    output logic [7:0]         symbol_len,
    output logic               eob
);
(* rom_style = "distributed" *)
localparam logic [8:0] HUFF_LEN_DC [0:11]  = '{2,3,3,3,3,3,4,5,6,7,8,9};
(* rom_style = "distributed" *)
localparam logic [8:0] HUFF_CODE_DC [0:11] = '{
        9'b00,           // 0
        9'b010,          // 1
        9'b011,          // 2
        9'b100,          // 3
        9'b101,          // 4
        9'b110,          // 5
        9'b1110,         // 6
        9'b11110,        // 7
        9'b111110,       // 8
        9'b1111110,      // 9
        9'b11111110,     // 10
        9'b111111110     // 11
    }; 
(* rom_style = "distributed" *)
localparam  logic [15:0] ZRL  = 16'b11111111001 ;
(* rom_style = "distributed" *)
localparam  logic [7:0]  HUFF_LEN_AC [0:159] = '{
    8'd2,
    8'd2,    
    8'd3,
    8'd4,
    8'd5, 
    8'd7,
    8'd8,    
    8'd10,
    8'd16,
    8'd16,   
    8'd4,
    8'd5,
    8'd7,
    8'd9,    
    8'd11,
    8'd16,
    8'd16,
    8'd16,
    8'd16,
    8'd16,   
    8'd5,
    8'd8,    
    8'd10,
    8'd12,
    8'd16,
    8'd16,
    8'd16,
    8'd16,
    8'd16,
    8'd16,    
    8'd6,
    8'd9,   
    8'd12,
    8'd16,
    8'd16,
    8'd16,
    8'd16,
    8'd16,
    8'd16,
    8'd16,
    8'd6,
    8'd10,   
    8'd16,   
    8'd16,   
    8'd16,   
    8'd16,   
    8'd16,   
    8'd16,  
    8'd16,   
    8'd16,
    8'd7,
    8'd11,
    8'd16,
    8'd16,
    8'd16,
    8'd16,
    8'd16,
    8'd16,
    8'd16,
    8'd16,
    8'd7,
    8'd12,
    8'd16,
    8'd16,
    8'd16,
    8'd16,
    8'd16,
    8'd16,
    8'd16,
    8'd16,
    8'd8,
    8'd12,
    8'd16,
    8'd16,
    8'd16,
    8'd16,
    8'd16,
    8'd16,
    8'd16,
    8'd16,  
    8'd9,
    8'd15,
    8'd16,
    8'd16,
    8'd16,
    8'd16,
    8'd16,
    8'd16,
    8'd16,
    8'd16,
    8'd9,
    8'd16,
    8'd16,
    8'd16,
    8'd16,
    8'd16,
    8'd16,
    8'd16,
    8'd16,
    8'd16,    
    8'd9,   
    8'd16,
    8'd16,
    8'd16,
    8'd16,
    8'd16,
    8'd16,
    8'd16,
    8'd16,
    8'd16,
    8'd10,
    8'd16,
    8'd16,
    8'd16,
    8'd16,
    8'd16,
    8'd16,
    8'd16,
    8'd16,
    8'd16,
    8'd10,
    8'd16,
    8'd16,
    8'd16,
    8'd16,
    8'd16,
    8'd16,
    8'd16,
    8'd16,
    8'd16,
    8'd11,
    8'd16,
    8'd16,
    8'd16,
    8'd16,
    8'd16,
    8'd16,
    8'd16,
    8'd16,
    8'd16,
    8'd16,
    8'd16,
    8'd16,
    8'd16,
    8'd16,
    8'd16,
    8'd16,
    8'd16,
    8'd16,
    8'd16,
    8'd16,
    8'd16,
    8'd16,
    8'd16,
    8'd16,
    8'd16,
    8'd16,
    8'd16,
    8'd16,
    8'd16
};
(* rom_style = "distributed" *)
localparam logic [15:0] HUFF_CODE_AC [0:159] = '{
16'b00               ,16'b01               ,16'b100               ,16'b1011             ,16'b11010            ,16'b1111000          ,16'b11111000         ,16'b1111110110       ,16'b1111111110000010 ,16'b1111111110000011,
16'b1100             ,16'b11011            ,16'b1111001          ,16'b111110110        ,16'b11111110110      ,16'b1111111110000100 ,16'b1111111110000101 ,16'b1111111110000110 ,16'b1111111110000111 ,16'b1111111110001000,
16'b11100            ,16'b11111001         ,16'b1111110111       ,16'b111111110100     ,16'b1111111110001001 ,16'b1111111110001010 ,16'b1111111110001011 ,16'b1111111110001100 ,16'b1111111110001101 ,16'b1111111110001110,
16'b111010           ,16'b111110111        ,16'b111111110101     ,16'b1111111110001111 ,16'b1111111110010000 ,16'b1111111110010001 ,16'b1111111110010010 ,16'b1111111110010011 ,16'b1111111110010100 ,16'b1111111110010101,
16'b111011           ,16'b1111111000       ,16'b1111111110010110 ,16'b1111111110010111 ,16'b1111111110011000 ,16'b1111111110011001 ,16'b1111111110011010 ,16'b1111111110011011 ,16'b1111111110011100 ,16'b1111111110011101,
16'b1111010          ,16'b11111110111      ,16'b1111111110011110 ,16'b1111111110011111 ,16'b1111111110100000 ,16'b1111111110100001 ,16'b1111111110100010 ,16'b1111111110100011 ,16'b1111111110100100 ,16'b1111111110100101,
16'b1111011          ,16'b111111110110     ,16'b1111111110100110 ,16'b1111111110100111 ,16'b1111111110101000 ,16'b1111111110101001 ,16'b1111111110101010 ,16'b1111111110101011 ,16'b1111111110101100 ,16'b1111111110101101,
16'b11111010         ,16'b111111110111     ,16'b1111111110101110 ,16'b1111111110101111 ,16'b1111111110110000 ,16'b1111111110110001 ,16'b1111111110110010 ,16'b1111111110110011 ,16'b1111111110110100 ,16'b1111111110110101,
16'b111111000        ,16'b111111111000000  ,16'b1111111110110110 ,16'b1111111110110111 ,16'b1111111110111000 ,16'b1111111110111001 ,16'b1111111110111010 ,16'b1111111110111011 ,16'b1111111110111100 ,16'b1111111110111101,
16'b111111001        ,16'b1111111110111110 ,16'b1111111110111111 ,16'b1111111111000000 ,16'b1111111111000000 ,16'b1111111111000010 ,16'b1111111111000011 ,16'b1111111111000100 ,16'b1111111111000101 ,16'b1111111111000110,
16'b111111010        ,16'b1111111111000111 ,16'b1111111111001000 ,16'b1111111111001001 ,16'b1111111111001010 ,16'b1111111111001011 ,16'b1111111111001100 ,16'b1111111111001101 ,16'b1111111111001110 ,16'b1111111111001111,
16'b1111111001       ,16'b1111111111010000 ,16'b1111111111010001 ,16'b1111111111010010 ,16'b1111111111010011 ,16'b1111111111010100 ,16'b1111111111010101 ,16'b1111111111010110 ,16'b1111111111010111 ,16'b1111111111011000,
16'b1111111010       ,16'b1111111111011001 ,16'b1111111111011010 ,16'b1111111111011011 ,16'b1111111111011100 ,16'b1111111111011101 ,16'b1111111111011110 ,16'b1111111111011111 ,16'b1111111111100000 ,16'b1111111111100001,
16'b11111111000      ,16'b1111111111100010 ,16'b1111111111100011 ,16'b1111111111100100 ,16'b1111111111100101 ,16'b1111111111100110 ,16'b1111111111100111 ,16'b1111111111101000 ,16'b1111111111101001 ,16'b1111111111101010,
16'b1111111111101011 ,16'b1111111111101100 ,16'b1111111111101101 ,16'b1111111111101110 ,16'b1111111111101111 ,16'b1111111111110000 ,16'b1111111111110001 ,16'b1111111111110010 ,16'b1111111111110011 ,16'b1111111111110100,
16'b1111111111110101 ,16'b1111111111110110 ,16'b1111111111110111 ,16'b1111111111111000 ,16'b1111111111111001 ,16'b1111111111111010 ,16'b1111111111111011 ,16'b1111111111111100 ,16'b1111111111111101 ,16'b1111111111111110
}; 
    // Internal registers
    logic signed [15:0] abs_val;
    logic [4:0]         size_val;
    
    logic [15:0]        huf_idx;
    logic [4:0]         ac_symbol_len;
    logic signed [15:0] ac_symbol;
    
    logic signed [15:0] Y_diff;
    logic signed [15:0] Y_predc;
    
    logic [5:0]         zerorun;
    logic [5:0]         zrl_counter;
    logic [7:0]         zerorun_remain;
    
    logic               coeff_is_zero;
    logic               zrl_flag; 
    logic               ac_start_flag1; //ac = 1 and dc = 0
    logic               endtoken_r;
    //to determine S_LOOKUP (zrl) -> S_OUT -> S_LOOKUP(symbol) -> S_OUT -> S_AC
    // use in S_OUT to back to S_LOOKUP
    logic signed [15:0] Y_reg [0:63];
    logic [5:0]         idx;
    logic signed [15:0] coeff;     
    
    logic [2:0]         dc_counter,ac_counter;
    // FSM states
    typedef enum logic [1:0] {
        S_IDLE       = 2'b00 ,
        S_DC         = 2'b01 , 
        S_AC         = 2'b10 ,  
        S_OUT        = 2'b11   
    } state_t;

    state_t state, next_state;
    // -------------------------
    // FSM next state logic
    // -------------------------
    always_comb 
    begin
        next_state = state;// default to avoid latch
        case (state)
            S_IDLE: 
            begin
               if (valid_in && ready_in)
                  next_state = S_DC;
            end
            
            S_DC:
            begin
               if (dc_counter == 4)
                  next_state = S_OUT;
            end

            S_AC: 
            begin
               // coeff!=0 or counter reach eob
//               if (!coeff_is_zero || counter == 63)
               if (ac_counter == 5)
                  next_state = S_OUT;
            end
            
            S_OUT: 
            begin
               if (valid_out && ready_out)
               begin
                  if (eob == 0)
                     next_state = S_AC;
                  else if (eob == 1'b1)
                     next_state = S_IDLE;
               end
            end
            default: next_state = S_IDLE;
        endcase
    end
      
    assign valid_out = (state == S_OUT);
    assign ready_in  = (state == S_IDLE);
    // ------------------------------------------------------------------
    // Store OUTPUT after compute
    // ------------------------------------------------------------------
    
    always_ff @(posedge clk) 
    begin
       if (valid_in && ready_in) 
       begin
          for (int i=0; i<64; i++)
          begin
             Y_reg[i] <= Y[i];  
          end
       end
    end
    
    // Assign coeff register 
    always_ff @(posedge clk )
    begin
       coeff     <= Y_reg[idx];
    end

    always_ff @(posedge clk )
    begin
       coeff_is_zero <= (coeff == '0);
    end 
    
    // Assign Y_diff register 
    always_ff @(posedge clk )
    begin
       Y_diff     <= coeff - Y_predc;
    end
    
    // Assign abs_val
    always_ff @(posedge clk )
    begin
       if (ac_start_flag1 == 1'b0)
          abs_val      <= (Y_diff < 0)? -Y_diff : Y_diff;   
       else
          abs_val      <= (coeff < 0)? -coeff : coeff;  
    end
    
   // Assign size_val for S_DC register 
    always_ff @(posedge clk )
    begin
       if      (abs_val == 0)    size_val <= 4'd0;
       else if (abs_val <= 1)    size_val <= 4'd1;
       else if (abs_val <= 3)    size_val <= 4'd2;
       else if (abs_val <= 7)    size_val <= 4'd3;
       else if (abs_val <= 15)   size_val <= 4'd4;
       else if (abs_val <= 31)   size_val <= 4'd5;
       else if (abs_val <= 63)   size_val <= 4'd6;
       else if (abs_val <= 127)  size_val <= 4'd7;
       else if (abs_val <= 255)  size_val <= 4'd8;
       else if (abs_val <= 511)  size_val <= 4'd9;
       else if (abs_val <= 1023) size_val <= 4'd10;
       else                      size_val <= 4'd11;  
    end
    
    // Assign ac_symbol huf_idx for S_AC register
    always_ff @(posedge clk)
    begin
       zerorun_remain <= zerorun[3:0];
    end
    
    always_ff @(posedge clk)
    begin
       if (size_val != 0)
       begin
          huf_idx       <= zerorun_remain * 10 + size_val - 1;
          ac_symbol     <= (coeff >= 0) ? abs_val : (~abs_val);
          ac_symbol_len <= size_val;
       end   
       else
       begin
          huf_idx       <= '0;
          ac_symbol     <= '0;
          ac_symbol_len <= '0;
       end
    end
    
    // -----------------------------------------------------------------
    // assign ZRL_COUNTER base on zerorun
    // -----------------------------------------------------------------
    always_comb
    begin
       zrl_counter = '0;
       if      (!coeff_is_zero && zerorun >= 16 && zerorun <= 31) zrl_counter = 1;
       else if (!coeff_is_zero && zerorun >= 32 && zerorun <= 47) zrl_counter = 2;
       else if (!coeff_is_zero && zerorun >= 48)                  zrl_counter = 3;       
    end    
    
    always_ff @(posedge clk)
    begin
       if (ac_counter == 4)
       begin
          if (zrl_counter == '0)
             zrl_flag <= 0;
          else
             zrl_flag <= 1;
        end
        else 
           zrl_flag <= zrl_flag;
    end   
    // -----------------------------------------------------------------
     always_ff @(posedge clk)
     begin
        if (ac_start_flag1 == 1'b0)
        begin
           //----------------------------------------
           // HUF; HUF_LEN; SYMBOL; SYMBOL_LEN output DC
           //----------------------------------------
           huf        <= HUFF_CODE_DC[ size_val ];               
           huf_len    <= HUFF_LEN_DC [ size_val ];               
           symbol     <= (Y_diff>=0)? Y_diff : (Y_diff - 1'b1);  
           symbol_len <= size_val;
        end
        
        else if (ac_start_flag1 == 1'b1) 
        begin 
           if (zrl_flag == 0)
           begin 
              if (ac_symbol_len != '0)
              begin
                 huf        <= HUFF_CODE_AC[ huf_idx ];              
                 huf_len    <= HUFF_LEN_AC [ huf_idx ];
              end
              
              else 
              begin
                 huf        <= '0;            
                 huf_len    <= '0; 
              end
              
              symbol     <= ac_symbol; 
              symbol_len <= ac_symbol_len;
              
           end
           
           else if (zrl_flag == 1)
           begin
           //RUN ONLY ZRL 
              huf        <= ZRL;         
              huf_len    <= 11;          
              symbol     <= '0; 
              symbol_len <= '0;   
           end
        end
     end
    
    
    
    always_ff @(posedge clk ) 
    begin
        if (!reset_n) 
        begin 
           state          <= S_IDLE;
           Y_predc        <= '0;
           idx            <= 6'd0;
           eob            <= '0;
           endtoken_o     <= '0;
           dc_counter     <= '0;
           ac_counter     <= '0;
           zerorun        <= '0;
           ac_start_flag1 <= 0;
           endtoken_r     <= 0;
        end 
        else 
        begin
           state <= next_state;
           case (state)
              S_IDLE: 
              begin
                 ac_start_flag1 <= 0;
                 eob            <= '0;
                 idx            <= 6'd0;
                 dc_counter     <= '0;
                 ac_counter     <= '0;
                 endtoken_r     <= endtoken_i;
              end
              S_DC:
              begin
                 dc_counter  <= dc_counter + 1;
              end
              S_AC:
              begin
                 Y_predc   <= Y_reg[0]; 
                 ac_start_flag1 <= 1;
                 
                 if (ac_counter < 5)
                 begin
                    if (idx < 63 && ac_counter == 3 && coeff_is_zero == 1)
                       ac_counter <= '0;
                    else
                       ac_counter <= ac_counter + 1;
                 end
                 
                 if (idx < 63 && ac_counter == 0)
                    idx <= idx + 1'b1;
                 
                 if (coeff_is_zero && ac_counter == 3)
                    zerorun <= zerorun + 1;   
                    
                    
                 if (idx == 63 && ac_counter == 5 && zrl_flag == 1'b0)
                 begin
                    eob        <= 1;
                    endtoken_o <= endtoken_r;
                 end 
              end
              S_OUT:
              begin
                 if (ready_out && zrl_flag == 1'b0)
                 begin
                    zerorun <= '0;//S_OUT output ac_symbol then back to S_AC  
                    ac_counter <= 0;
                 end
                 else if (ready_out && zrl_flag == 1'b1)
                 begin
                    zerorun <= zerorun - 16;//S_OUT output ZRL then back to S_LOOKUP
                    ac_counter <= 4;
                 end
              end
           endcase
        end
    end

endmodule

//    // Internal registers
//    logic signed [15:0] abs_val;
//    logic [4:0]         size_val;
//    logic signed [15:0] mag_val;
    
//    logic [15:0]        huf_idx;
//    logic [4:0]         ac_symbol_len;
//    logic signed [15:0] ac_symbol;
      
//    logic signed [15:0] Y_diff;
//    logic signed [15:0] Y_predc;
//    logic signed [15:0] dc_symbol;
//    logic [4:0]         dc_category;
    
//    logic [5:0]         zerorun;
//    logic [5:0]         zrl_counter;
//    logic [7:0]         zerorun_remain;
    
//    logic               coeff_is_zero;
//    logic               zrl_flag; 
//    logic               acdc_flag; //ac = 1 and dc = 0
//    //to determine S_LOOKUP (zrl) -> S_OUT -> S_LOOKUP(symbol) -> S_OUT -> S_AC
//    // use in S_OUT to back to S_LOOKUP
//    logic signed [15:0] Y_reg [0:63];
//    logic [5:0]         counter;
//    logic signed [15:0] coeff;     
    
//    // FSM states
//    typedef enum logic [2:0] {
//        S_IDLE  = 3'b000  ,
//        S_DC    = 3'b001  ,  
//        S_AC    = 3'b010  ,  
//        S_LOOKUP= 3'b011  ,
//        S_OUT   = 3'b100  
//    } state_t;

//    state_t state, next_state;
//    // ------------------------------------------------------------------
//    // Combinational Logic
//    // ------------------------------------------------------------------   
//    assign coeff         = Y_reg[counter];
//    assign coeff_is_zero = (coeff == 0);// if coeff==0 then coeffiszero = 1
//    assign Y_diff        = Y_reg[0] - Y_predc;
                           
//    assign mag_val       = (state == S_DC) 
//                           ? Y_diff
//                           : coeff;
//    assign abs_val       = (mag_val < 0) 
//                           ? -mag_val 
//                           : mag_val;   
//    // -----------------------------------------------------------------
//    // count ZERORUN 
//    // -----------------------------------------------------------------
//    always_ff @(posedge clk)
//    begin
//       if (!reset_n || state == S_IDLE)
//          zerorun <= '0;
//       else if (state == S_AC && coeff_is_zero)
//          zerorun <= zerorun + 1;
//       else if (state == S_OUT && ready_out && zrl_flag == 1'b0)
//          zerorun <= '0;//S_OUT output ac_symbol then back to S_AC  
//       else if (state == S_OUT && ready_out && zrl_flag == 1'b1)
//          zerorun <= zerorun - 16;//S_OUT output ZRL then back to S_LOOKUP     
//    end
    
//    // -----------------------------------------------------------------
//    // assign ZRL_COUNTER base on zerorun
//    // -----------------------------------------------------------------
//    always_comb
//    begin
//       zrl_counter = '0;
//       if      (ac_symbol != 0 && zerorun >= 16 && zerorun <= 31) zrl_counter = 1;
//       else if (ac_symbol != 0 && zerorun >= 32 && zerorun <= 47) zrl_counter = 2;
//       else if (ac_symbol != 0 && zerorun >= 48)                  zrl_counter = 3;       
//    end    
//    // ------------------------------------------------------------------
//    // Compute SIZE_VAL for SYMBOL
//    // ------------------------------------------------------------------                    
//    always_comb 
//    begin
//       size_val = '0;
//       if      (abs_val == 0)    size_val = 4'd0;
//       else if (abs_val <= 1)    size_val = 4'd1;
//       else if (abs_val <= 3)    size_val = 4'd2;
//       else if (abs_val <= 7)    size_val = 4'd3;
//       else if (abs_val <= 15)   size_val = 4'd4;
//       else if (abs_val <= 31)   size_val = 4'd5;
//       else if (abs_val <= 63)   size_val = 4'd6;
//       else if (abs_val <= 127)  size_val = 4'd7;
//       else if (abs_val <= 255)  size_val = 4'd8;
//       else if (abs_val <= 511)  size_val = 4'd9;
//       else if (abs_val <= 1023) size_val = 4'd10;
//       else                      size_val = 4'd11;
//    end
    
//    // ------------------------------------------------------------------
//    // Compute INDEX for LOOKUP
//    // ------------------------------------------------------------------
    
//    assign zerorun_remain = zerorun[3:0];
    
//    // -------------------------
//    // FSM next state logic
//    // -------------------------
//    always_comb 
//    begin
//        next_state = state;// default to avoid latch
//        case (state)
//            S_IDLE: 
//            begin
//               if (valid_in && ready_in)
//                  next_state = S_DC;
//            end
//            S_DC: 
//            begin
//               next_state = S_LOOKUP;
//            end
//            S_AC: 
//            begin
//               // coeff!=0 or counter reach eob
//               if (!coeff_is_zero || counter == 63)
//                  next_state = S_LOOKUP;
//            end
//            S_LOOKUP:
//            begin
//               next_state = S_OUT;
//            end
//            S_OUT: 
//            begin
//               if (valid_out && ready_out)
//               begin
//                  if (eob == 0)
//                  begin
//                     if (zrl_flag == 1'b0)
//                     begin     
//                        next_state = S_AC; //CORRECT
//                     end
//                  // After output ZRL, prepare to output symbol
//                  else if (zrl_flag == 1'b1)
//                  begin 
//                     next_state = S_LOOKUP; 
//                  end
//               end
                  
//               else if (eob == 1'b1)
//                  next_state = S_IDLE;
//               end
//            end
//            default: next_state = S_IDLE;
//        endcase
//    end
//    assign valid_out = (state == S_OUT);
//    assign ready_in  = (state == S_IDLE);
//    // ------------------------------------------------------------------
//    // Store OUTPUT after compute
//    // ------------------------------------------------------------------
    
//    always_ff @(posedge clk) 
//    begin
//       if (valid_in && ready_in) 
//       begin
//          for (int i=0; i<64; i++)
//          begin
//             Y_reg[i] <= Y[i];  
//          end
//       end
//    end
    
//    always_ff @(posedge clk)
//    begin
//       if (state == S_DC)
//       begin
//          dc_category <= size_val;
//          dc_symbol   <= (Y_diff>=0)? Y_diff : (Y_diff - 1'b1);
//       end
//    end
    
//    always_ff @(posedge clk)
//    begin
//       if (state == S_AC)
//       begin
//          if (size_val != 0)
//          begin
//             huf_idx       <= zerorun_remain * 10 + size_val - 1;
//             ac_symbol     <= (coeff >= 0) ? abs_val : (~abs_val);
//             ac_symbol_len <= size_val;
//          end   
//          else
//          begin
//             huf_idx       <= '0;
//             ac_symbol     <= '0;
//             ac_symbol_len <= '0;
//          end
//       end
//    end
    
//     always_ff @(posedge clk)
//     begin
//        if (state == S_LOOKUP)
//        begin
//           if (acdc_flag == 1'b0)
//           begin
//              //----------------------------------------
//              // HUF; HUF_LEN; SYMBOL; SYMBOL_LEN output
//              //----------------------------------------
//              huf        <= HUFF_CODE_DC[ dc_category ];               
//              huf_len    <= HUFF_LEN_DC [ dc_category ];               
//              symbol     <= dc_symbol;  
//              symbol_len <= dc_category;
//           end
           
//           else if (acdc_flag == 1'b1) 
//           begin 
//              if (zrl_counter == '0)
//              begin //RUN AC SYMBOL
//                 //----------------------------------------
//                 // HUF and HUF_LEN output
//                 //----------------------------------------
//                 if (ac_symbol_len != '0)
//                 begin
//                    huf        <= HUFF_CODE_AC[ huf_idx ];              
//                    huf_len    <= HUFF_LEN_AC [ huf_idx ];
//                 end
                 
//                 else // if (ac_symbol_len == '0)
//                 begin
//                    huf        <= '0;            
//                    huf_len    <= '0; 
//                 end
//                 //----------------------------------------
//                 // SYMBOL and SYMBOL_LEN output
//                 //----------------------------------------
//                 symbol     <= ac_symbol; 
//                 symbol_len <= ac_symbol_len;
//              end
//              //----------------------------------------
//              // ZRL output
//              //----------------------------------------
//              else if (zrl_counter != '0)
//              begin
//              //RUN ONLY ZRL 
//                 huf        <= ZRL;         
//                 huf_len    <= 11;          
//                 symbol     <= '0; 
//                 symbol_len <= '0;   
//              end
//           end
//        end
//     end
     
//    always_ff @(posedge clk ) 
//    begin
//        if (!reset_n) 
//        begin 
//           acdc_flag  <= '0;
//           state      <= S_IDLE;
//           Y_predc    <= '0;
//           counter    <= 6'd0;
//           eob        <= '0;
//           endtoken_o <= '0;
//           zrl_flag   <= '0;
//        end 
//        else 
//        begin
//           state <= next_state;
//           case (state)
//              S_IDLE: 
//              begin
//                 acdc_flag <= '0;
//                 eob <= '0;
//                 counter <= 6'd1;
//              end
//              S_DC:
//              begin
//                 Y_predc     <= Y_reg[0];
//              end
//              S_AC:
//              begin
//                 acdc_flag <= 1'b1;
//                 if (counter < 63)
//                    counter  <= counter + 1'b1;
//                 zrl_flag <= '0;
//              end 
//              S_LOOKUP:
//              begin  
//                 if (acdc_flag == 1'b1) 
//                 begin 
//                    if (zrl_counter == '0)
//                    begin //RUN AC SYMBOL
//                       zrl_flag   <= 1'b0;
//                       //----------------------------------------
//                       // EOB output
//                       //----------------------------------------
//                       eob        <= (counter == 63);// && (zrl_counter == 0) ;
//                       //----------------------------------------
//                       // ENDTOKEN_O output
//                       //----------------------------------------
//                       endtoken_o <= (counter == 63) && endtoken_i;
//                    end
//                    //----------------------------------------
//                    // ZRL output
//                    //----------------------------------------
//                    else if (zrl_counter != '0)
//                    begin
//                    //RUN ONLY ZRL 
//                       zrl_flag   <= 1'b1;
//                    end
//                 end
//              end
//              S_OUT:
//              begin
                 
//              end
//           endcase
//        end
//    end

//endmodule