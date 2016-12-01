`include "AbstractGateControl.v"
`include "AbstractConventionalTimer.v"

module DemoGateControl(
	input [3:0] KEY,
	input CLOCK_50,

	output [9:0] LEDR,

	output [6:0] HEX4,
	output [6:0] HEX3,
	output [6:0] HEX2,
	output [6:0] HEX1,
	output [6:0] HEX0,

	output [7:0] selected_gate, // The current gate the player has selected
	output [8:0] completed_gate, // The gates the player has completed
	output timer_en, // Enabling the timer, starts after hitting
	output reg vga_blankout, // Blank out the VGA temporarily when a player misses
	output [7:0] current_gate);

	AbstractGateControl DemoControl(
		.in1(KEY[1]),
		.in2(KEY[0]),
		.switch_select(KEY[2]),
		.confirm_select(KEY[3]),
		.clk(CLOCK_50),

		.outwire(LEDR[1]), // The output of the two inputs
		.selected_gate(selected_gate), // The current gate the player has selected
		.completed_gate(completed_gate),
		.timer_en(timer_en),
		.vga_blankout(LEDR[0]),
		.current_gate(current_gate)
		);

	wire [3:0] selected_gate_4_bit;
	oneHotToFourBit conv1(
		.onehot({1'b0, selected_gate}),
		.fourbit(selected_gate_4_bit));

	wire [3:0] current_gate_4_bit;
	oneHotToFourBit conv2(
		.onehot({1'b0, current_gate}),
		.fourbit(current_gate_4_bit));

	AbstractConventionalTimer ActTimer(
        .enable(timer_en),
		.reset(),
		.clock(CLOCK_50),
    	.HEXfour(HEX4),
    	.HEXthree(HEX3),
    	.HEXtwo(HEX2),
    	.HEXone(HEX1),
    	.HEXzero(HEX0),
		.out_pulse());


	assign LEDR[9:6] = selected_gate_4_bit;
	assign LEDR[5:2] = current_gate_4_bit;
endmodule

module oneHotToFourBit(
	input [8:0] onehot,
	output reg [3:0] fourbit);

	always @(*) begin
		case(onehot)
			8'b0000_0000: begin
				fourbit = 4'h0;
			end
			8'b0000_0001: begin
				fourbit = 4'h1;
			end
			8'b0000_0010: begin
				fourbit = 4'h2;
			end
			8'b0000_0100: begin
				fourbit = 4'h3;
			end
			8'b0000_1000: begin
				fourbit = 4'h4;
			end
			8'b0001_0000: begin
				fourbit = 4'h5;
			end
			8'b0010_0000: begin
				fourbit = 4'h6;
			end
			8'b0100_0000: begin
				fourbit = 4'h7;
			end
			8'b1000_0000: begin
				fourbit = 4'h8;
			end
			default: begin
				fourbit = 4'h0;
			end
		endcase
	end
endmodule
