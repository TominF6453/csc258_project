/*Counter that resets once it hits 0 from negative start. 
When it resets, also sends out a pulse on out_pulse.
Also outputs its current value (in two's complement for the positive form).
Increments on the posedge of in_pulse.
*/
module bit4_counter(
    input enable,
    input in_pulse,
    input [3:0] start,
    output out_pulse,
    output [3:0] pos_value);
    
    wire [4:0] twos_comp = ~{1'b0, start[3:0]} + 1;

    // Cycle amt must be the 2's complement of the number of bits we are counting to
    // Concatenate a 0 onto the front to be safe
    // Value of the counter (start at two's complement)
    reg [4:0] counter;
    initial counter = twos_comp;

    // Increment the value of the counter at every clock edge
    always @(posedge in_pulse) begin
        if (enable)
            counter <= (counter + 1);
            if (counter == 0)
                counter <= twos_comp;
    end

    wire [4:0] abs_val = ~counter[4:0] + 1;
    // Positive value of the current value
    assign pos_value = abs_val[3:0];

    // Out pulse should be 1 when counter is all zero 
    assign out_pulse = &(~counter);
    
endmodule