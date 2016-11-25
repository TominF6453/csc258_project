/*Counter that resets once it hits 0 from negative start. 
When it resets, also sends out a pulse on out_pulse.
Also outputs its current value (in two's complement for the positive form).
Increments on the posedge of in_pulse.
*/
module bit4_counter(
    input reset,
	 input [3:0] reset_n,
	 input enable,
    input in_pulse,
    input [3:0] start,
    output out_pulse,
    output [3:0] pos_value);

    // Cycle amt must be the 2's complement of the number of bits we are counting to
    // Concatenate a 0 onto the front to be safe
    // Value of the counter (start at two's complement)
    reg [4:0] counter;
	 initial counter = ~{1'b0, start[3:0]} + 1;
    // Increment the value of the counter at every clock edge
    always @(posedge in_pulse, negedge reset) begin
		  if (reset == 1'b0)
				counter = ~{1'b0, reset_n[3:0]} + 1;
		  else
				if (enable) begin
					if (counter == 5'd0)
						counter = ~{1'b0, start[3:0]} + 1;
					else
						counter = (counter + 1);
					end
	 end

    wire [4:0] abs_val = ~counter + 1;
    // Positive value of the current value
    assign pos_value = abs_val[3:0];

    // Out pulse should be 1 when counter is all zero 
    assign out_pulse = (pos_value[3:0] == start[3:0]);
    
endmodule