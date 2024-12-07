
module controller(

	//input
	
	// from top
	input clk,
    input srst_n
	input enable,
	input [19:0] face_v1,
	input [19:0] face_v2,
	input [19:0] face_v3,
	input [20:0] num_of_faces,
	
	// from vertice_shader
	input [20:0] vertice1_depth_update,  // when the current use calculate done, then updated by this value 
	input [20:0] vertice2_depth_update,
	input [20:0] vertice3_depth_update,

	input [23:0] vertice1_color_update,
	input [23:0] vertice2_color_update,
	input [23:0] vertice3_color_update,

	input [11:0] screen_x1_update,
	input [11:0] screen_y1_update,

	input [11:0] screen_x2_update,
	input [11:0] screen_y2_update,

	input [11:0] screen_x3_update,
	input [11:0] screen_y3_update,

	input data_ready,
	
	//from Rasterization
	input get_next_triangle,
	
	//output
	
	// to top
	output [19:0] address_sram_get_face,
	output finish,
	
	// to vertice_shader
	output controller_signal_get,
	output [19:0] controller_which_vertice,
	output start_doing_shading,
	
	// to Rasterization
	output vertice1_depth_use,  // the current use information
	output vertice2_depth_use,
	output vertice3_depth_use,
	output vertice1_color_use,
	output vertice2_color_use,
	output vertice3_color_use,
	output screen_x1_use,
	output screen_y1_use,
	output screen_x2_use,
	output screen_y2_use,
	output screen_x3_use,
	output screen_y3_use,
	output data_ready_use




);




endmodule