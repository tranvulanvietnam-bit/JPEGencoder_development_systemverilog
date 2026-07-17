`timescale 1ns / 1ps

module HEADER_STUFF_FLUSH(
    input  logic        clk             ,
    input  logic        reset_n         ,
    
    input  logic        valid_in        ,
    output logic        ready_in        ,
    
    input logic [15:0]  width           ,
    input logic [15:0]  len             ,
    input logic         widlen_valid_in ,
    
    input  logic        endtoken_i      ,
    input  logic [7:0]  byte_in         ,
    output logic [7:0]  byte_out        ,
    output logic        valid_out
);
  /*============================================================
    Parameters / Types
  ============================================================*/
  typedef enum logic [2:0] {
     S_WIDLENINPUT = 3'd0,
     S_HEADER      = 3'd1,
     S_IDLE        = 3'd2,
     S_OUT         = 3'd3,
     S_ZEROSTUFF   = 3'd4,
     S_END         = 3'd5
  } state_t;
  /*============================================================
    Registers
  ============================================================*/
  state_t state, next_state;
  logic [8:0] header_count;
  logic [15:0] wid_reg,len_reg;
  logic [2:0] end_count;
  /*============================================================
    HEADER FILE
  ============================================================*/
  (* rom_style = "distributed" *)
  localparam logic [7:0] header_table [0:396] = '{ 
      255,  216,   255,224	,000,	016	,074	,070	,073	,070	,000	,001	,002	,000	,000,	096	,000	,096	,000	,000,
      255,  219,   000,067	,000,	016	,011	,012	,014	,012	,010	,016	,014	,013	,014,	018	,017	,016	,019	,024,
      040,  026,   024,022	,022,	024	,049	,036	,037	,029	,040	,058	,051	,061	,060,	057	,051	,056	,055	,064,
      072,  092,   078,064	,068,	087	,069	,055	,056	,080	,109	,081	,087	,095	,098,	103	,194	,103	,062	,077,
      113,  121,   112,100	,120,	092	,101	,103	,099	,255	,219	,000	,067	,001	,017,	018	,018	,024	,021	,024,
      047,  026,   026,047	,099,	066	,056	,066	,099	,099	,099	,099	,099	,099	,099,	099	,099	,099	,099	,099,
      099,  099,   099,099	,099,	099	,099	,099	,099	,099	,099	,099	,099	,099	,099,	099	,099	,099	,099	,099,
      099,  099,   099,099	,099,	099	,099	,099	,099	,099	,099	,099	,099	,099	,099,	099	,099	,099	,255	,192,
      000,  011,   008,000	,000,	000	,000	,001	,001	,034	,000	,255	,196	,000	,031,	000	,000	,001	,005	,001,
      001,  001,   001,001	,001,	000	,000	,000	,000	,000	,000	,000	,000	,001	,002,	003	,004	,005	,006	,007,
      008,  009,   010,011	,255,	196	,000	,181	,016	,000	,002	,001	,003	,003	,002,	004	,003	,005    ,005	,004,
      004,  000,   000,001	,125,	001	,002	,003	,000	,004	,017	,005	,018	,033	,049,	065	,006	,019	,081	,097,
      007,  034,   113,020	,050,	129	,145	,161	,008	,035	,066	,177	,193	,021	,082,	209	,240	,036	,051	,098,
      114,  130,   009,010	,022,	023	,024	,025	,026	,037	,038	,039	,040	,041	,042,	052	,053	,054	,055	,056,
      057,  058,   067,068	,069,	070	,071	,072	,073	,074	,083	,084	,085	,086	,087,	088	,089	,090	,099	,100,
      101,  102,   103,104	,105,	106	,115	,116	,117	,118	,119	,120	,121	,122	,131,	132	,133	,134	,135	,136,
      137,  138,   146,147	,148,	149	,150	,151	,152	,153	,154	,162	,163	,164	,165,	166	,167	,168	,169	,170,
      178,  179,   180,181	,182,	183	,184	,185	,186	,194	,195	,196	,197	,198	,199,	200	,201	,202	,210	,211,
      212,  213,   214,215	,216,	217	,218	,225	,226	,227	,228	,229	,230	,231	,232,	233	,234	,241	,242	,243,
      244,  245,   246,247	,248,	249	,250	,255	,218	,000	,008	,001	,001	,000	,000,	063	,000                        
   };  

  //--------------------------------------------------
  //FSM
  //--------------------------------------------------
  logic [7:0]  byte_r;
  
  always_comb
  begin
     next_state = state;
     case (state) 
        S_WIDLENINPUT:
        begin
           if (widlen_valid_in)
               next_state = S_HEADER;
        end
        S_HEADER:
        begin
           
           if (header_count == 9'd396)
           // header_index run from 0 -> 396
              next_state = S_IDLE;
        end
        S_IDLE: 
        begin
           if (valid_in && ready_in)
           begin
              if (endtoken_i == 1'b0)
                 next_state = S_OUT;
              else 
                 next_state = S_END;
           end
        end
        S_OUT:
        begin
           if (byte_r == 8'hFF)
              next_state = S_ZEROSTUFF;
           else 
              next_state = S_IDLE;
        end
        S_ZEROSTUFF:
        begin
           next_state = S_IDLE;
        end
        S_END:
        begin
           next_state = S_END;
        end
        default: next_state = S_WIDLENINPUT;
     endcase
  end
  
  assign ready_in  = (state == S_IDLE);

  always_ff @(posedge clk)
  begin
     if (state == S_WIDLENINPUT)
     begin
        if (widlen_valid_in )
        begin
           //wid_reg represents rows || len_reg represents collumns
           wid_reg <= width;
           len_reg <= len;
        end
     end
  end
  
  always_ff @(posedge clk)
  begin
     case (state)
        S_WIDLENINPUT:
        begin
           byte_out <= byte_out;   
        end
        S_IDLE:
        begin
           byte_out <= byte_out;   
        end
        S_HEADER:
        begin
           if (header_count == 9'd163)
              byte_out  <= len_reg[15:8];
           else if (header_count == 9'd164)
              byte_out  <= len_reg[7:0];
           else if (header_count == 9'd165)
              byte_out  <= wid_reg[15:8];
           else if (header_count == 9'd166)
              byte_out  <= wid_reg[7:0];
           else 
              byte_out  <= header_table [header_count];
        end
        S_OUT:
        begin
           byte_out <= byte_r;       
        end
        S_ZEROSTUFF:
        begin
           // top 8 bits
           byte_out   <= 8'd0;   
        end
        S_END:
        begin
           case (end_count)
              0:
              begin
                 if (byte_r == 8'd0)//k can flush; chuyen den ff d8
                    byte_out <= 8'hFF;
                 else // byte_r co the bang 255 hoac bang 1 so khac
                    byte_out <= byte_r;
              end
              
              1:
              begin
                 if (byte_r == 8'd255)// can zerostuf
                    byte_out <= 8'd0;
                 else //chuyen den ff d8
                    byte_out <= 8'hFF;
              end
              
              2:
              begin
                 byte_out <= 8'hFF;
              end
              
              3:
              begin
                 byte_out <= 8'hD9;
              end
              default:
              begin
                 byte_out <= byte_out;
              end
           endcase
        end
        default:
        begin
           byte_out <= byte_out;
        end
     endcase
  end

  always_ff @(posedge clk )
  begin
     if (!reset_n)
     begin
        state        <= S_WIDLENINPUT;
        end_count    <= '0;
        header_count <= '0;
        valid_out    <= '0;
     end
     else 
     begin
        state <= next_state;
        case (state)
           S_WIDLENINPUT:
           begin
              valid_out    <= '0;
              header_count <= '0;
           end
           S_HEADER:
           begin
              valid_out <= 1'b1;
              if (header_count < 9'd396)
              begin
                 header_count <= header_count + 1;
              end
           end
           S_IDLE:
           begin
              valid_out    <= 1'b0;
              header_count <= header_count;
              if (valid_in && ready_in)
              begin
                 byte_r <= byte_in;
              end
           end
           S_OUT:
           begin
              valid_out    <= 1'b1;
              header_count <= header_count;
           end
           S_ZEROSTUFF:
           begin
              valid_out    <= 1'b1;
              header_count <= header_count; 
           end
           S_END:
           begin
              header_count <= header_count;
              case (end_count)
                 0:
                 begin
                    valid_out    <= 1'b1;
                    if (byte_r == 8'd0)
                       end_count <= 3;
                    else //if (byte_r != 8'd0)
                       end_count <= 1;
                 end
                 
                 1:
                 begin
                    valid_out    <= 1'b1;
                    if (byte_r == 8'd255)
                       end_count <= 2;
                    else //if (byte_r != 8'd255)
                       end_count <= 3;
                 end
                 
                 2:
                 begin
                    valid_out <= 1'b1;
                    end_count <= 3;
                 end
                 
                 3:
                 begin
                    valid_out <= 1'b1;
                    end_count <= 4;
                 end
                 
                 4:
                 begin
                    valid_out <= 1'b0;
                    end_count <=  4;
                 end
                 default:
                 begin
                    valid_out <= 1'b0;
                    end_count <= end_count;
                 end
              endcase
           end
        endcase
     end
  end
   
endmodule


   