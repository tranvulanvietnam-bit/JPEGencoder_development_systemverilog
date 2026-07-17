`timescale 1ns / 1ps
module jpeg_meta_data(
   input                clk,
   input  logic         reset_n,
   
   output logic         valid_out,
   
   output logic [15:0]  width,
   output logic [15:0]  len,
   output logic [23:0]  pixelnum
);

   logic        ena;
   logic [23:0] memout0, memout1, memout2;
   logic [17:0] addr0, addr1, addr2;

   logic [1:0] counter;


   // --------------------------------------------------
   // BRAM
   // --------------------------------------------------
   blk_mem_gen_0 inst0 (  
       .clka  (clk),            
       .ena   (ena),         
       .addra (addr0),  
       .douta (memout0)   
   ); 

   blk_mem_gen_0 inst1 (  
       .clka  (clk),            
       .ena   (ena),         
       .addra (addr1),  
       .douta (memout1)   
   );  

   blk_mem_gen_0 inst2 (  
       .clka  (clk),            
       .ena   (ena),         
       .addra (addr2),  
       .douta (memout2)   
   );   


   // --------------------------------------------------
   // Counter replaces FSM
   // --------------------------------------------------
   assign valid_out = (counter == 2'd3);


   always_ff @(posedge clk)
   begin
      if (!reset_n)
      begin
          counter  <= 2'd0;

          ena      <= 1'b1;

          addr0    <= 18'd0;
          addr1    <= 18'd1;
          addr2    <= 18'd2;

          width    <= '0;
          len      <= '0;
          pixelnum <= '0;
      end

      else
      begin

          case(counter)

              // BRAM address already applied
              2'd0:
              begin
                  counter <= 2'd1;
              end


              // BRAM latency wait
              2'd1:
              begin
                  counter <= 2'd2;
              end


              // Capture BRAM data
              2'd2:
              begin
                  width    <= memout0[15:0];
                  len      <= memout1[15:0];
                  pixelnum <= memout2;

                  counter <= 2'd3;
              end


              // Output valid forever
              2'd3:
              begin
                  counter <= 2'd3;
              end

              default:
                  counter <= 2'd0;

          endcase

      end
   end

endmodule
//module BRAM_widthlen_blknumb(
//   input               clk,
//   input  logic        reset_n,
   
//   output logic        valid_out,
   
//   output logic [15:0]  width,
//   output logic [15:0]  len,
//   output logic [23:0]  pixelnum
//    );
//   logic        ena;
//   logic [23:0] memout0,memout1,memout2;
//   logic [17:0] addr0,addr1,addr2;
//   // --------------------------------------------------
//   // BRAM
//   // --------------------------------------------------
//   blk_mem_gen_0 inst0 (  
//       .clka  (clk),            
//       .ena   (ena),         
//       .addra (addr0),  
//       .douta (memout0)   
//   ); 
//   blk_mem_gen_0 inst1 (  
//       .clka  (clk),            
//       .ena   (ena),         
//       .addra (addr1),  
//       .douta (memout1)   
//   );  
//   blk_mem_gen_0 inst2 (  
//       .clka  (clk),            
//       .ena   (ena),         
//       .addra (addr2),  
//       .douta (memout2)   
//   );   
//   // --------------------------------------------------
//    // FSM
//    // --------------------------------------------------
//    typedef enum logic [1:0] {
//        S_ADDR  = 2'b00,
//        S_WAIT  = 2'b01,
//        S_DATA  = 2'b10,
//        S_SEND  = 2'b11
//    } state_t;

//    state_t state, next_state;
//   // --------------------------------------------------
//    // Next-state logic
//    // --------------------------------------------------
//    always_comb 
//    begin
//        next_state = state;

//        case (state)
//            S_ADDR:
//                next_state = S_WAIT;
//            S_WAIT:
//                next_state = S_DATA;
//            S_DATA:
//               next_state  = S_SEND;
//            S_SEND:
//               next_state  = S_SEND;
//        endcase
//    end
//      // --------------------------------------------------
//      // Sequential logic 
//      // -------------------------------------------------- 
//      assign valid_out = (state == S_SEND); 
       
//      always_ff @(posedge clk)  
//      begin 
//          if (!reset_n)  
//          begin 
//              state   <= S_ADDR; 
//              ena     <= 1'b1; 
//              addr0   <= 18'd0;
//              addr1   <= 18'd1;
//              addr2   <= 18'd2;
//              width    <= '0; 
//              len      <= '0;
//              pixelnum <= '0;
//          end 
//          else  
//          begin 
//              state <= next_state; 
              
//              case (state) 
//                  // Address already equals current counter 
//                  S_ADDR:  
//                  begin 
//                     width    <= width   ; 
//                     len      <= len     ;
//                     pixelnum <= pixelnum;
//                  end 
   
//                  // Wait 1 cycle for BRAM latency 
//                  S_WAIT:  
//                  begin 
//                     width    <= width   ;
//                     len      <= len     ;
//                     pixelnum <= pixelnum;
//                  end 
   
//                  // Capture data and increment AFTER handshake 
//                  S_DATA:  
//                  begin 
//                     width    <= memout0[15:0]; 
//                     len      <= memout1[15:0]; 
//                     pixelnum <= memout2;
//                  end 
//                  S_SEND:
//                  begin
//                     width    <= width   ;
//                     len      <= len     ;
//                     pixelnum <= pixelnum;
//                  end
//                  default:
//                  begin
//                     width    <= width   ;
//                     len      <= len     ;
//                     pixelnum <= pixelnum;
//                  end
//              endcase 
//          end 
//      end 
//endmodule






     