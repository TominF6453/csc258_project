module rectDrawer(
		input enable,
		input clock,
		
		input [9:0] x,
		input [8:0] y,
		input [9:0] width,
		input [8:0] height,

		output [9:0] out_x,
		output [8:0] out_y,
		output done);
	
	wire [18:0] limit = width * height;
	reg [18:0] counter;
	initial counter = 0;
	
	always @(posedge clock)
    begin
		if (enable)
			counter = counter + 1;
			if (counter == limit)
				counter = 0;
    end
	
	assign done = (counter == limit);
	assign out_x = x + counter[18:9];
	assign out_y = y + counter[8:0];
endmodule