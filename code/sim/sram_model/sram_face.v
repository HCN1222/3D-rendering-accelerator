//==================================================================================================
//  Note:          Use only for teaching materials of IC Design Lab, NTHU.
//  Copyright: (c) 2022 Vision Circuits and Systems Lab, NTHU, Taiwan. ALL Rights Reserved.
//==================================================================================================

module sram_face #(     //for activation
parameter CH_NUM = 1,
parameter ACT_PER_ADDR = 1,
parameter BW_PER_ACT = 60
)
(
input clk,
input csb,  //chip enable
input wsb,  //write enable
input [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] wdata, //write data 60 (3*20) bits
input [19:0] waddr, //write address
input [19:0] raddr, //read address

output reg [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] rdata //read data 60 (3*20) bits
);

reg [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] _rdata;
reg [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] mem [0:1048576-1];
wire [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] bit_mask;

always @(posedge clk) begin
    if(~csb && ~wsb) begin
        mem[waddr] <= wdata;
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
        for(i=0;i<1048576;i=i+1)begin
            mem[i] = 60'bX;
        end
    end
endtask

endmodule