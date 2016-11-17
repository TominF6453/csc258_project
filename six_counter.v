`include "bit4_counter.v"

/*Counter that counts in this order:
5,4,3,2,1,0,5,4..., on every posedge of in_pulse. 
Outputs a pulse on out_pulse whenever it resets to 0*/
module six_counter(
    input in_pulse,
    output out_pulse,
    output [3:0] cur_value);

	bit4_counter ctr (
		.in_pulse(in_pulse),
		.start(4'd6),
		.out_pulse(out_pulse),
		.pos_value(cur_value));
endmodule