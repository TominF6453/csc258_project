`include "rectDrawer.v"
`include "vga_adapter/vga_adapter.v"

module signal_drawer
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
	wire [9:0] x;
	wire [8:0] y;
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
		defparam VGA.RESOLUTION = "320x240";
		defparam VGA.MONOCHROME = "FALSE";
		defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
		defparam VGA.BACKGROUND_IMAGE = "./Images/image.colour.mif";

	 // Instantiate FSM control
    control c0(
		.clk(rectDone),
		.resetn(resetn),
		.draw(SW[3]),

		.bar1_signal(SW[0]),
		.bar2_signal(SW[1]),
		.bar3_signal(SW[2]),

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
		.width(10'd75),
		.height(10'd10),

		.out_x(x),
		.out_y(y),
		.done(rectDone));


endmodule

module control(
	input clk,
	input resetn,
	input draw,

	input bar1_signal,
	input bar2_signal,
	input bar3_signal,

	output reg [9:0] x,
	output reg [8:0] y,
	output reg [2:0] outColor,
	output reg wen
	);

	reg [1:0] current_state, next_state;

	localparam  S_LOAD        	= 2'd0,
				S_draw_bar1		= 2'd1,
				S_draw_bar2		= 2'd2,
				S_draw_bar3		= 2'd3;

	// Next state logic
	always @(*)
	begin: state_table
		case (current_state)
			S_LOAD: next_state = draw ? S_draw_bar1 : S_LOAD;
			S_draw_bar1: next_state = S_draw_bar2;
			S_draw_bar2: next_state = S_draw_bar3;
			S_draw_bar3: next_state = S_LOAD;
			default: next_state = S_LOAD;
		endcase
	end

	always @(*)
	begin: enable_signals
		// Default signals to 0
		x = 0;
		y = 0;
		outColor = 0;
		wen = 1'b0;

		case (current_state)
			S_LOAD: begin
				wen = 1'b0;
			end
			S_draw_bar1: begin
				wen = 1'b1;
				x = 10'd195;
				y = 9'd95;
				outColor = bar1_signal ? 3'b010 : 3'b100;
			end
			S_draw_bar2: begin
				wen = 1'b1;
				x = 10'd195;
				y = 9'd144;
				outColor = bar2_signal ? 3'b010 : 3'b100;
			end
			S_draw_bar3: begin
				wen = 1'b1;
				x = 10'd370;
				y = 9'd119;
				outColor = bar3_signal ? 3'b010 : 3'b100;
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