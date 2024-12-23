module Rasterizer(

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
	
	output  reg [383:0] Color_RGB_combine,
	output reg  write_enable_sram_CD,
	output reg [15:0] write_wordmask_sram_CD,
	output  reg [335:0] depth_after,
	
	// to controller
	output reg get_next_triangle

);

parameter initial_or_finish_triangle = 2'b00;
parameter set = 2'b01;
parameter compute = 2'b10;
parameter wait_pipeline_result = 2'b11;

wire [383:0] Color_RGB_combine_n;
wire [335:0] depth_after_n;
	
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

reg signed [11:0] minus_x;
reg signed [11:0] next_minus_x;

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
reg [15:0] next_write_wordmask_sram_CD;

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
reg signed [20:0] depth_s_org [0:15];
reg signed [20:0] depth_s_after [0:15];

reg next_get_next_triangle;
reg signed [11:0] next_current_x;
reg signed [11:0] next_current_y;
reg signed [11:0] current_x;
reg signed [11:0] current_y;

reg signed [11:0] x_00;
reg signed [11:0] y_00;

reg signed [11:0] x_01;
reg signed [11:0] y_01;

reg signed [11:0] x_02;
reg signed [11:0] y_02;

reg signed [11:0] x_03;
reg signed [11:0] y_03;

reg signed [11:0] x_10;
reg signed [11:0] y_10;

reg signed [11:0] x_11;
reg signed [11:0] y_11;

reg signed [11:0] x_12;
reg signed [11:0] y_12;

reg signed [11:0] x_13;
reg signed [11:0] y_13;

reg signed [11:0] x_20;
reg signed [11:0] y_20;

reg signed [11:0] x_21;
reg signed [11:0] y_21;

reg signed [11:0] x_22;
reg signed [11:0] y_22;

reg signed [11:0] x_23;
reg signed [11:0] y_23;

reg signed [11:0] x_30;
reg signed [11:0] y_30;

reg signed [11:0] x_31;
reg signed [11:0] y_31;

reg signed [11:0] x_32;
reg signed [11:0] y_32;

reg signed [11:0] x_33;
reg signed [11:0] y_33;

integer i;

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
	minus_x <= next_minus_x;
	end_x <= next_end_x;
	end_y <= next_end_y;
	get_next_triangle <= next_get_next_triangle;
	Color_RGB_combine <= Color_RGB_combine_n;
	depth_after <= depth_after_n;
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
	
	next_minus_x = (end_x - start_x)/4;

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
			depth_s_after[i] = depth_after_n[i*21+:21];
		    if( depth_s_after[i] <= depth_s_org[i] && in_triangle_array[i]==1'b1 && not_draw_array[i] == 1'b0) begin
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
				next_state = set;
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
				temp_address = record - minus_x + 320;
				next_record = record - minus_x + 320;
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

always@* begin
	x_00 = current_x;
	y_00 = current_y;

	x_01 = current_x+1;
	y_01 = current_y;

	x_02 = current_x+2;
	y_02 = current_y;

	x_03 = current_x+3;
	y_03 = current_y;

	x_10 = current_x;
	y_10 = current_y+1;

	x_11 = current_x+1;
	y_11 = current_y+1;

	x_12 = current_x+2;
	y_12 = current_y+1;

	x_13 = current_x+3;
	y_13 = current_y+1;

	x_20 = current_x;
	y_20 = current_y+2;

	x_21 = current_x+1;
	y_21 = current_y+2;

	x_22 = current_x+2;
	y_22 = current_y+2;

	x_23 = current_x+3;
	y_23 = current_y+2;

	x_30 = current_x;
	y_30 = current_y+3;

	x_31 = current_x+1;
	y_31 = current_y+3;

	x_32 = current_x+2;
	y_32 = current_y+3;

	x_33 = current_x+3;
	y_33 = current_y+3;

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
	
	.current_x(x_00),
    .current_y(y_00),
	
	.current_Color(Color_RGB_combine_n[383:360]),
	.current_depth(depth_after_n[335:315]),
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
	
	.current_x(x_01),
    .current_y(y_01),
	
	.current_Color(Color_RGB_combine_n[359:336]),
	.current_depth(depth_after_n[314:294]),
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
	
	.current_x(x_02),
    .current_y(y_02),
	
	.current_Color(Color_RGB_combine_n[335:312]),
	.current_depth(depth_after_n[293:273]),
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
	
	.current_x(x_03),
    .current_y(y_03),
	
	.current_Color(Color_RGB_combine_n[311:288]),
	.current_depth(depth_after_n[272:252]),
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
	
	.current_x(x_10),
    .current_y(y_10),
	
	.current_Color(Color_RGB_combine_n[287:264]),
	.current_depth(depth_after_n[251:231]),
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
	
	.current_x(x_11),
    .current_y(y_11),
	
	.current_Color(Color_RGB_combine_n[263:240]),
	.current_depth(depth_after_n[230:210]),
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
	
	.current_x(x_12),
    .current_y(y_12),
	
	.current_Color(Color_RGB_combine_n[239:216]),
	.current_depth(depth_after_n[209:189]),
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
	
	.current_x(x_13),
    .current_y(y_13),
	
	.current_Color(Color_RGB_combine_n[215:192]),
	.current_depth(depth_after_n[188:168]),
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
	
	.current_x(x_20),
    .current_y(y_20),
	
	.current_Color(Color_RGB_combine_n[191:168]),
	.current_depth(depth_after_n[167:147]),
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
	
	.current_x(x_21),
    .current_y(y_21),
	
	.current_Color(Color_RGB_combine_n[167:144]),
	.current_depth(depth_after_n[146:126]),
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
	
	.current_x(x_22),
    .current_y(y_22),
	
	.current_Color(Color_RGB_combine_n[143:120]),
	.current_depth(depth_after_n[125:105]),
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
	
	.current_x(x_23),
    .current_y(y_23),
	
	.current_Color(Color_RGB_combine_n[119:96]),
	.current_depth(depth_after_n[104:84]),
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
	
	.current_x(x_30),
    .current_y(y_30),
	
	.current_Color(Color_RGB_combine_n[95:72]),
	.current_depth(depth_after_n[83:63]),
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
	
	.current_x(x_31),
    .current_y(y_31),
	
	.current_Color(Color_RGB_combine_n[71:48]),
	.current_depth(depth_after_n[62:42]),
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
	
	.current_x(x_32),
    .current_y(y_32),
	
	.current_Color(Color_RGB_combine_n[47:24]),
	.current_depth(depth_after_n[41:21]),
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
	
	.current_x(x_33),
    .current_y(y_33),
	
	.current_Color(Color_RGB_combine_n[23:0]),
	.current_depth(depth_after_n[20:0]),
	.not_draw(not_draw_array[0]),
	.in_triangle(in_triangle_array[0])
	);
	
	
endmodule
