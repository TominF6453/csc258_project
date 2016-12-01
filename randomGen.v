module randomGen(
	input clk,
	output reg [8:0] selected
	);

	always @(posedge clk) begin
		if (selected == 9'b100000000)
			selected = 9'b000000001;
		else if (selected == 0)
			selected = 9'b000000001;
		else
			selected = (selected << 1);
	end
endmodule
