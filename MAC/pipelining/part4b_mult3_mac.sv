module part4b_mac(clk, reset, a, b, valid_in, f, valid_out);
	input clk, reset, valid_in;
	input signed [13:0] a, b;
	output logic signed [27:0] f;
	output logic valid_out;
	logic signed [13:0] a_r, b_r;
        logic signed [27:0] f_wire, mult_ab, mult_ab_delay;
	logic enable_ab, enable_R1, enable_f, enable_mult1, enable_mult2;
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
		mult_ab_delay <= mult_ab;
        	if (reset == 1) begin
			mult_ab_delay <= 0;
            		f    <= 0;
        	end
        	else begin
		if (enable_f == 1) begin
			f <= f_wire;
		end
        	end
    	end
DW02_mult_3_stage #(14, 14) multinstance(a_r, b_r, 1'b1, clk, mult_ab);
	always_comb begin
		f_wire = f + mult_ab_delay;
		if (~(f[27] ^ mult_ab_delay[27]) & (f[27]^f_wire[27])) begin
			if(f[27] == 0)
				f_wire = 134217727;
			else
				f_wire = -134217728;
		end
		else begin
			f_wire = f + mult_ab_delay;
		end
		
	end 
control cntrl(.valid_in(valid_in), .clk(clk), .reset(reset), .enable_f(enable_f), .enable_ab(enable_ab), .valid_out(valid_out), .enable_R1(enable_R1), .enable_mult1(enable_mult1), .enable_mult2(enable_mult2));
endmodule

module control(valid_in, clk, reset, enable_f, enable_ab, valid_out, enable_R1, enable_mult1, enable_mult2);
	input valid_in, clk, reset;
	output logic enable_f, valid_out, enable_ab, enable_R1, enable_mult1, enable_mult2;
 	logic reset_R1, reset_f, reset_mult1, reset_mult2;
	assign enable_ab = valid_in;
	always_ff @(posedge clk) begin
		enable_R1 <= valid_in;
		enable_mult1 <= enable_R1;
		enable_mult2 <= enable_mult1;
		enable_f <= enable_mult2;		
		reset_R1 <= reset;
		reset_mult1 <= reset_R1;
		reset_mult2 <= reset_mult1;
		reset_f <= reset_mult2;
	end
	always_ff @(posedge clk) begin
		if (reset ==1) begin
			valid_out <= 0;
		end
		else if (reset_R1 == 1) begin
			valid_out <= 0;
		end
		else if (reset_mult1 == 1) begin
			valid_out <= 0;
		end
		else if (reset_mult2 == 1) begin
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
 
