// Peter Milder

// This is a very small testbench for you to check that you have the right
// idea for the input/output timing.

// This should not be your only test -- it's simply a basic way to make
// sure you have the right idea.

module tb_part2_mac();

   logic clk, reset, valid_in, valid_out;
   logic signed [13:0] a, b;
   logic signed [27:0] f;
   logic signed [13:0] testData[399999:0];
   integer i;
   part2_mac dut(.clk(clk), .reset(reset), .a(a), .b(b), .valid_in(valid_in), .f(f), .valid_out(valid_out));

   initial clk = 0;
   always #5 clk = ~clk;

   initial $readmemh("inputData", testData);

   initial begin

      // Before first clock edge, initialize
      reset = 1;
      @(posedge clk);
      #1;
      reset = 0; a =0; b= 0; valid_in=1;

    /*  for (i=0; i<100000; i=i+1) begin
	  @(posedge clk);
	  #1; valid_in = testData[4*i];
	  a = testData[4*i+1][13:0];
	  b = testData[4*i+2][13:0];
          reset = testData[4*i+3];
      end */
      
      @(posedge clk);
      #1;
      reset = 0; a = 8191; b = 8191; valid_in = 1;
      @(posedge clk);
      #1;
      reset = 0; a = 8191; b = 8191; valid_in = 1;
      $display("a = %d, b = %d", a, b);
      @(posedge clk);
      #1;
      reset = 0; a = 1000; b = 1000; valid_in = 1;
      $display("a = %d, b = %d", a, b);
      @(posedge clk);
      #1;
      reset = 0; a = -1000; b = 1260; valid_in = 1;
      $display("a = %d, b = %d", a, b);
      @(posedge clk);
      #1;
      reset = 0; a = 1300; b = 1780; valid_in = 1;
      $display("a = %d, b = %d", a, b);
      @(posedge clk);
      #1;
      reset = 0; a = 1400; b = 33; valid_in = 1;
      $display("a = %d, b = %d", a, b);
      @(posedge clk);
      #1;
      reset = 0; a = 1000; b = 1000; valid_in = 1;
      $display("a = %d, b = %d", a, b);
      @(posedge clk);
      #1;
      reset = 1; a = -13; b = 1; valid_in = 1;
      $display("a = %d, b = %d", a, b);
      @(posedge clk);
      #1;
      reset = 0; a = -8192; b = 8191; valid_in = 1;
      $display("a = %d, b = %d", a, b);
      @(posedge clk);
      #1
      reset = 0; a = -8192; b = 8191; valid_in = 1;
      $display("a = %d, b = %d", a, b);
      @(posedge clk);
      #1;
      reset = 0; a = 1000; b = -1000; valid_in = 1;
      $display("a = %d, b = %d", a, b);
      @(posedge clk);
      #1;
      reset = 0; a = 1; b = -1; valid_in = 1;
      $display("a = %d, b = %d", a, b);
      @(posedge clk);
      #1;
      reset = 1; a = -13; b = 1; valid_in = 1; 
      $display("a = %d, b = %d", a, b);
      @(posedge clk);
      #1;
      @(posedge clk);
      #20;
      $finish;
   end // initial begin

      integer filehandle=$fopen("outValues");
      always @(posedge clk)
          $fdisplay(filehandle, "%x %x", f, valid_out);
     

endmodule 
