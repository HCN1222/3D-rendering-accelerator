
module Graphic_3Dto2D_top

(
  input clk,
  input srst_n,
  input enable,
  input [23:0] eye_x,     //4Q20
  input [23:0] eye_y,     
  input [23:0] eye_z,     
  input [23:0] center_x,  
  input [23:0] center_y,  
  input [23:0] center_z,  
  input [23:0] up_x,     
  input [23:0] up_y,     
  input [23:0] up_z,
  input [23:0] vertice_x,  //4Q20
  input [23:0] vertice_y,
  input [23:0] vertice_z,
  input [19:0] face_v1,  //20 bit
  input [19:0] face_v2,
  input [19:0] face_v3,
  input [7:0] Color_v,
  input [20:0] num_of_faces,
  input [335:0] depth_org,                          // pixel depth store in sram, 21*16 = 336 bit
  output [15:0] address_sram_CW,                    // address for Color and Weight SRAM
  output [19:0] address_sram_get_vertice_info,      // address for vertice position and its color
  output [19:0] address_sram_get_face,              // address for faces information
  output [383:0] Color_RGB_combine,                 // 8*3 = 24 bit, 24*16 = 384 bit
  output [335:0] depth_after,
  output finish,
  
  output write_enable_sram_CW;
  output write_enable_sram_get_vertice_info,    //1'b1
  output address_sram_get_face  //1'b1
  
  output [15:0] write_wordmask_sram_CW;
  output [15:0] write_wordmask_sram_get_vertice_info,  //16'b1111111111111111
  output [15:0] write_wordmask_sram_get_face           //16'b1111111111111111
  
);


reg enable_reg;
reg [23:0] eye_x_reg;     //4Q20
reg [23:0] eye_y_reg;     
reg [23:0] eye_z_reg;     
reg [23:0] center_x_reg ; 
reg [23:0] center_y_reg ; 
reg [23:0] center_z_reg ; 
reg [23:0] up_x_reg;     
reg [23:0] up_y_reg;     
reg [23:0] up_z_reg;
reg [23:0] vertice_x_reg;  //4Q20
reg [23:0] vertice_y_reg;  //4Q20
reg [23:0] vertice_z_reg;  //4Q20
reg [19:0] face_v1_reg;  //20 bit
reg [19:0] face_v2_reg;
reg [19:0] face_v3_reg;
reg [7:0] Color_v_reg;
reg [335:0] depth_org_reg;
reg [20:0] num_of_faces_reg;


wire controller_signal_get;
wire [19:0] controller_which_vertice;
wire start_doing_shading;

wire [20:0] vertice1_depth_update;
wire [20:0] vertice2_depth_update;
wire [20:0] vertice3_depth_update;
wire [7:0] vertice1_color_update;
wire [7:0] vertice2_color_update;
wire [7:0] vertice3_color_update;
wire [11:0] screen_x1_update;     //12Q0
wire [11:0] screen_y1_update;
wire [11:0] screen_x2_update;
wire [11:0] screen_y2_update;
wire [11:0] screen_x3_update;
wire [11:0] screen_y3_update;
wire  data_ready;

wire [20:0] vertice1_depth_use;
wire [20:0] vertice2_depth_use;
wire [20:0] vertice3_depth_use;
wire [7:0] vertice1_color_use;
wire [7:0] vertice2_color_use;
wire [7:0] vertice3_color_use;
wire [11:0] screen_x1_use;     //12Q0
wire [11:0] screen_y1_use;
wire [11:0] screen_x2_use;
wire [11:0] screen_y2_use;
wire [11:0] screen_x3_use;
wire [11:0] screen_y3_use;

wire get_next_triangle;

    vertice_shader vertice_shader
	(
	
	//input
	
	//from top
	.clk(clk),
	.srst_n(srst_n),
	.enable(enable_reg),
	.eye_x(eye_x_reg),
	.eye_y(eye_y_reg),
	.eye_z(eye_z_reg),
	.center_x(center_x_reg),
	.center_y(center_y_reg),
	.center_z(center_z_reg),
	.up_x(up_x_reg),
	.up_y(up_y_reg),
	.up_z(up_z_reg),
	.vertice_x(vertice_x_reg),
	.vertice_y(vertice_y_reg),
	.vertice_z(vertice_z_reg),
	.Color_v(Color_v_reg),
	
	//from controller
	.controller_signal_get(controller_signal_get),
	.controller_which_vertice(controller_which_vertice),
	.start_doing_shading(start_doing_shading),
	
	//output
	
	//to controllor
	.vertice1_depth_update(vertice1_depth_update),
	.vertice2_depth_update(vertice2_depth_update),
	.vertice3_depth_update(vertice3_depth_update),
	.vertice1_color_update(vertice1_color_update),
	.vertice2_color_update(vertice2_color_update),
	.vertice3_color_update(vertice3_color_update),
	.screen_x1_update(screen_x1_update),
	.screen_y1_update(screen_y1_update),
	.screen_x2_update(screen_x2_update),
	.screen_y2_update(screen_y2_update),
	.screen_x3_update(screen_x3_update),
	.screen_y3_update(screen_y3_update),
	.data_ready(data_ready),
	
	//to top
	.address_sram_get_vertice_info(address_sram_get_vertice_info)
	
	
	);


    controller  controller
	(
	
	//input
	
	// from top
	.clk(clk),
	.srst_n(srst_n),
	.enable(enable_reg),
	.face_v1(face_v1_reg),
	.face_v2(face_v2_reg),
	.face_v3(face_v3_reg),
	.num_of_faces(num_of_faces_reg),
	
	// from vertice_shader
	.vertice1_depth_update(vertice1_depth_update),  // when the current use calculate done, then updated by this value 
	.vertice2_depth_update(vertice2_depth_update),
	.vertice3_depth_update(vertice3_depth_update),
	.vertice1_color_update(vertice1_color_update),
	.vertice2_color_update(vertice2_color_update),
	.vertice3_color_update(vertice3_color_update),
	.screen_x1_update(screen_x1_update),
	.screen_y1_update(screen_y1_update),
	.screen_x2_update(screen_x2_update),
	.screen_y2_update(screen_y2_update),
	.screen_x3_update(screen_x3_update),
	.screen_y3_update(screen_y3_update),
	.data_ready(data_ready),
	
	//from Rasterization
	.get_next_triangle(get_next_triangle),
	
	//output
	
	// to top
	.address_sram_get_face(address_sram_get_face),
	.finish(finish),
	
	// to vertice_shader
	.controller_signal_get(controller_signal_get),
	.controller_which_vertice(controller_which_vertice),
	.start_doing_shading(start_doing_shading),
	
	// to Rasterization
	.vertice1_depth_use(vertice1_depth_use),  // the current use information
	.vertice2_depth_use(vertice2_depth_use),
	.vertice3_depth_use(vertice3_depth_use),
	.vertice1_color_use(vertice1_color_use),
	.vertice2_color_use(vertice2_color_use),
	.vertice3_color_use(vertice3_color_use),
	.screen_x1_use(screen_x1_use),
	.screen_y1_use(screen_y1_use),
	.screen_x2_use(screen_x2_use),
	.screen_y2_use(screen_y2_use),
	.screen_x3_use(screen_x3_use),
	.screen_y3_use(screen_y3_use),
	.data_ready_use(data_ready_use)
	
	);
	
	
	Rasterization Rasterization
	(
	//input
	
	// from top
	.clk(clk),
	.srst_n(srst_n),
	.depth_org(depth_org_reg),    // pixel original depth
	
	
	//from controller
	.vertice1_depth(vertice1_depth_use),  // the current use information
	.vertice2_depth(vertice2_depth_use),
	.vertice3_depth(vertice3_depth_use),
	.vertice1_color(vertice1_color_use),
	.vertice2_color(vertice2_color_use),
	.vertice3_color(vertice3_color_use),
	.screen_x1(screen_x1_use),
	.screen_y1(screen_y1_use),
	.screen_x2(screen_x2_use),
	.screen_y2(screen_y2_use),
	.screen_x3(screen_x3_use),
	.screen_y3(screen_y3_use),
	.data_ready(data_ready_use),
	
	//output
	
	// to top
	.address_sram_CW(address_sram_CW),
	.Color_RGB_combine(Color_RGB_combine),
	.write_enable_sram_CW(write_enable_sram_CW),
	.write_wordmask_sram_CW(write_wordmask_sram_CW),
	.depth_after(depth_after),
	
	// to controller
	.get_next_triangle(get_next_triangle)
	
	);

    
	always@(posedge clk) begin
		enable_reg <= enable;
		eye_x_reg  <= eye_x;
		eye_y_reg   <= eye_y;
		eye_z_reg    <= eye_z;
		center_x_reg <= center_x;
		center_y_reg <= center_y;
		center_z_reg <= center_z;
		up_x_reg    <= up_x;
		up_y_reg    <= up_y;
		up_z_reg    <= up_z;
		vertice_x_reg<= vertice_x;
		vertice_y_reg<= vertice_y;
		vertice_z_reg<= vertice_z;
		face_v1_reg <= face_v1;
		face_v2_reg<= face_v2;
		face_v3_reg<= face_v3;
		Color_v_reg<= Color_v;
		depth_org_reg<= depth_org;
		num_of_faces_reg <= num_of_faces;
	end



endmodule



module vertice_shader(








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



module controller(





);




endmodule


module Rasterization(





);


    InTriangle InTriangle(
	
	
	
	
	);
	
	
	GetColorDepth GetColorDepth(
	
	
	
	
	
	);

endmodule
