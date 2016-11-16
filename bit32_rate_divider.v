module bit32_rate_divider(
    input clock,
    input [31:0] cycle_amt,
    output out_pulse);

    // Cycle amt must be the 2's complement of the number of bits we are counting to
    // Concatenate a 0 onto the front to be safe
    // Value of the counter (start at two's complement)
    reg [32:0] counter = ~{0, cycle_amt} + 1;

    // Increment the value of the counter at every clock edge
    always @(posedge clock) begin
		counter <= (counter + 1);
		if (counter == 0)
			counter <= twos_comp;
    end

    // Out pulse should be 1 when counter is all zero 
    assign out_pulse = &(~counter);
endmodule