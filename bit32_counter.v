module bit32_counter(
    input clock,
    input [31:0] cycle_amt,
    output out_pulse);

    // Cycle amt must be the 2's complement of the number of bits we are counting to
    // Concatenate a 0 onto the front to be safe
    wire twos_comp[32:0] = ~{0, cycle_amt} + 1

    // Value of the counter (start at twos_comp)
    reg [32:0] counter = twos_comp;

    // Increment the value of the counter at every clock edge
    always @(posedge clock) begin
		counter <= (counter + 1);
		if (counter == 0)
			counter <= twos_comp;
    end

    // Out pulse should be 1 when counter is all zero 
    assign out_pulse = &(~counter);
endmodule