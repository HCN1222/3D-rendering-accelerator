
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
  input [23:0] Color_v,
  input [20:0] num_of_faces,
  input [335:0] depth_org,                          // pixel depth store in sram, 21*16 = 336 bit
  output [15:0] address_sram_CD,                    // address for Color and Weight SRAM
  output [19:0] address_sram_get_vertice_info,      // address for vertice position and its color
  output [19:0] address_sram_get_face,              // address for faces information
  output [383:0] Color_RGB_combine,                 // 8*3 = 24 bit, 24*16 = 384 bit
  output [335:0] depth_after,
  output finish,
  
  output write_enable_sram_CD;
  output write_enable_sram_get_vertice_info,    //1'b1
  output address_sram_get_face  //1'b1
  
  output [15:0] write_wordmask_sram_CD;
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
reg [23:0] Color_v_reg;
reg [335:0] depth_org_reg;
reg [20:0] num_of_faces_reg;


wire controller_signal_get;
wire [19:0] controller_which_vertice;
wire start_doing_shading;

wire [20:0] vertice1_depth_update;
wire [20:0] vertice2_depth_update;
wire [20:0] vertice3_depth_update;
wire [23:0] vertice1_color_update;
wire [23:0] vertice2_color_update;
wire [23:0] vertice3_color_update;
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
wire [23:0] vertice1_color_use;
wire [23:0] vertice2_color_use;
wire [23:0] vertice3_color_use;
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
	.address_sram_CD(address_sram_CD),
	.Color_RGB_combine(Color_RGB_combine),
	.write_enable_sram_CD(write_enable_sram_CD),
	.write_wordmask_sram_CD(write_wordmask_sram_CD),
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

	//input
	
	// from top
	input clk,
	input srst_n,
	input [335:0] depth_org,    // pixel original depth
	
	//from controller
	input [20:0] vertice1_depth,  // the current use information
	input [20:0] vertice2_depth,
	input [20:0] vertice3_depth,
	input [23:0] vertice1_color,
	input [23:0] vertice2_color,
	input [23:0] vertice3_color,
	input [11:0] screen_x1,
	input [11:0] screen_y1,
	input [11:0] screen_x2,
	input [11:0] screen_y2,
	input [11:0] screen_x3,
	input [11:0] screen_y3,
	input data_ready,
	
	//output
	// to top
	output reg  [15:0] read_address_sram_CD,
	output reg  [15:0] write_address_sram_CD, 
	
	output  [383:0] Color_RGB_combine,
	output reg  write_enable_sram_CD,
	output reg [15:0] write_wordmask_sram_CD,
	output  [335:0] depth_after,
	
	// to controller
	output reg get_next_triangle

);

parameter initial_or_finish_triangle = 2'b00;
parameter set = 2'b01;
parameter compute = 2'b10;
parameter wait_pipeline_result = 2'b11;
	
reg [1:0] state;
reg [1:0] next_state;

reg signed [11:0] temp_start_x;
reg signed [11:0] temp_start_y;

reg signed [11:0] temp_end_x;
reg signed [11:0] temp_end_y;

reg signed [11:0] next_start_x;
reg signed [11:0] next_start_y;

reg signed [11:0] next_end_x;
reg signed [11:0] next_end_y;

reg signed [11:0] start_x;
reg signed [11:0] start_y;

reg signed [11:0] end_x;
reg signed [11:0] end_y;

reg [3:0] next_counter;
reg [3:0] counter;

reg [3:0] next_cnt;
reg [3:0] cnt;

reg signed [11:0] Ax;
reg signed [11:0] Bx;
reg signed [11:0] Cx;
reg signed [11:0] Ay;
reg signed [11:0] By;
reg signed [11:0] Cy;

reg [15:0] next_read_address_sram_CD;
reg [15:0] next_write_address_sram_CD;

reg next_write_enable_sram_CD;
reg next_write_wordmask_sram_CD;

reg [15:0] next_addr_pipe1;
reg [15:0] addr_pipe1;
reg [15:0] addr_pipe2;
reg [15:0] addr_pipe3;
reg [15:0] addr_pipe4;
reg [15:0] addr_pipe5;
reg [15:0] addr_pipe6;
reg [15:0] addr_pipe7;
reg [15:0] addr_pipe8;
reg [15:0] addr_pipe9;
reg [15:0] addr_pipe10;

reg [15:0] temp_address;
reg [15:0] next_record;
reg [15:0] record;

wire not_draw_array[0:15];
wire in_triangle_array[0:15];
wire signed [20:0] depth_s_org [0:15];
wire signed [20:0] depth_s_after [0:15];

reg next_get_next_triangle;
reg signed [11:0] next_current_x;
reg signed [11:0] next_current_y;
reg signed [11:0] current_x;
reg signed [11:0] current_y;


always@(posedge clk) begin
    if(~srst_n) begin
	    state <= initial_or_finish_triangle;
	    current_x <= 0;
		current_y <= 0;
        record <= 0;
		cnt <= 0;
		counter <= 0; 
	end else begin
        state <= next_state;
	    current_x <= next_current_x;
		current_y <= next_current_y;
        record <= next_record;
		cnt <= next_cnt;
		counter <= next_counter;
	end
end


always@(posedge clk) begin

    addr_pipe1 <= next_addr_pipe1;
	addr_pipe2 <= addr_pipe1;
	addr_pipe3 <= addr_pipe2;
	addr_pipe4 <= addr_pipe3;
	addr_pipe5 <= addr_pipe4;
	addr_pipe6 <= addr_pipe5;
	addr_pipe7 <= addr_pipe6;
	addr_pipe8 <= addr_pipe7;
	addr_pipe9 <= addr_pipe8;
	addr_pipe10 <= addr_pipe9;
	write_address_sram_CD <= next_write_address_sram_CD;
	read_address_sram_CD <= next_read_address_sram_CD;
	write_enable_sram_CD <= next_write_enable_sram_CD;
	write_wordmask_sram_CD <= next_write_wordmask_sram_CD;
	start_x <= next_start_x;
	start_y <= next_start_y;
	end_x <= next_end_x;
	end_y <= next_end_y;
	get_next_triangle <= next_get_next_triangle;
end

always@* begin
    
    Ax = screen_x1;
    Bx = screen_x2;
    Cx = screen_x3;

    if(Ax>=Bx && Ax>=Cx) begin
        //max_index = 0;
		temp_end_x = Ax;
    end else if(Bx>=Ax && Bx>=Cx) begin
        //max_index = 1;
		temp_end_x = Bx;
    end else if(Cx>=Ax && Cx>=Bx) begin
        //max_index = 2;
		temp_end_x = Cx;
    end else begin
        //max_index = 0;
		temp_end_x = 0;
    end


    if(Cx<=Ax && Cx<=Bx) begin
        //min_index = 2;
		temp_start_x = Cx;
    end else if(Bx<=Ax && Bx<=Cx) begin
        //min_index = 1;
		temp_start_x = Bx;
    end else if(Ax<=Bx && Ax<=Cx) begin
        //min_index = 0;
		temp_start_x = Ax;
    end else begin
        //min_index = 0;
		temp_start_x = 0;
    end
	
	Ay = screen_y1;
    By = screen_y2;
    Cy = screen_y3;

    if(Ay>=By && Ay>=Cy) begin
        //max_index = 0;
		temp_end_y = Ay;
    end else if(By>=Ay && By>=Cy) begin
        //max_index = 1;
		temp_end_y = By;
    end else if(Cy>=Ay && Cy>=By) begin
        //max_index = 2;
		temp_end_y = Cy;
    end else begin
        //max_index = 0;
		temp_end_y = 0;
    end


    if(Cy<=Ay && Cy<=By) begin
        //min_index = 2;
		temp_start_y = Cy;
    end else if(By<=Ay && By<=Cy) begin
        //min_index = 1;
		temp_start_y = By;
    end else if(Ay<=By && Ay<=Cy) begin
        //min_index = 0;
		temp_start_y = Ay;
    end else begin
        //min_index = 0;
		temp_start_y = 0;
    end
	
	next_start_x = (temp_start_x[11:2])*4;
	next_start_y = (temp_start_y[11:2])*4;
	
	next_end_x = (temp_end_x[11:2])*4;
	next_end_y = (temp_end_y[11:2])*4;

end

always@* begin

    if(state == compute || state == wait_pipeline_result) begin
	    next_read_address_sram_CD = addr_pipe7;
	end else begin
	    next_read_address_sram_CD = 0;
	end

end

always@* begin

    if(state == set || state == compute || state == wait_pipeline_result) begin
	    if(counter == 10) begin
		    next_counter = counter;
		end else begin
		    next_counter = counter + 1;
		end
	end else begin
	    next_counter = 0;
	end

end 

always@* begin
    if(counter == 10 && state!= initial_or_finish_triangle) begin
	    // distinguish write or not
		next_write_address_sram_CD = addr_pipe10;
		next_write_enable_sram_CD = 1'b0;
		for(i=0;i<=15;i=i+1) begin
		    depth_s_org[i] = depth_org[i*21+:21];
			depth_s_after[i] = depth_after[i*21+:21];
		    if( depth_s_after[i] < depth_s_org[i] && in_triangle_array[i]==1'b1 && not_draw_array[i] == 1'b0) begin
			    next_write_wordmask_sram_CD[i] = 1'b0;
			end else begin
			    next_write_wordmask_sram_CD[i] = 1'b1;
			end
		end 
	end else begin
	    // do not need to write
		next_write_address_sram_CD = addr_pipe10;
		next_write_enable_sram_CD = 1'b1;
		next_write_wordmask_sram_CD = 16'b1111111111111111;
	end

end

always@* begin
    next_addr_pipe1 = temp_address;
end

always@* begin
    
    case(state)
        initial_or_finish_triangle: begin
		
		    if(data_ready) begin
			    next_get_next_triangle = 1'b0;
				next_state = compute;
			end else begin
		        next_get_next_triangle = 1'b1;
				next_state = state;
		    end
			
			next_current_x = 0;
			next_current_y = 0;
			temp_address = 0;
			next_record = 0;
			next_cnt = 0;
		
		end
		set: begin
		    next_current_x = start_x;
			next_current_y = start_y;
			temp_address = start_x[11:2] + 320*(start_y[11:2]);
			next_record = start_x[11:2] + 320*(start_y[11:2]);
	        next_state = compute;
			next_cnt = 0;
			next_get_next_triangle = 1'b0;
			
		end
		compute: begin
		
		    if( (current_x + 4 > end_x) && (current_y + 4 > end_y) ) begin
			    next_state = wait_pipeline_result;
				next_current_x = current_x;
				next_current_y = current_y;
				temp_address = 0;
				next_record = record;
			end else if( (current_x + 4 > end_x) && !(current_y + 4 > end_y) ) begin
			    next_state = state;
				next_current_x = start_x;
				next_current_y = current_y + 4;
				temp_address = record + 320;
				next_record = record + 320;
			end else begin
			    next_state = state;
				next_current_x = current_x + 4;
				next_current_y = current_y;
				temp_address = record + 1;
				next_record = record + 1;
			end
			
			next_cnt = 0;
			next_get_next_triangle = 1'b0;
		
		end
		wait_pipeline_result: begin
		
		    if(cnt==8) begin
                next_state = initial_or_finish_triangle;
                next_cnt = 0;				
			end else begin
			    next_state = state;
				next_cnt = cnt + 1;
			end
			
			next_current_x = current_x;
			next_current_y = current_y;
			temp_address = 0;
			next_record = record;
			next_get_next_triangle = 1'b0;
		
		end
		default: begin
		
		    next_state = initial_or_finish_triangle;
			next_cnt = 0;
			next_current_x = 0;
			next_current_y = 0;
			temp_address = 0;
			next_record = 0;
			next_get_next_triangle = 1'b0;
		
		end		
    endcase
end
	
	GetColorDepth GetColorDepth_00(    // y = 0, x = 0
	.clk(clk),

    .screen_x1(screen_x1),
	.screen_y1(screen_y1),
	.screen_x2(screen_x2),
	.screen_y2(screen_y2),
	.screen_x3(screen_x3),
	.screen_y3(screen_y3),

    .vertice1_depth(vertice1_depth),
	.vertice2_depth(vertice2_depth),
	.vertice3_depth(vertice3_depth),
	
	.vertice1_color(vertice1_color),
	.vertice2_color(vertice2_color),
	.vertice3_color(vertice3_color),
	
	.current_x(current_x),
    .current_y(current_y),
	
	.current_Color(Color_RGB_combine[383:360]),
	.current_depth(depth_after[335:315]),
	.not_draw(not_draw_array[15]),
	.in_triangle(in_triangle_array[15])
	);


	GetColorDepth GetColorDepth_01(      // y = 0, x = 1
	.clk(clk),

    .screen_x1(screen_x1),
	.screen_y1(screen_y1),
	.screen_x2(screen_x2),
	.screen_y2(screen_y2),
	.screen_x3(screen_x3),
	.screen_y3(screen_y3),

    .vertice1_depth(vertice1_depth),
	.vertice2_depth(vertice2_depth),
	.vertice3_depth(vertice3_depth),
	
	.vertice1_color(vertice1_color),
	.vertice2_color(vertice2_color),
	.vertice3_color(vertice3_color),
	
	.current_x(current_x + 1),
    .current_y(current_y),
	
	.current_Color(Color_RGB_combine[359:336]),
	.current_depth(depth_after[314:294]),
	.not_draw(not_draw_array[14]),
	.in_triangle(in_triangle_array[14])
	);
	
	GetColorDepth GetColorDepth_02(   // y=0, x=2
	.clk(clk),

    .screen_x1(screen_x1),
	.screen_y1(screen_y1),
	.screen_x2(screen_x2),
	.screen_y2(screen_y2),
	.screen_x3(screen_x3),
	.screen_y3(screen_y3),

    .vertice1_depth(vertice1_depth),
	.vertice2_depth(vertice2_depth),
	.vertice3_depth(vertice3_depth),
	
	.vertice1_color(vertice1_color),
	.vertice2_color(vertice2_color),
	.vertice3_color(vertice3_color),
	
	.current_x(current_x + 2),
    .current_y(current_y),
	
	.current_Color(Color_RGB_combine[335:312]),
	.current_depth(depth_after[293:273]),
	.not_draw(not_draw_array[13]),
	.in_triangle(in_triangle_array[13])
	);
	
	GetColorDepth GetColorDepth_03(        // y=0, x=3
	.clk(clk),

    .screen_x1(screen_x1),
	.screen_y1(screen_y1),
	.screen_x2(screen_x2),
	.screen_y2(screen_y2),
	.screen_x3(screen_x3),
	.screen_y3(screen_y3),

    .vertice1_depth(vertice1_depth),
	.vertice2_depth(vertice2_depth),
	.vertice3_depth(vertice3_depth),
	
	.vertice1_color(vertice1_color),
	.vertice2_color(vertice2_color),
	.vertice3_color(vertice3_color),
	
	.current_x(current_x + 3),
    .current_y(current_y),
	
	.current_Color(Color_RGB_combine[311:288]),
	.current_depth(depth_after[272:252]),
	.not_draw(not_draw_array[12]),
	.in_triangle(in_triangle_array[12])
	);
	
	GetColorDepth GetColorDepth_10(    // y = 1, x = 0
	.clk(clk),

    .screen_x1(screen_x1),
	.screen_y1(screen_y1),
	.screen_x2(screen_x2),
	.screen_y2(screen_y2),
	.screen_x3(screen_x3),
	.screen_y3(screen_y3),

    .vertice1_depth(vertice1_depth),
	.vertice2_depth(vertice2_depth),
	.vertice3_depth(vertice3_depth),
	
	.vertice1_color(vertice1_color),
	.vertice2_color(vertice2_color),
	.vertice3_color(vertice3_color),
	
	.current_x(current_x),
    .current_y(current_y + 1),
	
	.current_Color(Color_RGB_combine[287:264]),
	.current_depth(depth_after[251:231]),
	.not_draw(not_draw_array[11]),
	.in_triangle(in_triangle_array[11])
	);


	GetColorDepth GetColorDepth_11(      // y = 1, x = 1
	.clk(clk),

    .screen_x1(screen_x1),
	.screen_y1(screen_y1),
	.screen_x2(screen_x2),
	.screen_y2(screen_y2),
	.screen_x3(screen_x3),
	.screen_y3(screen_y3),

    .vertice1_depth(vertice1_depth),
	.vertice2_depth(vertice2_depth),
	.vertice3_depth(vertice3_depth),
	
	.vertice1_color(vertice1_color),
	.vertice2_color(vertice2_color),
	.vertice3_color(vertice3_color),
	
	.current_x(current_x + 1),
    .current_y(current_y + 1),
	
	.current_Color(Color_RGB_combine[263:240]),
	.current_depth(depth_after[230:210]),
	.not_draw(not_draw_array[10]),
	.in_triangle(in_triangle_array[10])
	);
	
	GetColorDepth GetColorDepth_12(     // y = 1, x = 2
	.clk(clk),

    .screen_x1(screen_x1),
	.screen_y1(screen_y1),
	.screen_x2(screen_x2),
	.screen_y2(screen_y2),
	.screen_x3(screen_x3),
	.screen_y3(screen_y3),

    .vertice1_depth(vertice1_depth),
	.vertice2_depth(vertice2_depth),
	.vertice3_depth(vertice3_depth),
	
	.vertice1_color(vertice1_color),
	.vertice2_color(vertice2_color),
	.vertice3_color(vertice3_color),
	
	.current_x(current_x + 2),
    .current_y(current_y + 1),
	
	.current_Color(Color_RGB_combine[239:216]),
	.current_depth(depth_after[209:189]),
	.not_draw(not_draw_array[9]),
	.in_triangle(in_triangle_array[9])
	);
	
	GetColorDepth GetColorDepth_13(    // y=1, x=3
	.clk(clk),

    .screen_x1(screen_x1),
	.screen_y1(screen_y1),
	.screen_x2(screen_x2),
	.screen_y2(screen_y2),
	.screen_x3(screen_x3),
	.screen_y3(screen_y3),

    .vertice1_depth(vertice1_depth),
	.vertice2_depth(vertice2_depth),
	.vertice3_depth(vertice3_depth),
	
	.vertice1_color(vertice1_color),
	.vertice2_color(vertice2_color),
	.vertice3_color(vertice3_color),
	
	.current_x(current_x + 3),
    .current_y(current_y + 1),
	
	.current_Color(Color_RGB_combine[215:192]),
	.current_depth(depth_after[188:168]),
	.not_draw(not_draw_array[8]),
	.in_triangle(in_triangle_array[8])
	);
	
	GetColorDepth GetColorDepth_20(    // y = 2, x = 0
	.clk(clk),

    .screen_x1(screen_x1),
	.screen_y1(screen_y1),
	.screen_x2(screen_x2),
	.screen_y2(screen_y2),
	.screen_x3(screen_x3),
	.screen_y3(screen_y3),

    .vertice1_depth(vertice1_depth),
	.vertice2_depth(vertice2_depth),
	.vertice3_depth(vertice3_depth),
	
	.vertice1_color(vertice1_color),
	.vertice2_color(vertice2_color),
	.vertice3_color(vertice3_color),
	
	.current_x(current_x),
    .current_y(current_y + 2),
	
	.current_Color(Color_RGB_combine[191:168]),
	.current_depth(depth_after[167:147]),
	.not_draw(not_draw_array[7]),
	.in_triangle(in_triangle_array[7])
	);


	GetColorDepth GetColorDepth_21(      // y = 2, x = 1
	.clk(clk),

    .screen_x1(screen_x1),
	.screen_y1(screen_y1),
	.screen_x2(screen_x2),
	.screen_y2(screen_y2),
	.screen_x3(screen_x3),
	.screen_y3(screen_y3),

    .vertice1_depth(vertice1_depth),
	.vertice2_depth(vertice2_depth),
	.vertice3_depth(vertice3_depth),
	
	.vertice1_color(vertice1_color),
	.vertice2_color(vertice2_color),
	.vertice3_color(vertice3_color),
	
	.current_x(current_x + 1),
    .current_y(current_y + 2),
	
	.current_Color(Color_RGB_combine[167:144]),
	.current_depth(depth_after[146:126]),
	.not_draw(not_draw_array[6]),
	.in_triangle(in_triangle_array[6])
	);
	
	GetColorDepth GetColorDepth_22(   // y=2, x=2
	.clk(clk),

    .screen_x1(screen_x1),
	.screen_y1(screen_y1),
	.screen_x2(screen_x2),
	.screen_y2(screen_y2),
	.screen_x3(screen_x3),
	.screen_y3(screen_y3),

    .vertice1_depth(vertice1_depth),
	.vertice2_depth(vertice2_depth),
	.vertice3_depth(vertice3_depth),
	
	.vertice1_color(vertice1_color),
	.vertice2_color(vertice2_color),
	.vertice3_color(vertice3_color),
	
	.current_x(current_x + 2),
    .current_y(current_y + 2),
	
	.current_Color(Color_RGB_combine[143:120]),
	.current_depth(depth_after[125:105]),
	.not_draw(not_draw_array[5]),
	.in_triangle(in_triangle_array[5])
	);
	
	GetColorDepth GetColorDepth_23(    // y=2, x=3
	.clk(clk),

    .screen_x1(screen_x1),
	.screen_y1(screen_y1),
	.screen_x2(screen_x2),
	.screen_y2(screen_y2),
	.screen_x3(screen_x3),
	.screen_y3(screen_y3),

    .vertice1_depth(vertice1_depth),
	.vertice2_depth(vertice2_depth),
	.vertice3_depth(vertice3_depth),
	
	.vertice1_color(vertice1_color),
	.vertice2_color(vertice2_color),
	.vertice3_color(vertice3_color),
	
	.current_x(current_x + 3),
    .current_y(current_y + 2),
	
	.current_Color(Color_RGB_combine[119:96]),
	.current_depth(depth_after[104:84]),
	.not_draw(not_draw_array[4]),
	.in_triangle(in_triangle_array[4])
	);
	
	GetColorDepth GetColorDepth_30(    // y = 3, x = 0
	.clk(clk),

    .screen_x1(screen_x1),
	.screen_y1(screen_y1),
	.screen_x2(screen_x2),
	.screen_y2(screen_y2),
	.screen_x3(screen_x3),
	.screen_y3(screen_y3),

    .vertice1_depth(vertice1_depth),
	.vertice2_depth(vertice2_depth),
	.vertice3_depth(vertice3_depth),
	
	.vertice1_color(vertice1_color),
	.vertice2_color(vertice2_color),
	.vertice3_color(vertice3_color),
	
	.current_x(current_x),
    .current_y(current_y + 3),
	
	.current_Color(Color_RGB_combine[95:72]),
	.current_depth(depth_after[83:63]),
	.not_draw(not_draw_array[3]),
	.in_triangle(in_triangle_array[3])
	);


	GetColorDepth GetColorDepth_31(      // y = 3, x = 1
	.clk(clk),

    .screen_x1(screen_x1),
	.screen_y1(screen_y1),
	.screen_x2(screen_x2),
	.screen_y2(screen_y2),
	.screen_x3(screen_x3),
	.screen_y3(screen_y3),

    .vertice1_depth(vertice1_depth),
	.vertice2_depth(vertice2_depth),
	.vertice3_depth(vertice3_depth),
	
	.vertice1_color(vertice1_color),
	.vertice2_color(vertice2_color),
	.vertice3_color(vertice3_color),
	
	.current_x(current_x + 1),
    .current_y(current_y + 3),
	
	.current_Color(Color_RGB_combine[71:48]),
	.current_depth(depth_after[62:42]),
	.not_draw(not_draw_array[2]),
	.in_triangle(in_triangle_array[2])
	);
	
	GetColorDepth GetColorDepth_32(     // y = 3, x = 2
	.clk(clk),

    .screen_x1(screen_x1),
	.screen_y1(screen_y1),
	.screen_x2(screen_x2),
	.screen_y2(screen_y2),
	.screen_x3(screen_x3),
	.screen_y3(screen_y3),

    .vertice1_depth(vertice1_depth),
	.vertice2_depth(vertice2_depth),
	.vertice3_depth(vertice3_depth),
	
	.vertice1_color(vertice1_color),
	.vertice2_color(vertice2_color),
	.vertice3_color(vertice3_color),
	
	.current_x(current_x + 2),
    .current_y(current_y + 3),
	
	.current_Color(Color_RGB_combine[47:24]),
	.current_depth(depth_after[41:21]),
	.not_draw(not_draw_array[1]),
	.in_triangle(in_triangle_array[1])
	);
	
	GetColorDepth GetColorDepth_33(   // y = 3, x = 3
	.clk(clk),

    .screen_x1(screen_x1),
	.screen_y1(screen_y1),
	.screen_x2(screen_x2),
	.screen_y2(screen_y2),
	.screen_x3(screen_x3),
	.screen_y3(screen_y3),

    .vertice1_depth(vertice1_depth),
	.vertice2_depth(vertice2_depth),
	.vertice3_depth(vertice3_depth),
	
	.vertice1_color(vertice1_color),
	.vertice2_color(vertice2_color),
	.vertice3_color(vertice3_color),
	
	.current_x(current_x + 3),
    .current_y(current_y + 3),
	
	.current_Color(Color_RGB_combine[23:0]),
	.current_depth(depth_after[20:0]),
	.not_draw(not_draw_array[0]),
	.in_triangle(in_triangle_array[0])
	);
	
	
endmodule
