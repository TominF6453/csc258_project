`include "AbstractGateControl.v"
`include "AbstractConventionalTimer.do"
module DemoGateControl(
	input KEY[3:0],
	input CLOCK_50,

	output LED[9:0],

	output HEX4[3:0],
	output HEX3[3:0],
	output HEX2[3:0],
	output HEX1[3:0],
	output HEX0[3:0],

	output reg [7:0] selected_gate, // The current gate the player has selected
	output reg [8:0] completed_gate, // The gates the player has completed
	output reg timer_en, // Enabling the timer, starts after hitting
	output reg vga_blankout, // Blank out the VGA temporarily when a player misses
	output reg [7:0] current_gate);
	
	wire [7:0] selected_gate;
	wire [7:0] current_gate;

	AbstractGateControl DemoControl(
		.in1(KEY[1]),
		.in2(KEY[0]),
		.switch_select(KEY[2]),
		.confirm_select(KEY[3]),
		.clk(CLOCK_50),

		.outwire(LED[1]), // The output of the two inputs
		.selected_gate(selected_gate), // The current gate the player has selected
		.completed_gate(),
		.timer_en(),
		.vga_blankout(LED[0]),
		.current_gate(current_gate)
		)

	


	wire [3:0] selected_gate_4_bit;
	oneHotToFourBit conv1(
		.onehot(selected_gate),
		.fourbit(selected_gate_4_bit));

	wire [3:0] current_gate_4_bit;
	oneHotToFourBit conv2(
		.onehot(current_gate),
		.fourbit(current_gate_4_bit));


	assign LED[9:6] = selected_gate_4_bit;
	assign LED[5:2] = completed_gate_4_bit;


endmodule

module oneHotToFourBit(
	input [8:0] onehot,
	output [3:0] fourbit);

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

endmodule