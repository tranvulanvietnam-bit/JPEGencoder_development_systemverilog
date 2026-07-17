`timescale 1ns / 1ps
/////////////////////////////////////////////////////////////////////////////////
module dct1d (
   input  logic         clk,
    input  logic        reset_n,   // Active-low reset
    input  logic        valid_in,  // Valid input data (replaces start)
    output logic        ready_in,  // Ready to accept input
    
    input  logic        endtoken_i,
    output logic        endtoken_o,
    
    input  logic signed [15:0]  Y [0:63],
    output logic        valid_out, // Valid output data (replaces ack)
    input  logic        ready_out, // Ready to accept output
    output logic signed [15:0] Y_dct [0:63]
);

    // FSM states
    typedef enum logic [1:0] {
        S_IDLE    = 2'b00,
        S_COMPUTE = 2'b01,
        S_OUTPUT  = 2'b11
    } state_t;

    state_t state, next_state;

    // Internal registers
    logic signed [15:0] Y_reg   [0:63]; //store input
    logic signed [15:0] dct_reg0,dct_reg1,dct_reg2,dct_reg3,dct_reg4,dct_reg5,dct_reg6,dct_reg7; //store processes variable
    logic [3:0] compute_cnt;
    
    logic signed [15:0] x01,x11,x21,x31,x41,x51,x61,x71;
    logic signed [15:0] x02,x12,x22,x32,x42,x52,x62,x72;
    logic signed [15:0] x03,x13,x23,x33,x43,x53,x63,x73;
    logic signed [15:0] x04,x14,x24,x34,x44,x54,x64,x75;		                    
    logic signed [15:0] x57,x65;      
    logic signed [31:0] mult_sum14,mult_sum57,mult_sum65;
    logic signed [31:0] mult_sum42,mult_sum72,mult_sum52,mult_sum62,mult_sum23,mult_sum33;
    logic compute_done;

    assign compute_done = (compute_cnt == 4'd13);
    //st1     
    always_ff @(posedge clk) 
    begin
       case (compute_cnt)
          4'd0:
          begin
             dct_reg0 <= Y_reg[0];
             dct_reg1 <= Y_reg[1];
             dct_reg2 <= Y_reg[2];
             dct_reg3 <= Y_reg[3];
             dct_reg4 <= Y_reg[4];
             dct_reg5 <= Y_reg[5];
             dct_reg6 <= Y_reg[6];
             dct_reg7 <= Y_reg[7];
          end
          4'd1:
          begin
             dct_reg0 <= Y_reg[8];
             dct_reg1 <= Y_reg[9];
             dct_reg2 <= Y_reg[10];
             dct_reg3 <= Y_reg[11];
             dct_reg4 <= Y_reg[12];
             dct_reg5 <= Y_reg[13];
             dct_reg6 <= Y_reg[14];
             dct_reg7 <= Y_reg[15];
          end
          4'd2:
          begin
             dct_reg0 <= Y_reg[16];
             dct_reg1 <= Y_reg[17];
             dct_reg2 <= Y_reg[18];
             dct_reg3 <= Y_reg[19];
             dct_reg4 <= Y_reg[20];
             dct_reg5 <= Y_reg[21];
             dct_reg6 <= Y_reg[22];
             dct_reg7 <= Y_reg[23];
          end
          4'd3:
          begin
             dct_reg0 <= Y_reg[24];
             dct_reg1 <= Y_reg[25];
             dct_reg2 <= Y_reg[26];
             dct_reg3 <= Y_reg[27];
             dct_reg4 <= Y_reg[28];
             dct_reg5 <= Y_reg[29];
             dct_reg6 <= Y_reg[30];
             dct_reg7 <= Y_reg[31];
          end
          4'd4:
          begin
             dct_reg0 <= Y_reg[32];
             dct_reg1 <= Y_reg[33];
             dct_reg2 <= Y_reg[34];
             dct_reg3 <= Y_reg[35];
             dct_reg4 <= Y_reg[36];
             dct_reg5 <= Y_reg[37];
             dct_reg6 <= Y_reg[38];
             dct_reg7 <= Y_reg[39];
          end
          4'd5:
          begin
             dct_reg0 <= Y_reg[40];
             dct_reg1 <= Y_reg[41];
             dct_reg2 <= Y_reg[42];
             dct_reg3 <= Y_reg[43];
             dct_reg4 <= Y_reg[44];
             dct_reg5 <= Y_reg[45];
             dct_reg6 <= Y_reg[46];
             dct_reg7 <= Y_reg[47];
          end
          4'd6:
          begin
             dct_reg0 <= Y_reg[48];
             dct_reg1 <= Y_reg[49];
             dct_reg2 <= Y_reg[50];
             dct_reg3 <= Y_reg[51];
             dct_reg4 <= Y_reg[52];
             dct_reg5 <= Y_reg[53];
             dct_reg6 <= Y_reg[54];
             dct_reg7 <= Y_reg[55];
          end
          4'd7:
          begin
             dct_reg0 <= Y_reg[56];
             dct_reg1 <= Y_reg[57];
             dct_reg2 <= Y_reg[58];
             dct_reg3 <= Y_reg[59];
             dct_reg4 <= Y_reg[60];
             dct_reg5 <= Y_reg[61];
             dct_reg6 <= Y_reg[62]; 
             dct_reg7 <= Y_reg[63]; 
          end
       endcase
    end    

     // st2
    always_ff @(posedge clk) 
    begin
       x01 <= dct_reg0 + dct_reg7 + 2'sd1; 
       x71 <= dct_reg0 - dct_reg7;  
       x11 <= dct_reg1 + dct_reg6 + 2'sd1; 
       x61 <= dct_reg1 - dct_reg6; 
       x21 <= dct_reg2 + dct_reg5 + 2'sd1;
       x51 <= dct_reg2 - dct_reg5;
       x31 <= dct_reg3 + dct_reg4 + 2'sd1; 
       x41 <= dct_reg3 - dct_reg4;
    end
    
     //st3
     
     assign mult_sum42 = (x41 * 16'sd49  + x71 * 16'sd251);
     assign mult_sum72 = (x71 * 16'sd49  - x41 * 16'sd251);
     assign mult_sum52 = (x51 * 16'sd140 + x61 * 16'sd212);
     assign mult_sum62 = (x61 * 16'sd140 - x51 * 16'sd212);  
     
     always_ff @(posedge clk) 
     begin
           x02 <= x01 + x31;
           x32 <= x01 - x31;
           x12 <= x11 + x21;
           x22 <= x11 - x21;
           x42 <= mult_sum42 >>> 8;
           x72 <= mult_sum72 >>> 8;
           x52 <= mult_sum52 >>> 8;
           x62 <= mult_sum62 >>> 8;
     end
     
            // st4
     assign mult_sum23 = ( x22 * 16'sd97 + x32 * 16'sd236 );
     assign mult_sum33 = ( x32 * 16'sd97 - x22 * 16'sd236 );
     always_ff @(posedge clk) 
     begin
           x03 <= x02 + x12;
           x13 <= x02 - x12;
           x23 <= mult_sum23 >>>8;
           x33 <= mult_sum33 >>>8;
           x43 <= x42 + x52;
           x53 <= x42 - x52;
           x63 <= x62 + x72;
           x73 <= x62 - x72;
     end
     
           // st5
     assign mult_sum14 = (x03 * 16'sd90);
     always_ff @(posedge clk) 
     begin
           x04 <= mult_sum14      >>>8;
           x14 <= (x13 * 16'sd90) >>>8;
           x24 <= x23             >>>1;
           x34 <= x33             >>>1;
           x44 <= x43             >>>1;
           x54 <= x53 + x63;
           x64 <= x53 - x63;
           x75 <= -(x73 >>> 1);
     end
     
     // stage 6
     assign mult_sum57 = (x54 * 16'sd90);
     assign mult_sum65 = (x64 * 16'sd90);
    
    always_ff @(posedge clk) 
    begin
       x57 <= mult_sum57 >>>8;
       x65 <= mult_sum65 >>>8; 
    end
    
    // stage 7
    always_ff @(posedge clk) 
    begin
       if (state == S_COMPUTE) 
       begin
          case (compute_cnt)
             (4'd5):
             begin
                Y_dct[0]  <=  x04;  
                Y_dct[8]  <=  x44; 
                Y_dct[16] <=  x24; 
                Y_dct[32] <=  x14; 
                Y_dct[48] <=  x34; 
                Y_dct[56] <=  x75;
             end
             (4'd6):
             begin 
                Y_dct[1]  <=  x04;  
                Y_dct[9]  <=  x44; 
                Y_dct[17] <=  x24; 
                Y_dct[24] <=  x57; 
                Y_dct[33] <=  x14; 
                Y_dct[40] <=  x65; 
                Y_dct[49] <=  x34; 
                Y_dct[57] <=  x75;
             end     
             (4'd7):
             begin 
                Y_dct[2]  <=  x04;  
                Y_dct[10] <=  x44; 
                Y_dct[18] <=  x24; 
                Y_dct[25] <=  x57; 
                Y_dct[34] <=  x14; 
                Y_dct[41] <=  x65; 
                Y_dct[50] <=  x34; 
                Y_dct[58] <=  x75;
             end
             4'd8:
             begin 
                Y_dct[3]  <=  x04;  
                Y_dct[11] <=  x44; 
                Y_dct[19] <=  x24; 
                Y_dct[26] <=  x57; 
                Y_dct[35] <=  x14; 
                Y_dct[42] <=  x65; 
                Y_dct[51] <=  x34; 
                Y_dct[59] <=  x75;
             end
             4'd9:
             begin 
                Y_dct[4]  <=  x04;  
                Y_dct[12] <=  x44; 
                Y_dct[20] <=  x24; 
                Y_dct[27] <=  x57; 
                Y_dct[36] <=  x14; 
                Y_dct[43] <=  x65; 
                Y_dct[52] <=  x34; 
                Y_dct[60] <=  x75;
             end
             (4'd10):
             begin 
                Y_dct[5]  <=  x04;  
                Y_dct[13] <=  x44; 
                Y_dct[21] <=  x24; 
                Y_dct[28] <=  x57; 
                Y_dct[37] <=  x14; 
                Y_dct[44] <=  x65; 
                Y_dct[53] <=  x34; 
                Y_dct[61] <=  x75;
             end
             (4'd11):
             begin 
                Y_dct[6] <=  x04;  
                Y_dct[14] <=  x44; 
                Y_dct[22] <=  x24; 
                Y_dct[29] <=  x57; 
                Y_dct[38] <=  x14; 
                Y_dct[45] <=  x65; 
                Y_dct[54] <=  x34; 
                Y_dct[62] <=  x75;
             end     
             4'd12:   
             begin 
                Y_dct[7]  <=  x04;  
                Y_dct[15] <=  x44; 
                Y_dct[23] <=  x24; 
                Y_dct[30] <=  x57; 
                Y_dct[39] <=  x14; 
                Y_dct[46] <=  x65; 
                Y_dct[55] <=  x34; 
                Y_dct[63] <=  x75;
             end
             4'd13:
             begin 
                Y_dct[31] <=  x57; 
                Y_dct[47] <=  x65; 
             end
          endcase
       end
    end
    // ------------------------------------------------------------------
    // FSM next state logic
    // ------------------------------------------------------------------
    always_comb 
    begin
        next_state = state;
        case (state)
            S_IDLE: 
            begin
                if (valid_in) 
                begin
                   next_state = S_COMPUTE;
                end
            end
            S_COMPUTE: 
            begin
               if (compute_done)
                  next_state = S_OUTPUT;
            end
            S_OUTPUT:
            begin
               if ( ready_out )
               begin
                  next_state = S_IDLE;
               end
            end
            default: next_state = S_IDLE;
        endcase
    end    
    

    
    assign ready_in  = (state == S_IDLE);
    assign valid_out = (state == S_OUTPUT);
    // ------------------------------------------------------------------
    // Sequential process: FSM state update, registers, and handshake
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
    
    always_ff @(posedge clk ) 
    begin
        if (!reset_n) 
        begin
           state       <= S_IDLE;
           compute_cnt <= '0;
           endtoken_o  <= 0;
        end 
        else 
        begin
            state <= next_state;
            
            case (state)
                S_IDLE: 
                begin
                   compute_cnt <= '0;
                end

                S_COMPUTE: 
                begin
                    compute_cnt      <= compute_cnt + 1;
                    if (compute_cnt == 4'd13)
                    begin
                       compute_cnt <= '0;
                       endtoken_o  <= endtoken_i;
                    end
                end

                S_OUTPUT: 
                begin
                    
                end
            endcase
        end
    end
    
     
 endmodule
