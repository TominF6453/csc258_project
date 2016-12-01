`include "randomGen.v"

module AbstractGateControl(
	input in1, // Top wire [KEY[1]]
	input in2, // Bottom wire [KEY[0]]
	input switch_select, // Switch selection between gates [KEY[2]]
	input confirm_select, // Confirm selection of gate [KEY[3]]

	input clk, // CLOCK_50

	output outwire, // The output of the two inputs
	output reg [7:0] selected_gate, // The current gate the player has selected
	output reg [8:0] completed_gate, // The gates the player has completed
	output reg timer_en, // Enabling the timer, starts after hitting
	output reg vga_blankout, // Blank out the VGA temporarily when a player misses
	output reg [7:0] current_gate);

	wire [8:0] random_gate;

	randomGen generator(
		.clk(clk),
		.selected(random_gate));

	always @(negedge switch_select) begin
		// Toggle between all the gates to be selected.
		vga_blankout = 0;
		if (selected_gate == 0)
			selected_gate = 8'd1;
		else
			selected_gate << 1;
	end

	always @(negedge confirm_select) begin
		// Confirm a selection, get another random gate, start the timer if it hasn't already.
		if (timer_en == 0) begin
			timer_en = 1;
			current_gate = random_gate[8:1];
		end else begin
			if (selected_gate == current_gate) begin // Player has correctly selected the gate
				if (current_gate == 0)
					completed_gate = completed_gate + 1;
				else
					completed_gate = completed_gate + (current_gate << 1);

				if (&completed_gate)
					timer_en = 0
				else begin
					// Grab a new random gate to test, that hasn't already been completed.
					while ( |{completed_gate & random_gate} ) 
						current_gate = random_gate[8:1];
				end
			end else
				vga_blankout = 1;
		end
	end

	abstract_gate_selector GateInput(
		.in({in1,in2}),
		.selection(current_gate));

endmodule

module abstract_gate_selector(
	input [1:0] in,
	input [7:0] selection,
	output gate_out);

	wire srwire;
	sr_latch SR(.S(in[1]),
				.R(in[0]),
				.Q(srwire));

	wire twire;
	t_latch TLatch(.T(in[1]),
				   .clk(in[0]),
				   .Q(twire));

	localparam 	S_AND	= 8'd0,
				S_OR	= 8'd1,
				S_NAND	= 8'd2,
				S_NOR	= 8'd4,
				S_XOR	= 8'd8,
				S_XNOR	= 8'd16,
				S_SR	= 8'd32,
				S_T		= 8'd64,
				S_D		= 8'd128;
	
	reg result;

	always @(*)
	begin: select_table
		case (selection)
			S_AND: result = in[1] & in[0];
			S_OR: result = in[1] | in[0];
			S_NAND: result = ~(in[1] & in[0]);
			S_NOR: result = ~(in[1] | in[0]);
			S_XOR: result = in[1] ^ in[0];
			S_XNOR: result = ~(in[1] ^ in[0]);
			S_SR: result = srwire;
			S_T: result = twire;
			S_D: result = in[0] ? in[1] : result;
		endcase
	end
	assign gate_out = result;
endmodule

module sr_latch(
	input S,
	input R,
	output Q);

	reg curstate;

	always @(*)
	begin: sr
		case (curstate)
			1'b0: curstate = S ? 1'b1 : 1'b0;
			1'b1: curstate = R ? 1'b0 : 1'b1;
		default: curstate = 1'b0;
		endcase
	end
	assign Q = curstate;
endmodule

module t_latch(
	input T,
	input clk,
	output reg Q);

	always @(posedge clk)
		Q <= T ? ~Q : Q;
endmodule
