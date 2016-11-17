`include "bit4_counter.v"

/*Counter that counts in this order:
2,1,0,2... on every posedge of in_pulse. 
Outputs a pulse on out_pulse whenever it resets to 0*/
module three_counter(
	input enable,
    input in_pulse,
    output out_pulse,
    output [3:0] cur_value);

	bit4_counter ctr (
		.enable(enable),
		.in_pulse(in_pulse),
		.start(4'd2),
		.out_pulse(out_pulse),
		.pos_value(cur_value));
endmodule