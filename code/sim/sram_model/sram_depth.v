//==================================================================================================
//  Note:          Use only for teaching materials of IC Design Lab, NTHU.
//  Copyright: (c) 2022 Vision Circuits and Systems Lab, NTHU, Taiwan. ALL Rights Reserved.
//==================================================================================================

module sram_depth #(     //for activation
parameter CH_NUM = 4,
parameter ACT_PER_ADDR = 4,
parameter BW_PER_ACT = 21
)
(
input clk,
input [CH_NUM*ACT_PER_ADDR-1:0] wordmask,  //16 bits
input csb,  //chip enable
input wsb,  //write enable
input [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] wdata, //write data 336 bits
input [15:0] waddr, //write address
input [15:0] raddr, //read address

output reg [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] rdata //read data 336 bits
);

reg [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] _rdata;
reg [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] mem [0:57600-1];
wire [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] bit_mask;

assign bit_mask = {{21{wordmask[15]}}, {21{wordmask[14]}}, {21{wordmask[13]}}, {21{wordmask[12]}}, {21{wordmask[11]}}, {21{wordmask[10]}}, {21{wordmask[9]}}, {21{wordmask[8]}}, {21{wordmask[7]}}, {21{wordmask[6]}}, {21{wordmask[5]}}, {21{wordmask[4]}}, {21{wordmask[3]}}, {21{wordmask[2]}}, {21{wordmask[1]}}, {21{wordmask[0]}}};

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
            mem[i] = {16{21'b011111111111111111111}};
        end
    end
endtask

endmodule