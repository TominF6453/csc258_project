`include "AbstractConventionalTimer.v"

module ActualTimer(
    input [9:0] SW,
    input CLOCK_50,
    output [6:0] HEX4,
    output [6:0] HEX3,
    output [6:0] HEX2,
    output [6:0] HEX1,
    output [6:0] HEX0);

	AbstractConventionalTimer ActTimer(
        .enable(SW[0]),
		  .reset(SW[9]),
		.clock(CLOCK_50),
    	.HEXfour(HEX4),
    	.HEXthree(HEX3),
    	.HEXtwo(HEX2),
    	.HEXone(HEX1),
    	.HEXzero(HEX0));
    
endmodule