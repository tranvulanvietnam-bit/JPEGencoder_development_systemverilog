`timescale 1ns / 1ps

module Bit2Byte(
    input  logic        clk,
    input  logic        reset_n,
    
    input  logic        valid_in,
    output logic        ready_in,
    
    input  logic        endtoken_i,
    
    input  logic [15:0] huf,
    input  logic [7:0]  huf_len,
    input  logic [15:0] symbol,
    input  logic [7:0]  symbol_len,
    input  logic        eob,
    
    output logic [7:0]  byte_out,
    output logic        endtoken_o,
    
    output logic        valid_out,
    input logic         ready_out
);
  /*============================================================
    Parameters / Types
  ============================================================*/
  typedef enum logic [2:0] {
     S_IDLE,
     S_APPEND,
     S_BYTE,
     S_OUT,
     S_END
  } state_t;
  /*============================================================
    Registers
  ============================================================*/
  state_t state, next_state;
  
  logic [31:0] new_bits;
  logic [7:0]  new_len;
  logic [2:0]  eob_len;
  
  logic [38:0] buffer;
  logic [7:0]  buffer_len;
  logic [7:0]  buffer_len_next;
  
  logic [7:0]  byte_r;
  logic        endtoken_r;
  
  logic [15:0] huf_r;        
  logic [7:0]  huf_len_r;
  logic [15:0] symbol_r;     
  logic [7:0]  symbol_len_r;
  logic        eob_r;
  //--------------------------------------------------
  // calculate NEW_LEN
  assign eob_len = (eob_r == 0) ? 0 : 4;
  assign new_len = huf_len_r + symbol_len_r 
                   + eob_len;
  //--------------------------------------------------
  // calculate NEW_BITS
  //--------------------------------------------------
  always_comb 
  begin  
     new_bits = '0;
     new_bits = (huf_r << (symbol_len_r + eob_len)) 
                | ( (symbol_r & ( (16'd1<<symbol_len_r) -1) ) << eob_len); 
     if (eob_r)
        new_bits |= 4'b1010;    
  end
  //--------------------------------------------------
  // determine OUTPUT, POST-SHIFT BUFFER_LEN
  //--------------------------------------------------
  assign byte_r = buffer[38:31];
  
  always_comb 
  begin
     buffer_len_next = buffer_len;
     if (state == S_APPEND)
        buffer_len_next = buffer_len + new_len;
  end
  
  //--------------------------------------------------
  // FSM
  //--------------------------------------------------
  always_comb
  begin
     next_state = state;
     case (state) 
        S_IDLE: 
        begin
           if (valid_in && ready_in)
              next_state = S_APPEND;
        end
        S_APPEND:
        begin
           if ( endtoken_r == 1'b1 && buffer_len_next < 8 )// endtoken + need to flush
              next_state = S_END;
           else if (endtoken_r == 1'b0 && buffer_len_next < 8)
              next_state = S_IDLE;
           else //if (buffer_len_next >= 8)
              next_state = S_BYTE;
        end
        S_BYTE:
        begin
           next_state = S_OUT;
        end
        S_OUT:
        begin
           if (ready_out && valid_out)
           begin
              if (buffer_len > 7)
                 next_state = S_BYTE;
              else 
              begin
                 if (endtoken_r == 1'b0) 
                    next_state = S_IDLE;
                 else if (endtoken_r == 1'b1)
                    next_state = S_END;
              end
           end
        end
        S_END:
        begin
           next_state = S_END;
        end
        //STAY IN S_END
        default: next_state = S_IDLE;
     endcase
  end 
  
  logic valid_end;
  assign ready_in  = (state == S_IDLE);
  assign valid_out = (state == S_OUT || valid_end);
  //----------------------------------------------------
  // INPUT OUTPUT and BUFFER
  //----------------------------------------------------
  always_ff @(posedge clk) 
  begin
     if (valid_in && ready_in) 
     begin
        endtoken_r   <= endtoken_i;
        huf_r        <= huf;       
        huf_len_r    <= huf_len;   
        symbol_r     <= symbol;    
        symbol_len_r <= symbol_len;
        eob_r        <= eob;
     end
  end
  
  always_ff @(posedge clk)
  begin
     case (state)
        S_IDLE:
        begin
           byte_out <= byte_out;   
        end
        S_APPEND:
        begin
           byte_out <= byte_out;    
        end
        S_BYTE:
        begin
           byte_out <= byte_r;
        end
        S_OUT:
        begin
           byte_out <= byte_out;
        end
        S_END:
        begin
           // byte_r from [MSB..LSB(invalid_bits)] to [(MSB..LSB(1111)]
           byte_out   <= (byte_r) | (8'hFF >> buffer_len);
//            // byte_r from [MSB..LSB(invalid_bits)] to [(1111)(MSB..LSB]
           //byte_out   <= (byte_r >> (8 - buffer_len)) | (8'hFF << buffer_len);
        end
     endcase
  end
  
  // valid_end
  always_ff @(posedge clk)
  begin
      if (!reset_n)
      begin
          valid_end <= 1'b0;
      end
      else
      begin
          if (state == S_END)
          begin
             valid_end     <= 1'b1;
          end
          else
          begin
              valid_end <= valid_end;
          end
      end
  end
  
  always_ff @(posedge clk )
  begin
     if (!reset_n)
     begin
        state         <= S_IDLE;
        buffer        <= '0;
        buffer_len    <= '0;
        endtoken_o    <= '0;
     end
     else 
     begin
        state <= next_state;
        case (state)
           S_IDLE:
           begin
              endtoken_o <= 1'b0;
           end
           S_APPEND:
           begin
              //apendd MSB new_bits to LSB of buffer
              buffer     <= buffer | (new_bits << (39 - buffer_len - new_len));       
              buffer_len <= buffer_len + new_len;;     
           end
           S_BYTE:
           begin
              buffer     <= buffer << 8; 
              buffer_len <= buffer_len - 8'd8;
              //in case endtoken = 1 && buffer_len = 8 
              // output in S_OUT
              if (endtoken_r == 1'b1 && buffer_len == 8)
                 endtoken_o <= 1'b1;
           end
           S_OUT:
           begin
           end
           S_END:
           begin
              endtoken_o <= 1'b1;
           end
        endcase
     end
  end
  
endmodule



