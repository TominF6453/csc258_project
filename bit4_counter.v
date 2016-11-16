/*Counter that resets once it hits max_amt. Increments on posedge of in_pulse.*/
module bit4_counter(
    input in_pulse,
    input [3:0] max_amt,
    output reg [3:0] cur_value);

    // Value of the counter (start at 0)
    cur_value = 4'd0;

    // Increment the value of the counter at every clock edge
    always @(posedge in_pulse) begin
		cur_value <= (cur_value + 1);
		if (cur_value == max_amt)
			counter <= 4'd0;
    end
    
endmodule