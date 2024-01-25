module part2_mac(clk, reset, a, b, valid_in, f, valid_out);
	input clk, reset, valid_in;
	input signed [13:0] a, b;
	output logic signed [27:0] f;
	output logic valid_out;
	logic signed [13:0] a_r, b_r;
        logic signed [27:0] f_wire;
	logic enable_ab, enable_f;
	always_ff @(posedge clk) begin
        	if (reset == 1) begin
            		a_r  <= 0;
           		b_r  <= 0;
        	end
        	else begin
		if (enable_ab == 1) begin
           		a_r  <= a;
            		b_r <= b;
		end
        	end
    	end
	always_ff @(posedge clk) begin
        	if (reset == 1) begin
            		f    <= 0;
        	end
        	else begin
		if (enable_f == 1) begin
			f <= f_wire;
		end
        	end
    	end
	always_comb begin
		f_wire = f + a_r*b_r;      
	end 
control cntrl(.valid_in(valid_in), .clk(clk), .reset(reset), .enable_f(enable_f), .enable_ab(enable_ab), .valid_out(valid_out));
endmodule

module control(valid_in, clk, reset, enable_f, enable_ab, valid_out);
	input valid_in, clk, reset;
	output logic enable_f, valid_out, enable_ab;
 	logic reset_f, enable_temp;
	assign enable_ab = valid_in;
	always_ff @(posedge clk) begin
		enable_f <= valid_in;		
		reset_f <= reset;
	end
	always_ff @(posedge clk) begin
		if (reset ==1) begin
			valid_out <= 0;
		end
		else if (reset_f == 1) begin
			valid_out <= 0;
		end
		else begin
			valid_out <= enable_f;		
		end
	end
endmodule
 
