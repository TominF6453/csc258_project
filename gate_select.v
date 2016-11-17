//SW[9:6] - selects the gate
//SW[1:0] - the two inputs
//
//LEDR[0] - displays the output of the selected gate

module gate_select(SW, LEDR);
	input [9:0] SW;
	output [9:0] LEDR;

	abstract_gate_selector AGS1(.in(SW[1:0]),
								.selection(SW[9:6]),
								.gate_out(LEDR[0]));
endmodule

module abstract_gate_selector(
	input [1:0] in,
	input [3:0] selection,
	output gate_out);

	wire srwire;
	sr_latch SR(.S(in[1]),
				.R(in[0]),
				.Q(srwire));

	wire twire;
	t_latch TLatch(.T(in[1]),
				   .clk(in[0]),
				   .Q(twire));

	localparam 	S_AND	= 4'd0,
				S_OR	= 4'd1,
				S_NAND	= 4'd2,
				S_NOR	= 4'd3,
				S_XOR	= 4'd4,
				S_XNOR	= 4'd5,
				S_SR	= 4'd6,
				S_T		= 4'd7,
				S_D		= 4'd8;
	
	wire reg result;

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

	wire reg curstate;

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
	output Q);

	wire reg curstate;

	always @(posedge clk)
		curstate = T ? ~curstate : curstate;

	assign Q = curstate;
endmodule
