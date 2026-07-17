`timescale 1ns/1ns
module quantization (
    input  logic        clk,
    input  logic        reset_n,   // Active-low reset
    input  logic        valid_in,  // Valid input data (replaces start)
    output logic        ready_in,  // Ready to accept input
    
    input  logic        endtoken_i,
    output logic        endtoken_o,
    
    input  logic signed [15:0]  Y [0:63],
    output logic        valid_out, // Valid output data (replaces ack)
    input  logic        ready_out, // Ready to accept output
    output logic signed [15:0] Y_out [0:63]
);


    // FSM states
    typedef enum logic [1:0] {
        S_IDLE    = 2'b00,
        S_COMPUTE = 2'b01,
        S_OUTPUT  = 2'b10
    } state_t;

    state_t state, next_state;

    // Internal registers
    logic signed [15:0] Y_reg [0:63];
    logic signed [15:0] Y_temp;
    logic [5:0]         idx;
    logic [6:0]         compute_cnt;
    
    logic [5:0]         zigzag_r;
    logic signed [15:0] data_r, quant_r;
    logic signed [31:0] mult_r;
    
    (* rom_style = "distributed" *)
    localparam logic signed [15:0] quantize_table [0:63] ='{
       16   , 23   , 26   , 16   , 11   , 6   , 5   , 4   ,
       21   , 21   , 18   , 13   , 10   , 4   , 4   , 5   ,
       18   , 20   , 16   , 11   , 6   , 4   , 4   , 5   ,
       18   , 15   , 12   , 9    , 5   , 3   , 3   , 4   ,
       14   , 12   , 7    , 5    , 4   , 2   , 2   , 3   ,
       11   , 7    , 5    , 4    , 3   , 1   , 2   , 3   ,
       5    , 4    , 3    , 3    , 2   , 2   , 2   , 3   ,
       4    , 3    , 3    , 3    , 2   , 3   , 2   , 3  
    };
    (* rom_style = "distributed" *)
    localparam logic [5:0] zigzag [0:63] = '{
       0 ,1 ,8 ,16,9,2,3,10,
       17,24,32,25,18,11,4 ,5  ,
       12,19,26,33,40,48,41,34,
       27,20,13,6 ,7 ,14,21,28,
       35,42,49,56,57,50,43,36,
       29,22,15,23,30,37,44,51,
       58,59,52,45,38,31,39,46,
       53,60,61,54,47,55,62,63
    };
    // ------------------------------------------------------------------
    // FSM next state logic
    // ------------------------------------------------------------------
    always_comb 
    begin
        next_state = state;
        case (state)
            S_IDLE: 
            begin
                if (valid_in && ready_in) 
                begin
                    next_state = S_COMPUTE;
                end
            end
            S_COMPUTE: 
            begin
               if (compute_cnt == 7'd67 )
                  next_state = S_OUTPUT;
            end
            S_OUTPUT: 
            begin
                if (valid_out && ready_out) 
                begin
                    next_state = S_IDLE;
                end
            end
            default: next_state = S_IDLE;
        endcase
    end
    assign ready_in  = (state == S_IDLE);
    assign valid_out = (state == S_OUTPUT);
    //------------------------------------------
    
    //------------------------------------------
    always_ff @(posedge clk)
    begin
        if (state == S_COMPUTE )
        begin
           compute_cnt <= compute_cnt + 1;
           if (idx < 6'd63)
              idx <= idx + 1;
           else
              idx <= idx;
        end   
        else 
        begin
           compute_cnt <= '0;
           idx         <= '0; 
        end
    end
    
    always_ff @(posedge clk)
    begin
        zigzag_r   <= zigzag[idx];
    end
 
    always_ff @(posedge clk)
    begin
       data_r     <= Y_reg         [zigzag_r];
       quant_r    <= quantize_table[zigzag_r];
    end
    
    always_ff @(posedge clk)
    begin
       mult_r <= data_r * quant_r;
    end
    
    always_ff @(posedge clk)
    begin
       Y_temp <= (mult_r + ((mult_r < 0) ? 32'sd255 : 32'sd0)) >>> 8;
    end
    
    always_ff @(posedge clk)
    begin
       if (state == S_COMPUTE)
       begin
          Y_out [compute_cnt - 7'd4] <= Y_temp;
       end
    end
    
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
    
    always_ff @(posedge clk ) 
    begin
        if (!reset_n) 
        begin
           state      <= S_IDLE;
           endtoken_o <= '0;
        end 
        else 
        begin
            state <= next_state;
            
            case (state)
                S_IDLE: 
                begin
                end

                S_COMPUTE: 
                begin
                   if (compute_cnt == 7'd67)
                      endtoken_o <= endtoken_i;
                end
                S_OUTPUT: 
                begin
                   
                end
            endcase
        end
    end
  
endmodule
