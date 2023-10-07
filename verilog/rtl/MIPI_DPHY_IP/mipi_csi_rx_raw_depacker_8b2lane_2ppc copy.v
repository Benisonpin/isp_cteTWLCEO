`timescale 1ns/1ns

/*
MIPI CSI RX to Parallel Bridge (c) by Gaurav Singh www.CircuitValley.com

MIPI CSI RX to Parallel Bridge is licensed under a
Creative Commons Attribution 3.0 Unported License.

You should have received a copy of the license along with this
work.  If not, see <http://creativecommons.org/licenses/by/3.0/>.
*/

/*
Receives 4 lane raw mipi bytes from packet decoder, rearrange bytes to output upto 8 pixel with max 16bit each 
output is few cycles delayed, because the way , MIPI RAW is packed 
output come in chunk on each clock cycle, output_valid_o remains active only while a chunk is outputted  while raw_line_o stays valid for whole line 
*/

module mipi_csi_rx_raw_depacker_8b2lane_2ppc #(parameter PIXEL_WIDTH=16)(clk_i,
										data_valid_i,
										data_i,
										packet_type_i,
										raw_line_o,
										output_valid_o,
										output_o);

localparam [7:0]MIPI_GEAR = 8;
localparam [3:0]LANES = 3'h2;
localparam [3:0]PIXEL_PER_CLK = 2;

localparam [7:0]MIPI_CSI_PACKET_10bRAW = 8'h2B;
localparam [7:0]MIPI_CSI_PACKET_12bRAW = 8'h2C;
localparam [7:0]MIPI_CSI_PACKET_14bRAW = 8'h2D;

input clk_i;
input data_valid_i;
input [((MIPI_GEAR * LANES) - 1'h1) : 0]data_i;
input [2:0]packet_type_i;

output reg output_valid_o;
output reg [((PIXEL_WIDTH * PIXEL_PER_CLK) - 1) :0]output_o;
output raw_line_o;

reg [7:0]index_table_pixel_0[3:0];
reg [7:0]index_table_pixel_1[3:0];
reg [7:0]index_table_pixel_lsb1[3:0];

reg [7:0]index_table12_pixel_0[3:0];
reg [7:0]index_table12_pixel_1[3:0];
reg [7:0]index_table12_pixel_lsb1[3:0];

reg [7:0]index_table14_pixel_0[3:0];
reg [7:0]index_table14_pixel_1[3:0];
reg [7:0]index_table14_pixel_lsb1[3:0];

reg [7:0]offset_pixel_0;
reg [7:0]offset_pixel_1;
reg [7:0]offset_pixel_lsb1;

reg [7:0]offset12_pixel_0;
reg [7:0]offset12_pixel_1;
reg [7:0]offset12_pixel_lsb1;

reg [7:0]offset14_pixel_0;
reg [7:0]offset14_pixel_1;
reg [7:0]offset14_pixel_lsb1;

reg [1:0]offset_index;

reg [((MIPI_GEAR * LANES) - 1'h1):0]last_data_i[2:0];
reg [2:0]byte_count;
reg [1:0]idle_count;

reg data_valid_reg;
reg [((MIPI_GEAR * LANES) - 1'h1):0]data_reg;
reg [2:0]burst_length_reg;
reg [1:0]idle_length_reg;
reg [2:0]packet_type_reg;

wire [2:0]burst_length;
wire [1:0]idle_length;
wire [((MIPI_GEAR * LANES * 4) - 1'h1) :0]pipe; //combined current and last input data byte, total 4 sample of input data are in pipe

reg [((PIXEL_WIDTH * PIXEL_PER_CLK) - 1'h1) :0]output_10b;
reg [((PIXEL_WIDTH * PIXEL_PER_CLK) - 1'h1) :0]output_12b;
reg [((PIXEL_WIDTH * PIXEL_PER_CLK) - 1'h1) :0]output_14b;
reg output_valid_reg;
reg output_valid_reg_2;

assign pipe = {data_reg , last_data_i[0], last_data_i[1], last_data_i[2]}; //would need last bytes as well as current data to get all pixels


//Data on mipi RAW lanes is packed, after unpacking speed grows so there is going to inactive and active part
//For RAW10 4+1 RAW12 2+1 RAW14 5+3
assign burst_length =  ((packet_type_i == (MIPI_CSI_PACKET_10bRAW & 8'h07)) || (packet_type_i == (MIPI_CSI_PACKET_14bRAW & 8'h07)))? 8'd5:8'd3;  //active + 1

assign idle_length =  ((packet_type_i == (MIPI_CSI_PACKET_10bRAW & 8'h07)) || (packet_type_i == (MIPI_CSI_PACKET_12bRAW & 8'h07)))? 2'd1: 2'd3; //inactive


assign raw_line_o = data_valid_i| output_valid_reg | output_valid_reg_2 | output_valid_o;

always @(*)
begin

        output_10b[(PIXEL_WIDTH)   +: PIXEL_WIDTH] =    {pipe [offset_pixel_1   +:8],   pipe[(offset_pixel_lsb1+2) +:2],  {(PIXEL_WIDTH - 10){1'b0}}};          //lane 2 //add ( PIXEL_WIDTH - 10 ) padding in the LSbits
        output_10b[0                       +: PIXEL_WIDTH] =    {pipe [offset_pixel_0   +:8],   pipe[offset_pixel_lsb1     +:2],  {(PIXEL_WIDTH - 10){1'b0}}};          //lane 1 first pixel on wire
        //RAW10 additional LSbits  are as follow [ pixel3 pixel2 pixel 1 pixel0]

        output_12b[(PIXEL_WIDTH)   +: PIXEL_WIDTH] =    {pipe [offset12_pixel_1 +:8],   pipe[(offset12_pixel_lsb1+4)    +:4],  {(PIXEL_WIDTH - 12){1'b0}}};
        output_12b[0                       +: PIXEL_WIDTH] =    {pipe [offset12_pixel_0 +:8],   pipe[offset12_pixel_lsb1                +:4],  {(PIXEL_WIDTH - 12){1'b0}}};             //lane 1 first pixel on wire
        //RAW12 additional LSbits  are as follow [pixel 1 pixel0]

        output_14b[(PIXEL_WIDTH)   +: PIXEL_WIDTH] =    {pipe [offset12_pixel_1 +:8],   pipe[(offset12_pixel_lsb1+4)    +:4],  {(PIXEL_WIDTH - 14){1'b0}}};
        output_14b[0                       +: PIXEL_WIDTH] =    {pipe [offset12_pixel_0 +:8],   pipe[offset12_pixel_lsb1                +:4],  {(PIXEL_WIDTH - 14){1'b0}}};             //lane 1 first pixel on wire


end

always @(posedge clk_i)
begin
        if (packet_type_reg == (MIPI_CSI_PACKET_10bRAW & 8'h07))
        begin
                output_o <= output_10b;
        end
        else if (packet_type_reg == (MIPI_CSI_PACKET_12bRAW & 8'h07))
        begin
                output_o <= output_12b;
        end
        else // if (packet_type_i == (MIPI_CSI_PACKET_14bRAW & 8'h07))
        begin
                output_o <= output_14b;
        end

end


always @(posedge clk_i)
begin

                output_valid_reg_2 <= output_valid_reg;
                output_valid_o <= output_valid_reg_2;

                if (output_valid_reg_2)
                begin
                        offset_index = offset_index + 1;
                end
                else
                begin
                        offset_index = 0;
                end

                offset14_pixel_0 <= index_table14_pixel_0[offset_index];
                offset14_pixel_1 <= index_table14_pixel_1[offset_index];
                offset14_pixel_lsb1 <= index_table14_pixel_lsb1[offset_index];

                offset12_pixel_0 <= index_table12_pixel_0[offset_index];
                offset12_pixel_1 <= index_table12_pixel_1[offset_index];
                offset12_pixel_lsb1 <= index_table12_pixel_lsb1[offset_index];

                offset_pixel_0 <= index_table_pixel_0[offset_index];
                offset_pixel_1 <= index_table_pixel_1[offset_index];
                offset_pixel_lsb1 <= index_table_pixel_lsb1[offset_index];

end

always @(posedge clk_i )
begin
	
        if (data_valid_reg)
        begin

                if (byte_count < (burst_length_reg))
                begin
                        byte_count <= byte_count + 1'd1;
                        idle_count <= idle_length_reg - 1'b1;

                        output_valid_reg <= 1'b1;

                end
                else
                begin
                        idle_count <= idle_count - 1'b1;
                        if (!idle_count)
                        begin
                                byte_count <= 4'b1;             //set to 1 to enable output_valid_o with next edge
                        end

                        output_valid_reg <= 1'h0;
                end


        end
        else
        begin

                byte_count <= burst_length;

                index_table_pixel_0[0] <= 0;
                index_table_pixel_0[1] <= 0;
                index_table_pixel_0[2] <= 8;
                index_table_pixel_0[3] <= 8;

                index_table_pixel_1[0] <= 8;
                index_table_pixel_1[1] <= 8;
                index_table_pixel_1[2] <= 16;
                index_table_pixel_1[3] <= 16;

                index_table_pixel_lsb1[0] <= 32;
                index_table_pixel_lsb1[1] <= 20;
                index_table_pixel_lsb1[2] <= 40;
                index_table_pixel_lsb1[3] <= 28;


                index_table12_pixel_0[0] <= 0;
                index_table12_pixel_0[1] <= 8;
                index_table12_pixel_0[2] <= 0;
                index_table12_pixel_0[3] <= 0;

                index_table12_pixel_1[0] <= 8;
                index_table12_pixel_1[1] <= 16;
                index_table12_pixel_1[2] <= 0;
                index_table12_pixel_1[3] <= 0;

                index_table12_pixel_lsb1[0] <= 16;
                index_table12_pixel_lsb1[1] <= 24;
                index_table12_pixel_lsb1[2] <= 0;
                index_table12_pixel_lsb1[3] <= 0;


                index_table14_pixel_0[0] <= 0;
                index_table14_pixel_0[1] <= 0;
                index_table14_pixel_0[2] <= 24;
                index_table14_pixel_0[3] <= 0;

                index_table14_pixel_1[0] <= 8;
                index_table14_pixel_1[1] <= 8;
                index_table14_pixel_1[2] <= 32;
                index_table14_pixel_1[3] <= 0;

                index_table14_pixel_lsb1[0] <= 32;
                index_table14_pixel_lsb1[1] <= 28;
                index_table14_pixel_lsb1[2] <= 0;
                index_table14_pixel_lsb1[3] <= 0;


                if (packet_type_i == (MIPI_CSI_PACKET_14bRAW & 8'h07))          // for 14bit need to wait for 3 sample while 12bit and 10bit only need 1 sample delay
                begin
                        idle_count <= 3'd2;
                end
                else
                begin
                        idle_count <= 3'b0;     //need to be zero to wait for 1 sample after data become valid
                end

                output_valid_reg <= 1'h0;
                burst_length_reg <= burst_length;
                idle_length_reg <= idle_length;
                packet_type_reg <= packet_type_i;
        end
end

always @(posedge clk_i)
begin
                data_valid_reg <= data_valid_i;
                data_reg <= data_i;

                last_data_i[0] <= data_reg;
                last_data_i[1] <= last_data_i[0];
                last_data_i[2] <= last_data_i[1];
end

endmodule
