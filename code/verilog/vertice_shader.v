module vertice_shader(
	//from top
	input clk,
	input srst_n,
	input enable,
	input [23:0]  eye_x,
	input [23:0] eye_y,
	input [23:0] eye_z,
	input [23:0] center_x,
	input [23:0] center_y,
	input [23:0] center_z,
	input [23:0] up_x,
	input [23:0] up_y,
	input [23:0] up_z,
	input [23:0] vertice_x,
	input [23:0] vertice_y,
	input [23:0] vertice_z,
	input [23:0] Color_v,
	
	//from controller
	input controller_signal_get,
	input [19:0] controller_which_vertice,
	input start_doing_shading,
	
	//output
	
	//to controllor
	output [20:0] vertice1_depth_update,
	output [20:0] vertice2_depth_update,
	output [20:0] vertice3_depth_update,
	output [23:0] vertice1_color_update,
	output [23:0] vertice2_color_update,
	output [23:0] vertice3_color_update,
	output [11:0] screen_x1_update,
	output [11:0] screen_y1_update,
	output [11:0] screen_x2_update,
	output [11:0] screen_y2_update,
	output [11:0] screen_x3_update,
	output [11:0] screen_y3_update,
	output data_ready,
	
	//to top
	output [19:0] address_sram_get_vertice_info
	
);

	// ********** Summary ***********
	// - Takes twelve cycles to complete
	// - The module is pipelined
	// input:
	// x, y, z: 4Q20
	// output:
	// out: 0Q24
	// ******************************
	inv_sqrt inv_sqrt(
		/*input*/ .clk(clk),
		.x( ), .y( ), .z( ),
		/*output*/ .out( )
	);

    GetMVP GetMVP(
	
	
	
	);
	
	
	matrix_multiplication matrix_multiplication(
	
	
	
	);
	
	
	DO_NDC DO_NDC(
	
	
	
	
	);
	
	ChangeToScreen ChangeToScreen(
	
	
	
	);


endmodule


