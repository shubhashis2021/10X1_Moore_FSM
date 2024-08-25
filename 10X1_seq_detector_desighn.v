//  design code  here
module state_machine_10x1 (clk,reset,x,z);
  input reg clk,reset,x;
  output reg z;
  reg [3:0] ns,ps;
  parameter  s0=0,s1=1,s10=2,s100=3,s101=4,s10X1=5;
  
  always @(posedge clk or posedge reset) begin
    if(reset)
      begin 
      ps<=s0;
      ns<=s0;
      z=0;
    end
    else ps<=ns;
  end
  
  always @(ps,x)begin
    case(ps)
      s0: begin
        z=0;
        ns=x?s1:s0;
      end
      
      s1:begin
        z=0;
        ns=x?s1:s10;
      end
      
       s10: begin
         z=0;
         ns=x?s101:s100;
       end
       

      s101:begin
        z=0;
        ns=x?s10X1:s10;
      end
      
            s100:begin
        z=0;
        ns=x?s10X1:s0;
      end
      
      
      s10X1:begin
        z=1;
        ns=x?s1:s0;
      end
      
      default:begin
        z=0;
        ns=s0;
      end
      
    endcase
  end
  
endmodule