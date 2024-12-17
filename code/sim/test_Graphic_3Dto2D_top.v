
`timescale 1ns/100ps


module test_Graphic_3Dto2D_top;

`define CYCLE 10
`define END_CYCLES 200000

reg clk;
reg srst_n;
reg enable;
reg [23:0] eye_x;     //4Q20
reg [23:0] eye_y;     
reg [23:0] eye_z;     
reg [23:0] center_x;  
reg [23:0] center_y;  
reg [23:0] center_z;  
reg [23:0] up_x;     
reg [23:0] up_y;    
reg [23:0] up_z;
reg [23:0] vertice_x;  //4Q20
reg [23:0] vertice_y;
reg [23:0] vertice_z;
reg [19:0] face_v1;  //20 bit
reg [19:0] face_v2;
reg [19:0] face_v3;
reg [23:0] Color_v;
reg [19:0] num_of_faces;
wire [335:0] depth_org;                          // pixel depth store in sram, 21*16 = 336 bit
wire [15:0] read_address_sram_CD;                    // address for Color and depth SRAM
wire [15:0] write_address_sram_CD;                    // address for Color and depth SRAM
wire [19:0] address_sram_get_vertice_info;      // address for vertice position and its color
wire [19:0] address_sram_get_face;              // address for faces information
wire [383:0] Color_RGB_combine;                 // 8*3 = 24 bit, 24*16 = 384 bit
wire [335:0] depth_after;
wire finish;
  
wire write_enable_sram_CD;
wire [15:0] write_wordmask_sram_CD;

wire [59:0] face_comb;
wire [71:0] vertex_comb;
wire [23:0] Color_temp;

always@* begin

    vertice_x = vertex_comb[71:48];
	vertice_y = vertex_comb[47:24];
	vertice_z = vertex_comb[23:0];
	
	face_v1 = face_comb[59:40];
	face_v2 = face_comb[39:20];
	face_v3 = face_comb[19:0];
	
	Color_v = Color_temp;

end

sram_depth sram_depth(
.clk(clk),
.wordmask(write_wordmask_sram_CD), // 16 bits
.csb(1'b0),
.wsb(write_enable_sram_CD),      // write enable
.wdata(depth_after),    // 336 bits
.waddr(write_address_sram_CD),    // 16 bits
.raddr(read_address_sram_CD),    // 16 bits
.rdata(depth_org)     // 336 bits
);

sram_screen_buffer_color sram_screen_buffer_color(
.clk(clk),
.wordmask(write_wordmask_sram_CD), // 16 bits
.csb(1'b0),
.wsb(write_enable_sram_CD),      // write enable
.wdata(Color_RGB_combine),    // 384 bits
.waddr(write_address_sram_CD),    // 16 bits
.raddr(read_address_sram_CD),    // 16 bits
.rdata()     // 384 bits, used in after finish verification
);

sram_face sram_face(
.clk(clk),
.csb(1'b0),
.wsb(1'b1),
.wdata(60'd0),
.waddr(20'd0),
.raddr(address_sram_get_face), 
.rdata(face_comb)
);

sram_vertex_color sram_vertex_color(
.clk(clk),
.csb(1'b0),
.wsb(1'b1),
.wdata(24'd0),
.waddr(20'd0),
.raddr(address_sram_get_vertice_info),
.rdata(Color_temp)
);

sram_vertex_position sram_vertex_position(
.clk(clk),
.csb(1'b0),
.wsb(1'b1),
.wdata(72'd0),
.waddr(20'd0),
.raddr(address_sram_get_vertice_info),
.rdata(vertex_comb)
);

Graphic_3Dto2D_top Graphic_3Dto2D_top(
.clk(clk),
.srst_n(srst_n),
.enable(enable),
.eye_x(eye_x),     //4Q20
.eye_y(eye_y),     
.eye_z(eye_z),     
.center_x(center_x),  
.center_y(center_y),  
.center_z(center_z),  
.up_x(up_x),     
.up_y(up_y),     
.up_z(up_z),
.vertice_x(vertice_x),  //4Q20
.vertice_y(vertice_y),
.vertice_z(vertice_z),
.face_v1(face_v1),  //20 bit
.face_v2(face_v2),
.face_v3(face_v3),
.Color_v(Color_v),
.num_of_faces(num_of_faces),
.depth_org(depth_org),                          // pixel depth store in sram, 21*16 = 336 bit
.read_address_sram_CD(read_address_sram_CD),                    // address for Color and Weight SRAM
.write_address_sram_CD(write_address_sram_CD),
.address_sram_get_vertice_info(address_sram_get_vertice_info),      // address for vertice position and its color
.address_sram_get_face(address_sram_get_face),              // address for faces information
.Color_RGB_combine(Color_RGB_combine),                 // 8*3 = 24 bit, 24*16 = 384 bit
.depth_after(depth_after),
.finish(finish),
.write_enable_sram_CD(write_enable_sram_CD),
.write_wordmask_sram_CD(write_wordmask_sram_CD)
);

reg [59:0] faces_array [0:1048576-1];
reg [71:0] vertices_position_array [0:1048576-1];
reg [23:0] vertices_color_array [0:1048576-1];

integer i;
integer j;
integer k;

task initialize_sram_data;
    begin
	    $readmemb("sw/faces_array.dat", faces_array);
	    $readmemb("sw/vertices_position_array.dat", vertices_position_array);
		$readmemb("sw/vertices_color_array.dat", vertices_color_array);
		
		sram_depth.reset_sram;
		sram_screen_buffer_color.reset_sram;
		sram_face.reset_sram;
		sram_vertex_position.reset_sram;
		sram_vertex_color.reset_sram;
		
		for(i=0;i<1048576;i=i+1) begin
		    sram_face.load_act(i, faces_array[i]);
		end
		
		for(i=0;i<1048576;i=i+1) begin
		    sram_vertex_position.load_act(i,vertices_position_array[i]);
		end
		
		for(i=0;i<1048576;i=i+1) begin
		    sram_vertex_color.load_act(i,vertices_color_array[i]);
		end
		
	end
endtask

reg same_or_not_o [0:57599];
reg [383:0] screen_space_array[0:57599]; 

task verification;
    begin
		$readmemb("sw/screen_space.dat", screen_space_array);
		
		for(k=0;k<57600;k=k+1) begin
			sram_screen_buffer_color.compare_act(k,screen_space_array[k],same_or_not_o[k]);
			if(same_or_not_o[k] !== 1'b1) begin
				$display("address %d false",k);
				$finish;
			end
		end

		$display("success!");
    end
endtask

initial begin
    clk = 0;
    while(1) #(`CYCLE/2) clk = ~clk;
end

initial begin

    for(j=0;j<1;j=j+1) begin
	
	    initialize_sram_data;
		
	    srst_n = 1'b1;
        enable = 0;
		
	    eye_x = 24'd4194304;
		eye_y = 24'd4194304;
		eye_z = 24'd4194304;
		center_x = 24'd0;
		center_y = 24'd0;
		center_z = 24'd0;
		up_x = 24'd0;
		up_y = 24'd1048576;
		up_z = 24'd0;
	    num_of_faces = 20'd12;
		
        @(negedge clk); srst_n = 1'b0;
        @(negedge clk); srst_n = 1'b1; enable = 1'b1;
        @(negedge clk); enable = 1'b0;
	
	    wait(finish);
		
		@(negedge clk);
		
		verification;
		
	end
	
	$finish;

end

initial begin
  #(`CYCLE * `END_CYCLES);
    $display("\n========================================================");
    $display("   Error!!! Simulation time is too long...            ");
    $display("   There might be something wrong in your code.       ");
    $display("   If your design really needs such a long time,      ");
    $display("   increase the END_CYCLES setting in the testbench.  ");
    $display("========================================================");
    $finish;
end

initial begin
	$fsdbDumpfile("final_sim.fsdb");
	$fsdbDumpvars("+mda");
end

endmodule