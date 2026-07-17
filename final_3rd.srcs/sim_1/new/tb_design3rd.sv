`timescale 1ns / 1ps
module tb_design3rd;
   // ------------------------------------------------------------
   // Clock / Reset
   // ------------------------------------------------------------
   logic clk;
   logic reset_n;
   // ------------------------------------------------------------
   // DUT I/O
   // ------------------------------------------------------------
   logic         valid_out;
   logic [7:0]   byte_out;
   
//   logic valid01;
//   assign valid01 = dut.valid01;
   
//   logic [15:0] width, len;
//   logic [23:0] pixelnum;
//   assign width = dut.width;
//   assign len   = dut.len;
//   assign pixelnum = dut.pixelnum;
   
//   logic valid12, ready12;
//   assign valid12 = dut.valid12;
//   assign ready12 = dut.ready12;
   
//   logic statergb2y;
//   logic [5:0]  idx;
//   assign statergb2y = dut.dut2.state;
//   assign idx = dut.dut2.idx;
   
//   logic valid23, ready23;
//   assign valid23 = dut.valid23;
//   assign ready23 = dut.ready23;
//   logic signed [15:0] Y [0:63];
//   assign Y = dut.Y;
//   logic valid34, ready34;
//   assign valid34 = dut.valid34;
//   assign ready34 = dut.ready34;
   
//   logic valid45, ready45;
//   assign valid45 = dut.valid45;
//   assign ready45 = dut.ready45;
   
//    logic signed [15:0] Y_reg [0:63];
//    logic signed [15:0] Y_temp;
//    logic [5:0]         idx;
//    logic [6:0]         compute_cnt;
//    logic [5:0]         zigzag_r;
//    logic signed [15:0] data_r, quant_r;
//    logic signed [31:0] mult_r;
//    logic [1:0] statedut5;
//    logic signed [15:0] Y_quant [0:63];
    
//    assign statedut5   = dut.dut5.state;
//    assign Y_reg       = dut.dut5.Y_reg;
//    assign Y_temp      = dut.dut5.Y_temp;
//    assign idx         = dut.dut5.idx;
//    assign compute_cnt = dut.dut5.compute_cnt;
//    assign zigzag_r    = dut.dut5.zigzag_r;
//    assign data_r      = dut.dut5.data_r;
//    assign quant_r     = dut.dut5.quant_r;
//    assign mult_r      = dut.dut5.mult_r;
//   assign Y_quant      = dut.Y_quant; 
//   logic valid56, ready56;
//   assign valid56 = dut.valid56;
//   assign ready56 = dut.ready56;
   
//   logic valid67, ready67;
//   assign valid67 = dut.valid67;
//   assign ready67 = dut.ready67;
   
//   logic [1:0] state, next_state;
//   assign state      = dut.dut2.state;
//   assign next_state = dut.dut2.next_state;
   
//   logic [5:0]         idx; 
//   logic [2:0]         dc_counter,ac_counter;
//   assign idx        = dut.dut6.idx;
//   logic signed [15:0] coeff;
//   assign coeff      = dut.dut6.coeff;
//   assign dc_counter = dut.dut6.dc_counter;
//   assign ac_counter = dut.dut6.ac_counter;

//   logic eob;
//   assign eob = dut.dut6.eob;
//   logic zrl_flag;
//   assign zrl_flag = dut.dut6.zrl_flag;
   
//   logic endtoken1;
//   assign endtoken1 = dut.endtoken1;
//   logic endtoken2;
//   assign endtoken2 = dut.endtoken2;
//   logic endtoken3;
//   assign endtoken3 = dut.endtoken3;
//   logic endtoken4;
//   assign endtoken4 = dut.endtoken4;
//   logic endtoken5;
//   assign endtoken5 = dut.endtoken5;
//   logic endtoken6;
//   assign endtoken6 = dut.endtoken6;
//   logic endtoken7;
//   assign endtoken7 = dut.endtoken7;
  
//  logic rgbstate;
//  logic [5:0] idx;
//  assign rgbstate = dut.dut2.state;
//  assign idx      = dut.dut2.idx;
//   logic signed [15:0] Y_dct1d [0:63];
//   assign Y_dct1d = dut.Y_dct1d;
   
//   logic signed [15:0] Y_dct2d [0:63];
//   assign Y_dct2d = dut.Y_dct2d;
   
//   logic signed [15:0] Y_quant [0:63];
//   assign Y_quant = dut.Y_quant;
//   logic signed [16:0] x01,x11,x21,x31,x41,x51,x61,x71;
//   assign x01 = dut.dut3.x01;
//   assign x71 = dut.dut3.x71;
//   assign x11 = dut.dut3.x11;
//   assign x61 = dut.dut3.x61;
//   assign x21 = dut.dut3.x21;
//   assign x51 = dut.dut3.x51;
//   assign x31 = dut.dut3.x31;
//   assign x41 = dut.dut3.x41;
//   logic [3:0] compute_cnt;
//   assign compute_cnt = dut.dut3.compute_cnt;  
//   logic signed [16:0] x02,x12,x22,x32,x42,x52,x62,x72;
//   logic signed [16:0] x03,x13,x23,x33,x43,x53,x63,x73;
//   logic signed [16:0] x04,x14,x24,x34,x44,x54,x64,x75;		                    
//   logic signed [16:0] x57,x65; 
//assign x02 = dut.dut3.x02;
//assign x32 = dut.dut3.x32;
//assign x12 = dut.dut3.x12;
//assign x22 = dut.dut3.x22;
//assign x42 = dut.dut3.x42;
//assign x72 = dut.dut3.x72;
//assign x52 = dut.dut3.x52;
//assign x62 = dut.dut3.x62;
//assign x03 = dut.dut3.x03;
//assign x13 = dut.dut3.x13;
//assign x23 = dut.dut3.x23;
//assign x33 = dut.dut3.x33;
//assign x43 = dut.dut3.x43;
//assign x53 = dut.dut3.x53;
//assign x63 = dut.dut3.x63;
//assign x73 = dut.dut3.x73;
//assign x04 = dut.dut3.x04;
//assign x14 = dut.dut3.x14;
//assign x24 = dut.dut3.x24;
//assign x34 = dut.dut3.x34;
//assign x44 = dut.dut3.x44;
//assign x54 = dut.dut3.x54;
//assign x64 = dut.dut3.x64;
//assign x75 = dut.dut3.x75;
//assign x57 = dut.dut3.x57;
//assign x65 = dut.dut3.x65;
//logic signed [15:0] dct_reg0,dct_reg1,dct_reg2,dct_reg3,dct_reg4,dct_reg5,dct_reg6,dct_reg7;
//  assign dct_reg0 = dut.dut3.dct_reg0; 
//  assign dct_reg1 = dut.dut3.dct_reg1; 
//  assign dct_reg2 = dut.dut3.dct_reg2; 
//  assign dct_reg3 = dut.dut3.dct_reg3; 
//  assign dct_reg4 = dut.dut3.dct_reg4; 
//  assign dct_reg5 = dut.dut3.dct_reg5; 
//  assign dct_reg6 = dut.dut3.dct_reg6; 
//  assign dct_reg7 = dut.dut3.dct_reg7; 
   
   
   
   
   
   // ------------------------------------------------------------
   // Instantiate DUT
   // ------------------------------------------------------------
   design_3rd dut(
   .clk       (clk),
   .reset     (!reset_n),
   .valid_out (valid_out),
   .byte_out  (byte_out)
   );
   // ------------------------------------------------------------
   // Clock generation: 100 MHz
   // ------------------------------------------------------------
   initial clk = 1'b0;
   always #5 clk = ~clk;
   // ------------------------------------------------------------
   // Reset sequence
   // ------------------------------------------------------------
   initial 
   begin
       reset_n   = 1'b0;

       repeat (5) @(posedge clk);
       reset_n   = 1'b1;
   end
   // ------------------------------------------------------------
   // Start simulation
   // ------------------------------------------------------------
   initial begin
       @(posedge reset_n);
       $display("[%0t] Start simulation", $time);
   end

//   // ------------------------------------------------------------
//   // Simulation end condition
//   // ------------------------------------------------------------
//   initial 
//   begin
//       #4700us;
//       $display("\nSimulation finished");
//       $finish;
//   end
   
    always_ff @(posedge clk)
    begin
        if (valid_out == 1)
        $display("%0d",byte_out);
    end   
    
endmodule


//module quantization (
//    input  logic        clk,
//    input  logic        reset_n,   // Active-low reset
//    input  logic        valid_in,  // Valid input data (replaces start)
//    output logic        ready_in,  // Ready to accept input
    
//    input  logic        endtoken_i,
//    output logic        endtoken_o,
    
//    input  logic signed [15:0]  Y [0:63],
//    output logic        valid_out, // Valid output data (replaces ack)
//    input  logic        ready_out, // Ready to accept output
//    output logic signed [15:0] Y_out [0:63]
//);


//    // FSM states
//    typedef enum logic [1:0] {
//        S_IDLE    = 2'b00,
//        S_COMPUTE = 2'b01,
//        S_OUTPUT  = 2'b10
//    } state_t;

//    state_t state, next_state;

//    // Internal registers
//    logic signed [15:0] Y_reg [0:63];
//    logic signed [15:0] Y_temp;
//    logic [5:0]         idx;
//    logic [6:0]         compute_cnt;
    
//    logic [5:0]         zigzag_r;
//    logic signed [15:0] data_r, quant_r;
//    logic signed [31:0] mult_r;
    
//    (* rom_style = "distributed" *)
//    localparam logic signed [15:0] quantize_table [0:63] ='{
//       16   , 23   , 26   , 16   , 11   , 6   , 5   , 4   ,
//       21   , 21   , 18   , 13   , 10   , 4   , 4   , 5   ,
//       18   , 20   , 16   , 11   , 6   , 4   , 4   , 5   ,
//       18   , 15   , 12   , 9    , 5   , 3   , 3   , 4   ,
//       14   , 12   , 7    , 5    , 4   , 2   , 2   , 3   ,
//       11   , 7    , 5    , 4    , 3   , 1   , 2   , 3   ,
//       5    , 4    , 3    , 3    , 2   , 2   , 2   , 3   ,
//       4    , 3    , 3    , 3    , 2   , 3   , 2   , 3  
//    };
//    (* rom_style = "distributed" *)
//    localparam logic [5:0] zigzag [0:63] = '{
//       0 ,1 ,8 ,16,9,2,3,10,
//       17,24,32,25,18,11,4 ,5  ,
//       12,19,26,33,40,48,41,34,
//       27,20,13,6 ,7 ,14,21,28,
//       35,42,49,56,57,50,43,36,
//       29,22,15,23,30,37,44,51,
//       58,59,52,45,38,31,39,46,
//       53,60,61,54,47,55,62,63
//    };
//    // ------------------------------------------------------------------
//    // FSM next state logic
//    // ------------------------------------------------------------------
//    always_comb 
//    begin
//        next_state = state;
//        case (state)
//            S_IDLE: 
//            begin
//                if (valid_in && ready_in) 
//                begin
//                    next_state = S_COMPUTE;
//                end
//            end
//            S_COMPUTE: 
//            begin
//               if (compute_cnt == 7'd67 )
//                  next_state = S_OUTPUT;
//            end
//            S_OUTPUT: 
//            begin
//                if (valid_out && ready_out) 
//                begin
//                    next_state = S_IDLE;
//                end
//            end
//            default: next_state = S_IDLE;
//        endcase
//    end
//    assign ready_in  = (state == S_IDLE);
//    assign valid_out = (state == S_OUTPUT);
//    //------------------------------------------
    
//    //------------------------------------------
//    always_ff @(posedge clk)
//    begin
//        if (state == 2'b1 )
//        begin
//           compute_cnt <= compute_cnt + 1;
//           if (idx < 6'd63)
//              idx <= idx + 1;
//           else
//              idx <= idx;
//        end   
//        else 
//        begin
//           compute_cnt <= '0;
//           idx         <= '0; 
//        end
//    end
    
//    always_ff @(posedge clk)
//    begin
//        zigzag_r   <= zigzag[idx];
//    end
 
//    always_ff @(posedge clk)
//    begin
//       data_r     <= Y_reg         [zigzag_r];
//       quant_r    <= quantize_table[zigzag_r];
//    end
    
//    always_ff @(posedge clk)
//    begin
//       mult_r <= data_r * quant_r;
//    end
    
//    always_ff @(posedge clk)
//    begin
//       Y_temp <= (mult_r + ((mult_r < 0) ? 32'sd255 : 32'sd0)) >>> 8;
//    end
    
//    always_ff @(posedge clk)
//    begin
//       if (state == S_COMPUTE)
//       begin
//          Y_out [compute_cnt - 7'd4] <= Y_temp;
//       end
//    end
    
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
    
//    always_ff @(posedge clk ) 
//    begin
//        if (!reset_n) 
//        begin
//           state      <= S_IDLE;
//           endtoken_o <= '0;
//        end 
//        else 
//        begin
//            state <= next_state;
            
//            case (state)
//                S_IDLE: 
//                begin
//                end

//                S_COMPUTE: 
//                begin
//                   if (compute_cnt == 7'd67)
//                      endtoken_o <= endtoken_i;
//                end
//                S_OUTPUT: 
//                begin
                   
//                end
//            endcase
//        end
//    end
  
//endmodule
