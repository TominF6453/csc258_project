// Part 2 skeleton

`include "./vga_adapter/vga_adapter.v"
`include "gate_select.v"
module part2
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
	output			VGA_BLANK_N;			//	VGA BLANK
	output			VGA_SYNC_N;				//	VGA SYNC
	output	[9:0]	VGA_R;   				//	VGA Red[9:0]
	output	[9:0]	VGA_G;	 				//	VGA Green[9:0]
	output	[9:0]	VGA_B;   				//	VGA Blue[9:0]
	
	wire resetn;
	assign resetn = KEY[0];
	
	// Create the colour, x, y and writeEn wires that are inputs to the controller.
	wire [2:0] colour;
	assign colour = SW[9:7];

	wire [7:0] x;
	wire [6:0] y;
	wire writeEn;

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
			
	// Put your code here. Your code should produce signals x,y,colour and writeEn/plot
	// for the VGA controller, in addition to any other functionality your design may require.


	wire wen;

	// Wires to transfer dimension information to datapath
	wire [8:0] x_coord_to_dp;
	wire [8:0] width_x_to_dp;
	wire [7:0] y_coord_to_dp;
	wire [7:0] length_y_to_dp;

	// Instansiate FSM control
    control c0(

		.clk(CLOCK_50),
		.resetn(resetn),
		.draw(KEY[2]),

		.wire_inputs(~{KEY[1],KEY[0]}),
		.gate_num(SW[9:6]),

		.wen(wen),
		.out_x(x_coord_to_dp),
		.x_width(width_x_to_dp),
		.out_y(y_coord_to_dp),
		.y_length(length_y_to_dp), 
		.out_color(colour)
		);
    
    // Instansiate datapath
	datapath d0(
		.clk(CLOCK_50),
		.resetn(resetn),
		.adx(add_x),
		.ady(add_y),
		.loadx(KEY[3]),
		.out_x(x),
		.out_y(y),
		.writeEn(writeEn)
		);

endmodule

module control(
	input clk,
	input resetn,
	input draw,

	input [1:0] wire_inputs,
	input [3:0] gate_num,

	output reg wen,
	output reg [8:0] out_x,
	output reg [8:0] x_width,
	output reg [7:0] out_y,
	output reg [7:0] y_length, 
	output reg [2:0] out_color
	);

	reg [4:0] current_state, next_state;

	localparam  S_LOAD        	= 3'd0,
				S_DrawIn1		= 3'd1,
				S_DrawIn2		= 3'd2,
				S_DrawOut		= 3'd3,
				S_DrawBlock		= 3'd4,

	// Next state logic
	always @(*)
	begin: state_table
		case (current_state)
			S_LOAD: next_state = draw ? S_LOAD : S_DrawIn1;
			S_DrawIn1: next_state = S_DrawIn2;
			S_DrawIn2: next_state = S_DrawOut;
			S_DrawOut: next_state = S_DrawBlock;
			S_DrawBlock: next_state = S_LOAD;
			default: next_state = S_LOAD;
		endcase
	end
	
	// Wire to transfer result from gate selector
	wire gate_result;
	
	// Instantiating gate selector
	abstract_gate_selector ags(
		.in(wire_inputs),
		.selection(gate_num),
		.gate_out(gate_result));
	
	// Declaring wires that will be used to transfer info to and from block determination modules
	wire [8:0] blockStartX;
	wire [8:0] blockXwidth;
	wire [7:0] blockStartY;
	wire [7:0] blockYLength;
	
	// Instantiating block dimension determination module
	block_dimensions bd(
		.block_number(gate_num),
		
		.start_x(blockStartX),
		.width_x(blockXwidth),
		.start_y(blockStartY),
		.length_y(blockYLength));
	
	// Declaring wires that will be used to transfer info to and from wire determination modules
	reg [1:0] wire_number;
	wire [8:0] wireStartX;
	wire [8:0] wireXwidth;
	wire [7:0] wireStartY;
	wire [7:0] wireYLength;
	
	// Instantiating wire dimension determination module
	wire_dimensions wd(
		.wire_number(wire_number),
		
		.start_x(wireStartX),
		.width_x(wireXwidth),
		.start_y(wireStartY),
		.length_y(wireYLength));
	
	// Declaring wires that will be used to transfer info to and from color determination module
	reg is_wire;
	
	// Instantiating color determination module
	rect_color rc(

		.is_wire(is_wire),
		.wire_number(wire_number),
		.wire_inputs(wire_inputs),
		.gate_result(gate_result),

		.outcolor(out_color));
		
	always @(*)
	begin: enable_signals
		// Default signals to 0
		out_x = 0;
		out_y = 0;
		wen = 1'b0;

		case (current_state)
			S_LOAD: begin
				wen = 1'b0;
				end
			S_DrawIn1: begin
				wen = 1'b1;
				is_wire = 1;
				wire_number = 0;
				out_x = wireStartX;
				x_width = wireXwidth;
				out_y = wireStartY;
				y_length = wireYLength;
				end
			S_DrawIn2:  begin
				wen = 1'b1;
				is_wire = 1;
				wire_number = 1;
				out_x = wireStartX;
				x_width = wireXwidth;
				out_y = wireStartY;
				y_length = wireYLength;
				end
			S_DrawOut: begin
				wen = 1'b1;
				is_wire = 1;
				wire_number = 2;
				out_x = wireStartX;
				x_width = wireXwidth;
				out_y = wireStartY;
				y_length = wireYLength;
				end
			S_DrawBlock: begin
				wen = 1'b1;
				is_wire = 0;
				out_x = blockStartX;
				x_width = blockXwidth;
				out_y = blockStartY;
				y_length = blockYLength;
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

module datapath(

	input clk,
	input resetn,
	input loadx,
	input wen,

	input [8:0] in_x,
	input [8:0] x_width,
	input [7:0] in_y,
	input [7:0] y_length, 
	input [2:0] in_color,

	output reg [8:0] out_x,
	output reg [7:0] out_y,
	output reg writeEn
	);
	reg keep_going;
	initial keep_going = 1;

	reg [8:0] curx;
	initial curx = 0;

	reg [7:0] cury;
	initial cury = 0;

	always @(posedge clk) begin
		if (!resetn) begin
			curx = 0;
			cury = 0;
		end
		else begin
			if (keep_going) begin
				curx = curx + 1;
				if (curx == x_width) begin
					curx = 0;
					cury = cury + 1;
					if (cury = y_length) begin
						keep_going = 0;
					end
				end
			end
		end
	end

	assign out_x = in_x + curx;
	assign out_y = in_y + cury;

endmodule

module block_dimensions(

	input [3:0] block_number,
	
	output reg [8:0] start_x,
	output [8:0] width_x,
	output reg [7:0] start_y,
	output [7:0] length_y);
	
	always @ (*) begin
		case(block_number)
			4'd0: begin
				start_x = 76;
				start_y = 96;
				end
			4'd1: begin
				start_x = 139;
				start_y = 96;
				end
			4'd2: begin
				start_x = 202;
				start_y = 96;
				end
			4'd3: begin
				start_x = 76;
				start_y = 133;
				end
			4'd4: begin
				start_x = 139;
				start_y = 133;
				end
			4'd5: begin
				start_x = 202;
				start_y = 133;
				end
			4'd6: begin
				start_x = 76;
				start_y = 171;
				end
			4'd7: begin
				start_x = 139;
				start_y = 171;
				end
			4'd8: begin
				start_x = 202;
				start_y = 171;
				end
			default: begin
				start_x = 76;
				start_y = 171;
				end
		endcase
	end
	
	assign width_x = 9'd34;
	assign length_y = 8'd24;
	
endmodule

module wire_dimensions(

	input [1:0] wire_number,
	
	output reg [8:0] start_x,
	output [8:0] end_x,
	output reg [7:0] start_y,
	output [7:0] end_y);
	
	always @ (*) begin
		case(wire_number)
			2'd0: begin
				start_x = 97;
				start_y = 47;
				end
			2'd1: begin
				start_x = 97;
				start_y = 71;
				end
			2'd2: begin
				start_x = 185;
				start_y = 59;
				end
			default: begin
				start_x = 97;
				start_y = 47;
				end
		endcase
	end
	
	assign width_x = 9'd37;
	assign length_y = 8'd5;
	
endmodule

module rect_color(
	input is_wire,
	input [1:0] wire_number,
	input [1:0] wire_inputs,
	input gate_result,
	output reg [2:0] outcolor);
	
	always @(*) begin
		
		// Output red or green if we are drawing a wire
		if (is_wire) begin
			case (wire_number) begin
				
				// If we are using wire 0 (in1) output Green if the corresponding input is 1, red otherwise
				2d'0: begin
					if (wire_inputs[1]) begin
						outcolor = 3'b010;
					end
					else begin
						outcolor = 3'b100;
					end
				end
				
				// If we are using wire 1 (in2) output Green if the corresponding input is 1, red otherwise
				2d'1: begin
					if (wire_inputs[0]) begin
						outcolor = 3'b010;
					end
					else begin
						outcolor = 3'b100;
					end
				end
				
				// If we are looking at wire 2 (out), output Green iff the gate_result is 1, red otherwise
				2d'2: begin
					if (gate_result) begin
						outcolor = 3'b010;
					end
					else begin
						outcolor = 3'b100;
					end
				end
				
				// Default output green
				default: begin
					outcolor = 3'b010;
				end
				
			endcase
				
		end
		
		// Output green if we are drawing a block
		else begin
			outcolor = 3'b010;
		end
		
	end
	
endmodule
