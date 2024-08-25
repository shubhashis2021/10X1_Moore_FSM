//verilog testbench code
module tb();
  reg clk,reset,x;
  wire z;
  state_machine_10x1 FSM (clk,reset,x,z);
  
  
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars;
  end
  
  initial begin
    reset=1'b1;
    clk=1'b0;
    #15 reset=1'b0;
  end
  
  always #5 clk=~clk;
  
  initial begin
    #12 x=0;#10 x=0;#10 x=0;#10 x=0;
    #10 x=1; #10 x=0; #10 x=1; #10 x=1;
    #10 x=0; #10 x=1; #10 x=0; #10 x=0;
    #10 x=1; #10 x=0; #10 x=0; #10 x=0;
    
    #10 $finish;
  end
  
  
  
  endmodule
  