`timescale 1ns/1ps

module rgb2y(
    input  logic               clk,
    input  logic               reset_n,
    
    input  logic               valid_in,
    output logic               ready_in,
    input  logic [7:0]         R,
    input  logic [7:0]         G,
    input  logic [7:0]         B,
    input  logic               endtoken_i,
    
    output logic               endtoken_o,
    output logic               valid_out,
    input  logic               ready_out,
    output logic signed [15:0] Y [0:63]
); 
    logic [5:0]  idx;
    logic signed [15:0] Y_calc;
    logic signed [16:0] RGBbuf;
    //-------------------------------------------------
    // Combinational Y calculation (DSP friendly)
    //-------------------------------------------------
    always_comb 
    begin
    // this is safe because RGBbuf always positive
        RGBbuf = (16'd65  * R + 16'd128 * G + 16'd25  * B);
    // Y_calc is around -112 +105 which is 8 singed bits so good
        Y_calc = (RGBbuf >>> 8) - 16'sd112 ; //+16-128=-112
    end

    typedef enum logic [0:0] {
    S_IDLE,
    S_FULL
    } state_t;
state_t state;

assign ready_in  = (state == S_IDLE);
assign valid_out  = (state == S_FULL);

always_ff @(posedge clk)
begin
    if (valid_in && ready_in)
    begin
        Y[idx] <= Y_calc;
    end
end

always_ff @(posedge clk or negedge reset_n) 
begin
    if (!reset_n) 
    begin
        state      <= S_IDLE;
        idx        <= 0;
        endtoken_o <= 0;
    end 
    else 
    begin
        case (state)

        S_IDLE: 
        begin
            if (valid_in && ready_in) 
            begin
                if (idx == 6'd63) 
                begin
                    state      <= S_FULL;
                    endtoken_o <= endtoken_i;
                end 
                else 
                begin
                   //if (endtoken_o == 1'b0)
                      idx <= idx + 1;
                end
            end
        end

        S_FULL: 
        begin
            if (valid_out && ready_out) 
            begin
                state     <= S_IDLE;
                idx       <= 0;
            end
        end

        endcase
    end
end
endmodule