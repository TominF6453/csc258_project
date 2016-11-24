module completion_drawer
	(
		CLOCK_50,						//	On Board 50 MHz
		// Your inputs and outputs here
        KEY,
        SW,
		// The ports below are for the VGA output.  Do not change.
		VGA_CLK,   						//	VGA Clock
		VGA_HS,							//	VGA H_SYNC
		VGA_VS,							//	VGA V_SYNC
		VGA_BLANK_N,					//	VGA BLANK
		VGA_SYNC_N,						//	VGA SYNC
		VGA_R,   						//	VGA Red[9:0]
		VGA_G,	 						//	VGA Green[9:0]
		VGA_B   						//	VGA Blue[9:0]
	);

	input			CLOCK_50;				//	50 MHz
	input   [9:0]   SW;
	input   [3:0]   KEY;

	// Declare your inputs and outputs here
	// Do not change the following outputs
	output			VGA_CLK;   				//	VGA Clock
	output			VGA_HS;					//	VGA H_SYNC
	output			VGA_VS;					//	VGA V_SYNC
	output			VGA_BLANK_N;				//	VGA BLANK
	output			VGA_SYNC_N;				//	VGA SYNC
	output	[9:0]	VGA_R;   				//	VGA Red[9:0]
	output	[9:0]	VGA_G;	 				//	VGA Green[9:0]
	output	[9:0]	VGA_B;   				//	VGA Blue[9:0]
	
	wire resetn;
	assign resetn = KEY[0];
	
	// Wires
	wire [9:0] rectX;
	wire [8:0] rectY;
	wire writeEn;
	wire rectDone;

	// Create an Instance of a VGA controller - there can be only one!
	// Define the number of colours as well as the initial background
	// image file (.MIF) for the controller.
	vga_adapter VGA(
			.resetn(resetn),
			.clock(CLOCK_50),
			.colour(colour),
			.x(x),
			.y(y),
			.plot(writeEn),
			/* Signals for the DAC to drive the monitor. */
			.VGA_R(VGA_R),
			.VGA_G(VGA_G),
			.VGA_B(VGA_B),
			.VGA_HS(VGA_HS),
			.VGA_VS(VGA_VS),
			.VGA_BLANK(VGA_BLANK_N),
			.VGA_SYNC(VGA_SYNC_N),
			.VGA_CLK(VGA_CLK));
		defparam VGA.RESOLUTION = "640x480";
		defparam VGA.MONOCHROME = "FALSE";
		defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
		defparam VGA.BACKGROUND_IMAGE = "Images/UILayout.colour.mif";

	// We are always coloring in blocks as green (R G B = 0 1 0)
	assign colour = 3'b010;

	 // Instantiate FSM control
    control c0(
		.clk(rectDone),
		.resetn(resetn),
		.draw(SW[4]),
		.block(SW[3:0]),

		.x(rectX),
		.y(rectY),
		.outColor(colour),
		.wen(writeEn));

	// Instantiate the rectangle drawer
	rectDrawer rd(
		.enable(writeEn),
		.clock(CLOCK_50),
		.x(rectX),
		.y(rectY),
		.width(10'd80),
		.height(10'd50),

		.out_x(x),
		.out_y(y),
		.done(rectDone));


endmodule

module control(
	input clk,
	input resetn,
	input draw,
	input [3:0] block,

	output reg [9:0] x,
	output reg [8:0] y,
	output reg wen
	);

	reg current_state, next_state;

	localparam  S_LOAD = 0, S_draw_block = 1;

	// Next state logic
	always @(*)
	begin: state_table
		case (current_state)
			S_LOAD: next_state = draw ? S_draw_block: S_LOAD;
			S_draw_block: next_state = S_LOAD;
			default: next_state = S_LOAD;
		endcase
	end

	always @(*)
	begin: enable_signals
		// Default signals to 0
		x = 0;
		y = 0;
		wen = 1'b0;

		case (current_state)
			S_LOAD: begin
				wen = 1'b0;
			end
			S_draw_block: begin
				wen = 1'b1;
				case (block)
		            4'd0: begin 
		            	x <= 10'd152;
		            	y <= 10'd226;
		            end
		            4'd1: begin 
		            	x <= 10'd282;
		            	y <= 10'd226;
		            end
		            4'd2: begin 
		            	x <= 10'd412;
		            	y <= 10'd226;
		            end
		            4'd3: begin 
		            	x <= 10'd152;
		            	y <= 10'd325;
		            end
		            4'd4: begin 
		            	x <= 10'd282;
		            	y <= 10'd325;
		            end
		            4'd5: begin 
		            	x <= 10'd412;
		            	y <= 10'd325;
		            end
		            4'd6: begin 
		            	x <= 10'd152;
		            	y <= 10'd425;
		            end
		            4'd7: begin 
		            	x <= 10'd282;
		            	y <= 10'd425;
		            end
		            4'd8: begin 
		            	x <= 10'd412;
		            	y <= 10'd425;
		            end
		            default: begin
		            	x <= 10'd152;
		            	y <= 10'd226;
		            end
        		endcase
			end
		endcase
	end

	// current_state registers
    always @(posedge clk)
    begin: state_FFs
        if(!resetn)
            current_state <= S_LOAD;
        else
            current_state <= next_state;
    end // state_FFS
endmodule