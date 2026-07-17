`timescale 1ns / 1ps

module BRAM_pixel(
   input               clk,
   input  logic        reset_n,
         
   input  logic        valid_in,
   input  logic [23:0] pixelnum,              
   output logic        valid_out,
   input  logic        ready_out,
   output logic [7:0]  R, 
   output logic [7:0]  G, 
   output logic [7:0]  B,
   output logic        endtoken 
);

    logic [17:0] counter;
    logic        ena;
    logic [23:0] memout;

    logic [23:0] pixelnum_reg;

    // --------------------------------------------------
    // BRAM
    // --------------------------------------------------
    blk_mem_gen_0 pixelrom (  
        .clka  (clk),            
        .ena   (ena),         
        .addra (counter),  
        .douta (memout)   
    );  

    // --------------------------------------------------
    // FSM
    // --------------------------------------------------
    typedef enum logic [2:0] {
        S_IDLE  = 3'b000,
        S_ADDR  = 3'b001,
        S_WAIT  = 3'b010,
        S_DATA  = 3'b011,
        S_SEND  = 3'b100
    } state_t;

    state_t state, next_state;

    // --------------------------------------------------
    // Next-state logic
    // --------------------------------------------------
    always_comb 
    begin
        next_state = state;

        case (state)
            S_IDLE: 
               if (valid_in)
                  next_state = S_ADDR;
            S_ADDR:
                next_state = S_WAIT;

            S_WAIT:
                next_state = S_DATA;

            S_DATA:
               next_state = S_SEND;
            S_SEND:
            begin
               if (valid_out && ready_out) 
                begin
                   if (counter < pixelnum_reg )
                      next_state = S_ADDR;
                end
            end
            default: next_state = S_IDLE;   
        endcase
    end

    // --------------------------------------------------
    // Sequential logic
    // --------------------------------------------------
    assign valid_out = (state == S_SEND && ena == 1'b1) ;
    
    always_ff @(posedge clk) 
    begin
        if (!reset_n) 
        begin
            state   <= S_IDLE;
            counter <= 18'd3;
            ena     <= 1'b1;
            R       <= '0;
            G       <= '0;
            B       <= '0;
            endtoken <= 0;
        end
        else 
        begin
            state <= next_state;

            case (state)
                // WAIT 
                S_IDLE:
                begin
                   if (valid_in )
                      pixelnum_reg <= pixelnum +2;
                      
                end
                // Address already equals current counter
                S_ADDR: 
                begin
                    // nothing
                end

                // Wait 1 cycle for BRAM latency
                S_WAIT: 
                begin
                    // nothing
                end

                // Capture data and increment AFTER handshake
                S_DATA: 
                begin
                   if (counter == pixelnum_reg)
                   begin
                      endtoken <= 1'b1;
                   end
                   R <= memout[23:16];
                   G <= memout[15:8];
                   B <= memout[7:0];
                end
                S_SEND:
                begin
                   if (valid_out && ready_out) 
                   begin
                      if (counter < (pixelnum_reg) )
                         counter <= counter + 1;
                      else 
                      begin
                         counter <= counter;
                         ena      <= 1'b0;
                      end
                   end
                end
            endcase
        end
    end

endmodule

