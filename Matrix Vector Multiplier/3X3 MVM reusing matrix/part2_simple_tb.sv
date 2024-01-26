// ESE-507 Project 2, Fall 2022
// This simple testbench is provided to help you in testing Project 2, Part 2.
// This testbench is not sufficient to test the full correctness of your system, it's just
// a relatively small test to help you get started.

// This test will:
//  - load one matrix
//  - load a vector
//  - wait for your system to compute the product
//  - load another vector (with new_matrix == 0)
//  - check that your system computes the product of the old matrix with this new vector
module check_timing();

   logic               clk, reset, input_valid, input_ready, output_valid, output_ready, new_matrix;

   logic signed [13:0] input_data;
   logic signed [27:0] output_data;
   
   logic [2:0] state, next_state; //remove debuG:output word delete
   logic clr_cntr, incr_delay_cntr, clr1, incr_w_addr, clr2, incr_x_addr;//remove debug
   logic [2:0]delay_cntr;//remove debug
   logic output_ready_r;
   logic [13:0] mem_x_r, mem_w_r;
   
   initial clk=0;
   always #5 clk = ~clk;
   

   // Instantiate DUT
   matvec3_part2 dut(clk, reset, input_valid, input_ready, input_data,new_matrix, output_valid, output_ready, output_data, state, next_state, mem_x_r, mem_w_r, clr_cntr, incr_delay_cntr, clr1, incr_w_addr, clr2, incr_x_addr, delay_cntr, output_ready_r,input_valid_r);  


   //////////////////////////////////////////////////////////////////////////////////////////////////
   // code to feed some test inputs

   // rb and rb2 represent random bits. Each clock cycle, we will randomize the value of these bits.
   // When rb is 0, we will not let our testbench send new data to the DUT.
   // When rb is 1, we can send data.
   logic rb, rb2;
   always begin
      @(posedge clk);
      #1;
      std::randomize(rb, rb2); // randomize rb
   end

   // Put our test data into these arrays. These are the values we will feed as input into the system.
   logic [13:0] invals[0:14] = '{10,-20,30,50,-60,70,80, 100, -110, 40, 30, -20, 50, -60, -70};

   logic [0:14] newInputMatrixVals = {1'b1, 11'bx, 1'b0, 2'bx};

   logic signed [23:0] expectedOut[0:5] = '{-800, -1200, 8400, -400, 1200, 5700};
    
   logic [15:0] j;

   // If input_valid is set to 1, we will put data on input_data.
   // If input_valid is 0, we will put an X on the input_data to test that your system does not 
   // process the invalid input.
   always @* begin
      if (input_valid == 1) begin
         input_data = invals[j];
         new_matrix = newInputMatrixVals[j];
      end
      else begin
         input_data = 'x;
         new_matrix = 'x;
      end
   end

   // If our random bit rb is set to 1, and if j is within the range of our test vector (invals),
   // we will set input_valid to 1.
   always @* begin
      if ((j>=0) && (j<15) && (rb==1'b1)) begin
         input_valid=1;
      end
      else
         input_valid=0;
   end

   // If we set input_valid and input_ready on this clock edge, we will increment j just after
   // this clock edge.
   always @(posedge clk) begin
      if (input_valid && input_ready)
         j <= #1 j+1;
   end

   ////////////////////////////////////////////////////////////////////////////////////////
   // code to receive the output values

   // we will use another random bit (rb2) to determine if we can assert output_ready.
   logic [31:0] i;
   always @* begin
      if ((i>=0) && (i<6) && (rb2==1'b1))
         output_ready = 1;
      else
         output_ready = 0;
   end

   integer errors=0;

   always @(posedge clk) begin
      if (output_ready && output_valid) begin
         if (output_data !== expectedOut[i]) 
            $display("ERROR:   y[%d] = %d     expected output = %d" , i, output_data, expectedOut[i]);
         else
            $display("SUCCESS: y[%d] = %d", i, output_data);
         
         i=i+1;
      end 
   end

   ////////////////////////////////////////////////////////////////////////////////

   initial begin
      j=0; i=0;   
      
      // Before first clock edge, initialize
      output_ready = 0; 
      reset = 0;
   
      // reset
      @(posedge clk); #1; reset = 1; 
      @(posedge clk); #1; reset = 0;

      wait(i==6);

      // Now we're done!

      // Just as a test: wait another 100 cycles and make sure the DUT doesn't assert output_valid again.
      // It shouldn't, because the system finished the inputs it was given, so it should be providing
      // for new output data.
      repeat(100) begin
         @(posedge clk);
         if (output_valid == 1)
             $display("ERROR: DUT asserted output_valid incorrectly");
      end
        
      $finish;
    end
      
   // This is just here to keep the testbench from running forever in case of error.
   // In other words, if your system never produces three outputs, this code will stop 
   // the simulation after 10000 clock cycles.
   initial begin
      repeat(10000) begin
         @(posedge clk);
      end
      $display("Warning: Output not produced within 10000 clock cycles; stopping simulation so it doens't run forever");
      $stop;
   end

endmodule