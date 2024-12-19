//==================================================================================================
//  Note:          Use only for teaching materials of IC Design Lab, NTHU.
//  Copyright: (c) 2022 Vision Circuits and Systems Lab, NTHU, Taiwan. ALL Rights Reserved.
//==================================================================================================

module sram_screen_buffer_color #(     //for activation
parameter CH_NUM = 4,
parameter ACT_PER_ADDR = 4,
parameter BW_PER_ACT = 24
)
(
input clk,
input [CH_NUM*ACT_PER_ADDR-1:0] wordmask,  //16 bits
input csb,  //chip enable
input wsb,  //write enable
input [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] wdata, //write data 384 bits
input [15:0] waddr, //write address
input [15:0] raddr, //read address

output reg [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] rdata //read data 384 bits
);

reg [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] _rdata;
reg [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] mem [0:57600-1];
wire [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] bit_mask;

assign bit_mask = {{24{wordmask[15]}}, {24{wordmask[14]}}, {24{wordmask[13]}}, {24{wordmask[12]}}, {24{wordmask[11]}}, {24{wordmask[10]}}, {24{wordmask[9]}}, {24{wordmask[8]}}, {24{wordmask[7]}}, {24{wordmask[6]}}, {24{wordmask[5]}}, {24{wordmask[4]}}, {24{wordmask[3]}}, {24{wordmask[2]}}, {24{wordmask[1]}}, {24{wordmask[0]}}};

always @(posedge clk) begin
    if(~csb && ~wsb) begin
        mem[waddr] <= (wdata & ~(bit_mask)) | (mem[waddr] & bit_mask);
    end
end

always @(posedge clk) begin
    if(~csb) begin
        _rdata <= mem[raddr];
    end
end

always @* begin
    rdata = #(1) _rdata;
end

task load_act(
    input integer index,
    input [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] param_input
);
    mem[index] = param_input;
endtask

task reset_sram;
    integer i;
    begin
        for(i=0;i<57600;i=i+1)begin
            mem[i] = {384{1'b1}};
        end
    end
endtask

task compare_act(
    input integer index,
	input [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] golden_data,
	output reg same_or_not
);

    integer a;

    if(golden_data === mem[index]) begin
	    same_or_not = 1'b1;
	end else begin
	    same_or_not = 1'b0;
		for(a=0;a<16;a=a+1) begin
		    $display("k = %d golden RGB:%d,%d,%d",a,golden_data[(a*24+16)+:8],golden_data[(a*24+8)+:8],golden_data[a*24+:8]);
			$display("k = %d My design RGB: %d %d %d",a,mem[index][(a*24+16)+:8],mem[index][(a*24+8)+:8],mem[index][a*24+:8]);
		end
	end

endtask

    

endmodule