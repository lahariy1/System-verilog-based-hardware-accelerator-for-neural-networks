//Team:
//1)Lahari
//2)George

//Project 2


module fc_6_6_16_1_1(clk, reset, input_valid, input_ready, input_data, output_valid, output_ready, output_data);
	input 				 		clk, reset, input_valid, output_ready;
	input signed [16-1:0]  		input_data;
	output logic signed [16-1:0] output_data;
	logic signed [1-1:0][16-1:0] 	output_data_f;
	output 		 				output_valid, input_ready;
	parameter 					WIDTH= 16; 
	parameter                   SIZE_X= 6;
	parameter                   SIZE_W= 36;
	localparam          		LOGSIZE_x=$clog2(SIZE_X);
	localparam 					LOGSIZE_w=$clog2(SIZE_W);
	localparam                  LOGSIZE_Output=$clog2(6);
	logic [LOGSIZE_x-1:0] 		addr_x;
	logic [LOGSIZE_w-1:0] 		addr_w;
	logic [LOGSIZE_Output-1:0]  output_cntr;
	logic wr_en_x, clear_acc, en_acc, output_valid_r;
	logic signed [16-1:0] mem_x_r;
	
	logic [1-1:0][16-1:0]/* mem_x_r, */ mem_w_r;// Debug Signal Removev
	
	logic [2:0] state, next_state, delay_cntr; // Debug signal Remove

	memory #(WIDTH,SIZE_X,LOGSIZE_x) mem_x(.clk(clk),.data_in(input_data),.data_out(mem_x_r),.addr(addr_x),.wr_en(wr_en_x));
	control_path_fc_6_6_16_1_1 #(LOGSIZE_x, LOGSIZE_w,LOGSIZE_Output) cntrl(clk,reset,input_valid,output_ready,addr_x, wr_en_x, addr_w, clear_acc, en_acc, input_ready, output_valid, output_valid_r,output_cntr,delay_cntr,state,next_state);

	generate
	genvar i;
	for(i= 0;i<1;i=i+1)begin:data_name
		data_path_fc_6_6_16_1_1 #(i) data(input_data, clk, reset/*, addr_x, wr_en_x*/, addr_w, clear_acc, en_acc, output_valid_r, output_data_f[i], mem_x_r, mem_w_r[i]);
	end
	endgenerate
	
	always_comb begin
		output_data = 0;
		if(output_cntr == 0)
		output_data = output_data_f[0];

	end
	
endmodule	


module memory(clk, data_in, data_out,addr, wr_en);
	parameter 			WIDTH=16, SIZE=64, ADDR_SIZE = $clog2(SIZE);
	localparam          LOGSIZE=$clog2(SIZE);
	input [WIDTH-1:0]	data_in;
	output logic [WIDTH-1:0] data_out;
	input [ADDR_SIZE-1:0] addr;
	input				clk,wr_en;
	logic [SIZE-1:0][WIDTH-1:0] mem;
	always_ff @(posedge clk) begin
		data_out<=mem[addr];
		if(wr_en)
			mem[addr]<=data_in;
	end
endmodule


//Based of part3_mac
module data_path_fc_6_6_16_1_1(input_data, clk, reset/*, addr_x, wr_en_x*/, addr_w, clear_acc, en_acc, output_valid_r, output_data,mem_x_r, mem_w_r);
	parameter                   select = 0;
	input signed [16-1:0] 		input_data;
	input 						clk, reset/*, wr_en_x*/,clear_acc,en_acc,output_valid_r;
	output logic signed [16-1:0] 	output_data;
	//parameter 					WIDTH= 16; 
	parameter                   SIZE_X= 6;
	parameter                   SIZE_W= 36;
	localparam          		LOGSIZE_x=$clog2(SIZE_X);
	localparam 					LOGSIZE_w=$clog2(SIZE_W);
	//input [LOGSIZE_x-1:0] 		addr_x;
	input [LOGSIZE_w-1:0] 		addr_w;
	logic signed [2*16-1:0] 		mult;
	
	input logic signed [16-1:0] mem_x_r;
	output logic signed [16-1:0] /*mem_x_r,*/ mem_w_r;
    logic signed [16-1:0] f_wire, mult_x_r_w_r,mult_x_r_w_r_delay;
	
	// Instantiate memory x
	// Here WIDTH is the Width, SIZE_X is the size of the 2D memory array
	//memory #(WIDTH,SIZE_X,LOGSIZE_x) mem_x(.clk(clk),.data_in(input_data),.data_out(mem_x_r),.addr(addr_x),.wr_en(wr_en_x));
	
	//Instantiate memory W
	generate
	if(select == 0)
		fc_6_6_16_1_1_W_rom_0 mem_w(.clk(clk),.addr(addr_w),.z_0(mem_w_r));

	endgenerate
	
	// Output register f
	always_ff @(posedge clk) begin
		mult_x_r_w_r_delay <= mult_x_r_w_r;
		if (reset == 1 || clear_acc == 1) begin
			output_data   <= 0;
			mult_x_r_w_r_delay <= 0;
        end
        else begin
			if (en_acc == 1) begin
				output_data <= f_wire;
			end
			if(output_valid_r == 1) begin 
 if(output_data <= 0) 
  output_data <= 0; 
end
        end
    end
		
	// Multiply and accumulate with satuaration functionality
	always_comb begin
		mult = mem_x_r*mem_w_r;
		if(mult > 32'sd32767)
			mult_x_r_w_r = 16'sd32767;
		else if(mult < -32'sd32768)
			mult_x_r_w_r = -16'sd32768;
		else
			mult_x_r_w_r = mult;
	
		f_wire = output_data + mult_x_r_w_r_delay;
		if (~(output_data[16-1] ^ mult_x_r_w_r_delay[16-1]) & (output_data[16-1]^f_wire[16-1])) begin
			if(output_data[16-1] == 0)
				f_wire = 16'sd32767;
			else
				f_wire = -16'sd32768;
		end
		else begin
			f_wire = output_data + mult_x_r_w_r_delay;
		end
	end 
endmodule


module control_path_fc_6_6_16_1_1(clk,reset,input_valid,output_ready,addr_x, wr_en_x, addr_w, clear_acc, en_acc, input_ready, output_valid, output_valid_r,output_cntr,delay_cntr,state,next_state);
	parameter LOGSIZE_x=3, LOGSIZE_w=9, LOGSIZE_Output = 10;
	input clk, reset, input_valid, output_ready;
	output logic wr_en_x, clear_acc, en_acc, input_ready, output_valid;
	output logic [LOGSIZE_x-1:0] addr_x;
	output logic [LOGSIZE_w-1:0] addr_w;
	output logic [LOGSIZE_Output-1:0] output_cntr;
	logic output_ready_r;
	logic clr_cntr, incr_delay_cntr, clr1,clr3, incr_w_addr, clr2, incr_x_addr,incr_output_cntr;
	output logic [2:0]delay_cntr;
	parameter [2:0] RESET = 3'b000, LOAD_W = 3'b001, LOAD_X = 3'b010, EXEC = 3'b011, STALL1 = 3'b100,STALL = 3'b101,WAIT = 3'b110;
	output logic [2:0] state, next_state; //Remove output logic
	output logic output_valid_r;
	//enum {RESET,LOAD_W,LOAD_X,EXEC,STALL1,STALL} state, next_state; 
	logic dec_delay_cntr;
    always_comb begin
		clr1 		 	= 0;
		clr2		 	= 0;
		clr3			= 0;
		clr_cntr 		= 0;
        incr_w_addr  	= 0;
		incr_x_addr	 	= 0;
		incr_output_cntr= 0;
		incr_delay_cntr = 0;
		wr_en_x		 	= 0;
		en_acc		 	= 0;
		clear_acc 	 	= 0;
		input_ready  	= 0;
		output_valid 	= 0;
		output_valid_r  = 0;
		dec_delay_cntr  = 0;
		
		if (state == RESET) begin // These signals will be sampled on the second clock cycle after reset 	
			if (input_valid == 1)begin
				incr_x_addr = 1;
				wr_en_x		= 1;
			end
			input_ready = 1;
			clear_acc 	= 1;	
		end
		// For making wr_en_w to 0 so that w memory's 8th index is not over written to
		else if (state == LOAD_X && addr_x == 0)begin 
			if (input_valid == 1) begin
				incr_x_addr = 1;
				wr_en_x		= 1;
			end
			input_ready = 1;
			clear_acc 	= 1;
		end
		// For making wr_en_w to 0 so that w memory's 8th index is not over written to
		else if (state == LOAD_X && ~(addr_x == 6-1))begin 
			if (input_valid == 1) begin
				incr_x_addr = 1;
				wr_en_x		= 1;
			end
			input_ready = 1;
			clear_acc 	= 1;
		end																
		// Here when addr_x == 2 && addr_w == 8 means we gave loaded both x and w
		// Here when addr_x == 2 && addr_w == 0 means only x is loaded, and addr_w reused.
		else if (state == LOAD_X && addr_x == 6-1) begin // Next cycle move to STALL state.
			if (input_valid == 1) begin
				clr1 		= 1;
				clr2		= 1;
				wr_en_x		= 1;//Wait for next cycle to make it 0 because memory block takes this in next cycle
			end
			input_ready = 1;
			clear_acc 	= 1;
		end
		// This STALL state is for waiting a state so that memory X's previous value(2nd index locations write) of x is not used for execution
		else if(state == STALL1 && addr_x == 0) begin
			incr_w_addr = 1;
			incr_x_addr	= 1;
			clear_acc 	= 1;
		end
		else if(state == EXEC && addr_w == 0 && addr_x == 0) begin // Only first cycle after entering the execution mode 
			incr_w_addr = 1;
			incr_x_addr	= 1;
			en_acc		= 1;// Next cycle will have mac result of 0th index of w and 2nd index of x. We need to wait for index 0 of w and x, to enable the acc
			// will have mac result of 8th index of w and 2nd index of x. So only in next cycle make this 1.			
		end
		else if(state == EXEC && ~(addr_x == 6-1)) begin
			incr_w_addr = 1;
			incr_x_addr	= 1;
			en_acc		= 1;
		end
		else if(state == EXEC && addr_x == 6-1) begin
			incr_delay_cntr = 1;
			if(addr_w == (36)-1)begin
				incr_w_addr = 0; // Stop counting when addr_w = 8 and addr_x == 2, this means that after delay =3 , we move to reset state
			end
			else begin
				incr_w_addr = 1;
			end
			//Counter x
			clr2		= 1;// Perform clr in the next cycle
			if(addr_w == (36)-1)begin
				incr_x_addr = 0;
			end
			else begin
				incr_x_addr = 1;
			end
			en_acc		= 1;
		end
		else if(state == STALL && delay_cntr == 1) begin
			//Keep the delay counter running
			incr_delay_cntr = 1;
			en_acc		= 1;
		end
		else if(state == STALL && delay_cntr == 2) begin
			//Keep the delay counter running
			incr_delay_cntr = 1;
			en_acc		= 1;
		end
		// Keep executing this until output is read by the dest port
		else if(state == STALL && delay_cntr == 3) begin //Change this two for pipelining
			//stop the delay counter in the next clock cycle, but don't clear the value of 2, because we will be stuck in this loop till we get out_put ready			
			//Keep stalling the counter till the row MAC result is read by the output stream
			//Counter w
			output_valid = 0;
			output_valid_r = 1;
			incr_delay_cntr = 1;
			clr3 = 1;
		end
		else if(state == STALL && delay_cntr == 4) begin //Change this two for pipelining
			//stop the delay counter in the next clock cycle, but don't clear the value of 2, because we will be stuck in this loop till we get out_put ready			
			//Keep stalling the counter till the row MAC result is read by the output stream
			//Counter w
			output_valid = 1;
			//output_valid_r = 1;
			incr_delay_cntr = 1;
		end
		
		// Keep executing this until output is read by the dest port
		else if(state == STALL && delay_cntr == 5) begin //Change this two for pipelining
			//stop the delay counter in the next clock cycle, but don't clear the value of 2, because we will be stuck in this loop till we get out_put ready
			//Keep stalling the counter till the row MAC result is read by the output stream
			//Counter w
			if( output_ready_r == 1) begin
				if(output_cntr < 1-1) begin
					dec_delay_cntr = 1;
					incr_output_cntr = 1;
				end
				else begin
					incr_delay_cntr = 1;// Increment the delay counter one last time
					clr3	        = 1;// Clear counter used for output logic after use
				end
			end 
			else begin
				output_valid = 1;				
			end
		end
		// Here we are just bringing the clear_acc to 0, so that next cycle onwards the row mac result will be passed through
		else if(state == STALL && delay_cntr == 6) begin  
			//Keep the delay counter running
			clr_cntr 		= 1;// Clear the delay counter because next cycle we start counting		
			// Next state is RESET
			if(addr_w == (36)-1) begin
				//Now stall the counter till the row MAC result is read by the output stream
				//Counter w
				clr1 		= 1;
				//Counter x
				clr2		= 1;
			end
			// Next state is EXEC
			else begin
				//Counter w
				incr_w_addr = 1;
				incr_x_addr	= 1;
				//en_acc		= 1;
				clear_acc = 1;
			end
		end
	end

	// FSM next state logic
	always_comb begin
		next_state = WAIT;
        if (state == RESET )begin
			next_state = RESET;
			if(input_valid == 1)
				next_state = LOAD_X;
		end
		/*else if (state == LOAD_W)begin
			next_state = LOAD_W;
			if(input_valid ==1 && addr_w == 63)
				next_state = LOAD_X;
		end*/
		else if (state == LOAD_X) begin	
			next_state = LOAD_X;
			if(input_valid == 1 && addr_x == 6-1)
				next_state = STALL1;
		end
		else if (state == STALL1)begin
			next_state = STALL1;
			if(addr_x == 0 && addr_w == 0)
				next_state = EXEC;
		end
		else if (state == EXEC)begin
			next_state = EXEC;
			if(addr_x == 6-1)
				next_state = STALL;
		end
		else if(state == STALL) begin
			next_state = STALL;
			if(delay_cntr == 6) begin
				if(addr_w == (36)-1)
				next_state = RESET;
				else
				next_state = EXEC;
			end
		end
	end	
	
	// FSM resgister
	always_ff @(posedge clk) begin
        if (reset == 1)
            state <= RESET;
        else
            state <= next_state;
    end 
	
	// Counter for incrementing address for memory array used to store matrix W
	always_ff @(posedge clk) begin
		if (reset == 1 || clr1 == 1) begin
			addr_w 	  <= 0;	
		end
		else if(incr_w_addr ==1) begin	
				addr_w <= addr_w + 1;
		end	
	end
	
	// Counter for incrementing address for memory array used to store vector x
	always_ff @(posedge clk) begin
		if (reset == 1 || clr2 == 1) begin
			addr_x <= 0;	
		end
		else if(incr_x_addr ==1) begin		
			addr_x <= addr_x + 1;
		end
	end
	
	// Used for ouput logic
	always_ff @(posedge clk) begin
		if (reset == 1 || clr3 == 1) begin
			output_cntr <= 0;	
		end
		else if(incr_output_cntr ==1) begin		
			output_cntr <= output_cntr + 1;
		end
	end
	
	// Counter for incrementing address for memory array used to store vector x
	always_ff @(posedge clk) begin
		if (reset == 1 || clr_cntr == 1) begin
			delay_cntr <= 0;	
		end
		else if(incr_delay_cntr == 1) begin		
			delay_cntr <= delay_cntr + 1;
		end
		else if(dec_delay_cntr == 1) begin		
			delay_cntr <= delay_cntr - 1;
		end
	end
	
	//output_ready is made synchronous
	always_ff @(posedge clk) begin
		if (reset == 1) 
			output_ready_r <= 0;
		else
			output_ready_r <= output_ready;
	end	
endmodule


 































module fc_6_6_16_1_1_W_rom_0(clk, addr, z_0);
   input clk;
   input [5:0] addr;
   output logic signed [15:0] z_0;
   always_ff @(posedge clk) begin
      case(addr)
        0: z_0<= -16'd124;
        1: z_0<= 16'd82;
        2: z_0<= 16'd101;
        3: z_0<= -16'd127;
        4: z_0<= -16'd15;
        5: z_0<= 16'd6;
        6: z_0<= -16'd99;
        7: z_0<= 16'd11;
        8: z_0<= 16'd105;
        9: z_0<= -16'd63;
        10: z_0<= -16'd45;
        11: z_0<= -16'd118;
        12: z_0<= -16'd21;
        13: z_0<= -16'd74;
        14: z_0<= -16'd36;
        15: z_0<= -16'd128;
        16: z_0<= 16'd40;
        17: z_0<= -16'd6;
        18: z_0<= -16'd74;
        19: z_0<= 16'd103;
        20: z_0<= -16'd83;
        21: z_0<= -16'd73;
        22: z_0<= 16'd97;
        23: z_0<= 16'd15;
        24: z_0<= -16'd104;
        25: z_0<= -16'd21;
        26: z_0<= -16'd57;
        27: z_0<= -16'd7;
        28: z_0<= 16'd124;
        29: z_0<= -16'd45;
        30: z_0<= -16'd11;
        31: z_0<= 16'd8192;
        32: z_0<= 16'd1061;
        33: z_0<= 16'd23514;
        34: z_0<= 16'd21250;
        35: z_0<= -16'd16234;
      endcase
   end
endmodule

