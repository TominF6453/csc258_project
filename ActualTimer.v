`include "AbstractConventionalTimer.v"

module ActualTimer(
    input CLOCK_50,
    output [6:0] HEX4,
    output [6:0] HEX3,
    output [6:0] HEX2,
    output [6:0] HEX1,
    output [6:0] HEX0);

	AbstractConventionalTimer ActTimer(
		.clock(CLOCK_50),
    	.HEXfour(HEX4),
    	.HEXthree(HEX3),
    	.HEXtwo(HEX2),
    	.HEXone(HEX1),
    	.HEXzero(HEX0));
    
endmodule