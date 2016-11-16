`include "bit32_rate_divider.v"

/*Delivers a pulse to outpulse every 500,000 ticks 
(should be 0.01 seconds with 50Mhz tickrate)*/
module centisecond_rate_divider(
    input clock,
    output out_pulse);
    
    /*Call the 32 bit rate divider with cycle_amt = 500,000*/
    bit32_rate_divider ctr(
        .clock(clock),
        .cycle_amt(32'd500_000),
        .out_pulse(out_pulse));

endmodule
