`include "six_counter.v"
`include "ten_counter.v"
`include "three_counter.v"
`include "centisecond_rate_divider.v"
`include "hex_decoder.v"

/*Abstract module for a 5-hex display counter that displays time 
conventionally to centisecond precision. 
Outputs a pulse when the counter reaches zero.
(e.g. 2:00.00 -> 1:59.99*/
module AbstractConventionalTimer(
    input clock,
    output [6:0] HEXfour,
    output [6:0] HEXthree,
    output [6:0] HEXtwo,
    output [6:0] HEXone,
    output [6:0] HEXzero,
    output out_pulse);
    
    /*RD = rate divider, TCX = Xth ten counter, 
    THC = three counter, SC = six counter, 
    HX = hex X*/

    // Wire that connects the rate divider's pulse to the first ten counter's in pulse
    wire RD_to_TC0;

    // Wires that connect the counters pulses to each other
    wire TC0_to_TC1;
    wire TC1_to_TC2;
    wire TC2_to_SC;
    wire SC_to_THC;

    // Wires that connect the counters' current values to the hex displays
    wire [3:0] TC0_to_H0;
    wire [3:0] TC1_to_H1;
    wire [3:0] TC2_to_H2;
    wire [3:0] SC_to_H3;
    wire [3:0] THC_to_H4;

    // The rate divider and counters with their pulses chained together
    centisecond_rate_divider RD(
        .clock(clock),
        .out_pulse(RD_to_TC0));

    ten_counter TC0(
        .in_pulse(RD_to_TC0),
        .out_pulse(TC0_to_TC1),
        .cur_value(TC0_to_H0));

    ten_counter TC1(
        .in_pulse(TC0_to_TC1),
        .out_pulse(TC1_to_TC2),
        .cur_value(TC1_to_H1));

    ten_counter TC2(
        .in_pulse(TC1_to_TC2),
        .out_pulse(TC2_to_SC),
        .cur_value(TC2_to_H2));

    six_counter SC(
        .in_pulse(TC2_to_SC),
        .out_pulse(SC_to_THC),
        .cur_value(SC_to_H3));

    three_counter THC(
        .in_pulse(SC_to_THC),
        .out_pulse(out_pulse),
        .cur_value(THC_to_H4));


    // The hex displays
    hex_decoder H4(
        .hex_digit(THC_to_H4),
        .segments(HEXfour));

    hex_decoder H3(
        .hex_digit(SC_to_H3),
        .segments(HEXthree));

    hex_decoder H2(
        .hex_digit(TC2_to_H2),
        .segments(HEXtwo));

    hex_decoder H1(
        .hex_digit(TC1_to_H1),
        .segments(HEXone));

    hex_decoder H0(
        .hex_digit(TC0_to_H0),
        .segments(HEXzero));
    
endmodule