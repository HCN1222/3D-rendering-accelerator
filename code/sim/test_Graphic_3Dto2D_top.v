
`timescale 1ns/100ps


module test_Graphic_3Dto2D_top;

`define CYCLE 10
`define END_CYCLES 20000000

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

Graphic_3Dto2D_top Graphic_3Dto2D_top_U0(
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
	
		`ifdef BOX
			$readmemb("sw/TP/box_0_faces_array.dat", faces_array);
			$readmemb("sw/TP/box_0_vertices_position_array.dat", vertices_position_array);
			$readmemb("sw/TP/box_0_vertices_color_array.dat", vertices_color_array);
		`endif
		
		`ifdef ELEPHANT
			$readmemb("sw/TP/elephant_0_faces_array.dat", faces_array);
			$readmemb("sw/TP/elephant_0_vertices_position_array.dat", vertices_position_array);
			$readmemb("sw/TP/elephant_0_vertices_color_array.dat", vertices_color_array);
		`endif
		
		`ifdef DRAGON
			$readmemb("sw/TP/dragon_0_faces_array.dat", faces_array);
			$readmemb("sw/TP/dragon_0_vertices_position_array.dat", vertices_position_array);
			$readmemb("sw/TP/dragon_0_vertices_color_array.dat", vertices_color_array);
		`endif
		
		`ifdef TEAPOT
			$readmemb("sw/TP/teapot_0_faces_array.dat", faces_array);
			$readmemb("sw/TP/teapot_0_vertices_position_array.dat", vertices_position_array);
			$readmemb("sw/TP/teapot_0_vertices_color_array.dat", vertices_color_array);
		`endif
		
		`ifdef BUNNY
			$readmemb("sw/TP/bunny_0_faces_array.dat", faces_array);
			$readmemb("sw/TP/bunny_0_vertices_position_array.dat", vertices_position_array);
			$readmemb("sw/TP/bunny_0_vertices_color_array.dat", vertices_color_array);
		`endif
		
        `ifdef ATHENA
			$readmemb("sw/TP/athena_0_faces_array.dat", faces_array);
			$readmemb("sw/TP/athena_0_vertices_position_array.dat", vertices_position_array);
			$readmemb("sw/TP/athena_0_vertices_color_array.dat", vertices_color_array);
		`endif
	
		
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
			
			`ifdef ATHENA
				`ifdef PAT1
					$readmemb("sw/TP/athena_0_screen_space.dat", screen_space_array);
				`elsif PAT2
					$readmemb("sw/TP/athena_1_screen_space.dat", screen_space_array);
				`endif
			`endif

			`ifdef BOX
				`ifdef PAT1
					$readmemb("sw/TP/box_0_screen_space.dat", screen_space_array);
				`elsif PAT2
					$readmemb("sw/TP/box_1_screen_space.dat", screen_space_array);
				`endif
			`endif

			`ifdef BUNNY
				`ifdef PAT1
					$readmemb("sw/TP/bunny_0_screen_space.dat", screen_space_array);
				`elsif PAT2
					$readmemb("sw/TP/bunny_1_screen_space.dat", screen_space_array);
				`endif
			`endif 
			
			`ifdef DRAGON
				`ifdef PAT1
					$readmemb("sw/TP/dragon_0_screen_space.dat", screen_space_array);
				`elsif PAT2
					$readmemb("sw/TP/dragon_1_screen_space.dat", screen_space_array);
				`endif
			`endif

			`ifdef ELEPHANT
				`ifdef PAT1
					$readmemb("sw/TP/elephant_0_screen_space.dat", screen_space_array);
				`elsif PAT2
					$readmemb("sw/TP/elephant_1_screen_space.dat", screen_space_array);
				`endif
			`endif

			`ifdef TEAPOT
				`ifdef PAT1
					$readmemb("sw/TP/teapot_0_screen_space.dat", screen_space_array);
				`elsif PAT2
					$readmemb("sw/TP/teapot_1_screen_space.dat", screen_space_array);
				`endif
			`endif
				
		for(k=0;k<57600;k=k+1) begin
			sram_screen_buffer_color.compare_act(k,screen_space_array[k],same_or_not_o[k]);
			if(same_or_not_o[k] !== 1'b1) begin
				$display("Error, address %d false",k);
				$finish;
			end else begin
			    // $display("address %d pass",k);
			end
		end
		
		`ifdef POSTSIM
            $display("POSTSIM_PASS: HA HA HA, 3D Model mesh to 2D screen buffer success!!");
		`elsif GATESIM
		    $display("GATESIM_PASS: HA HA HA, 3D Model mesh to 2D screen buffer success!!");
		`else
		    $display("PRESIM_PASS: HA HA HA, 3D Model mesh to 2D screen buffer success!!");
		`endif

    end
endtask

initial begin
    clk = 0;
    while(1) #(`CYCLE/2) clk = ~clk;
end

//always #(`CYCLE/2) clk = ~clk;

initial begin

    for(j=0;j<1;j=j+1) begin
	
	    initialize_sram_data;
		
	    srst_n = 1'b1;
        enable = 0;
		`ifdef ATHENA
			
				num_of_faces = 20'd1121;
				
				`ifdef PAT1
					eye_x = 24'd373293;
					eye_y = 24'd365953;
					eye_z = 24'd6520046;
				`elsif PAT2
					eye_x = 24'd5376049;
					eye_y = 24'd6645875;
					eye_z = 24'd5682233;
				`else
					eye_x = 24'd0;
					eye_y = 24'd0;
					eye_z = 24'd0;
					$display("You need to define PAT1 or PAT2, test finish");
					$finish;
				`endif
			`endif
			
			`ifdef BOX
			
				num_of_faces = 20'd12;
				
				`ifdef PAT1
					eye_x = 24'd6137315;
					eye_y = 24'd5480907;
					eye_z = 24'd5888803;
				`elsif PAT2
					eye_x = 24'd5176820;
					eye_y = 24'd4633657;
					eye_z = 24'd4442817;
				`else
					eye_x = 24'd0;
					eye_y = 24'd0;
					eye_z = 24'd0;
					$display("You need to define PAT1 or PAT2, test finish");
					$finish;
				`endif
			`endif
			
			`ifdef BUNNY
			
				num_of_faces = 20'd2915;
				
				`ifdef PAT1
					eye_x = 24'd7065305;
					eye_y = 24'd4348445;
					eye_z = 24'd6628049;
				`elsif PAT2
					eye_x = 24'd5807014;
					eye_y = 24'd3396338;
					eye_z = 24'd4736418;
				`else
					eye_x = 24'd0;
					eye_y = 24'd0;
					eye_z = 24'd0;
					$display("You need to define PAT1 or PAT2, test finish");
					$finish;
				`endif
			`endif
			
			`ifdef DRAGON
			
				num_of_faces = 20'd2730;
				
				`ifdef PAT1
					eye_x = 24'd452985;
					eye_y = 24'd668991;
					eye_z = 24'd5449449;
				`elsif PAT2
					eye_x = 24'd5071962;
					eye_y = 24'd273678;
					eye_z = 24'd4961862;
				`else
					eye_x = 24'd0;
					eye_y = 24'd0;
					eye_z = 24'd0;
					$display("You need to define PAT1 or PAT2, test finish");
					$finish;
				`endif
			`endif
			
			`ifdef ELEPHANT
			
				num_of_faces = 20'd1148;
				
				`ifdef PAT1
					eye_x = 24'd5627707;
					eye_y = 24'd3280994;
					eye_z = 24'd4752146;
				`elsif PAT2
					eye_x = 24'd4653580;
					eye_y = 24'd6042943;
					eye_z = 24'd4381999;
				`else
					eye_x = 24'd0;
					eye_y = 24'd0;
					eye_z = 24'd0;
					$display("You need to define PAT1 or PAT2, test finish");
					$finish;
				`endif
			`endif
			
			`ifdef TEAPOT
			
				num_of_faces = 20'd2256;
				
				`ifdef PAT1
					eye_x = 24'd5372903;
					eye_y = 24'd5272240;
					eye_z = 24'd5204083;
				`elsif PAT2
					eye_x = 24'd5015339;
					eye_y = 24'd4369416;
					eye_z = 24'd5796528;
				`else
					eye_x = 24'd0;
					eye_y = 24'd0;
					eye_z = 24'd0;
					$display("You need to define PAT1 or PAT2, test finish");
					$finish;
				`endif
			`endif
		
	    
		center_x = 24'd0;
		center_y = 24'd0;
		center_z = 24'd0;
		up_x = 24'd0;
		up_y = 24'd1048576;
		up_z = 24'd0;
	    
		
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

integer current_cycle;
initial begin
	current_cycle = 0;
	while (1) begin
		@(posedge clk);
		current_cycle = current_cycle + 1;
		if (current_cycle % 100 == 0)
			$display("cycle: %d, I'm still alive :). weeeeeee", current_cycle);
	end
end

initial begin

    `ifdef POSTSIM
	
		`ifdef DUMPFILE
			$fsdbDumpfile("postsim.fsdb");
			$fsdbDumpvars("+mda", Graphic_3Dto2D_top_U0);
		`endif
		
		$sdf_annotate("../APR_85/innovus/post_layout/CHIP.sdf", Graphic_3Dto2D_top_U0);
		
	`elsif GATESIM
	
		`ifdef DUMPFILE
			$fsdbDumpfile("gatesim.fsdb");
			$fsdbDumpvars("+mda", Graphic_3Dto2D_top_U0);
		`endif
		
		 $sdf_annotate("../syn/netlist/Graphic_3Dto2D_top_syn.sdf",Graphic_3Dto2D_top_U0);
		 
	`else
	
		`ifdef DUMPFILE
			$fsdbDumpfile("presim.fsdb");
			$fsdbDumpvars("+mda",Graphic_3Dto2D_top_U0);
		`endif
		
	`endif

end

endmodule
