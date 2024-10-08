# Introduction to  State Machines 

State machines are a fundamental concept in digital design, used to model and control sequential logic systems. Among the most common types are Moore and Mealy state machines. Both are finite state machines (FSMs) that transition between states based on inputs and produce outputs, but they differ in how the outputs are generated.

Moore State Machine

In a Moore state machine, the output is solely determined by the current state of the machine. The output does not directly depend on the inputs but only changes when the machine transitions to a different state. This characteristic makes the output stable and less prone to fluctuations caused by rapid input changes.

Key Characteristics:

	•	Output depends only on the current state.
	•	Predictable and stable outputs, as they are unaffected by input glitches.
	•	State transitions are triggered by inputs, but the output is based solely on the resulting state.



<img width="564" alt="Screenshot 2024-08-25 at 11 32 21 PM" src="https://github.com/user-attachments/assets/2d0dfc4d-79d6-443b-9e25-70fceca52d60">

Mealy State Machine

In a Mealy state machine, the output is determined by both the current state and the current input. This means that the output can change immediately when the input changes, making Mealy machines more responsive.

Key Characteristics:

	•	Output depends on both the current state and the input.
	•	More responsive to input changes since the output can update instantly.
	•	Potential for output glitches if the input changes rapidly.

 <img width="564" alt="Screenshot 2024-08-25 at 11 28 45 PM" src="https://github.com/user-attachments/assets/87327dee-1082-46be-b06b-cbd371f1e958">

 # Design Overview 
 The goal of this project is to implement a sequence detector that identifies the non-overlapping pattern 10X1 (where X can be either 0 or 1) using a Moore state machine. The design is developed in Verilog and includes both the sequence detector logic and a testbench for verification.

Key Features:

	•	Sequence Detection: The detector is designed to recognize the non-overlapping sequence 10X1 in a stream of binary inputs.
	•	Non-Overlapping Detection: Once the sequence is detected, the machine resets and does not allow overlapping matches, ensuring each sequence is detected separately.
	•	Moore State Machine: The design uses a Moore state machine where the output depends only on the current state, resulting in stable and predictable behavior.

# State Machine Design and State Diagram
The Moore state machine consists of multiple states, each representing a step in detecting the target sequence. The states and transitions are defined as follows:

	1.	S0(Initial State and reset state): The machine starts in the IDLE state, waiting for the first 1 in the sequence 10X1.
	2.	S1: When a 1 is detected, the machine transitions to S1.
	3.	S10: On detecting a 0 after 1, the machine moves to S10.
	4.	S10X: The machine transitions to s10X upon detecting either 0 or 1 after 10.
	5.	S10X1(FINAL STATE) : The machine transitions to S10X1 if the next input is 1, indicating that the full sequence 10X1 has been detected.
 
 <b>state diagram</b>
 ![WhatsApp Image 2024-08-25 at 23 55 43](https://github.com/user-attachments/assets/16eef7b4-e033-4566-aa2a-797c0ded1d47)

 
<b>Non-Overlapping Logic:</b>
To ensure non-overlapping detection, the state machine returns to the IDLE state after detecting the sequence, preventing immediate re-detection until a fresh sequence starts.

<b>Output Logic:</b>
The output is asserted high only when the machine reaches the final state (S10X1). Since this is a Moore machine, the output remains stable throughout the current state until the next state transition occurs.



# Verilog Implementation with testbench code
The design is fully implemented in Verilog, with a clear separation between the state machine logic and the sequence detection logic. Each state is encoded, and transitions are defined based on the current state and input.

```verilog

// Sequence Detector using Moore State Machine
module state_machine_10x1 (
  input clk,        // Clock signal
  input reset,      // Asynchronous reset signal
  input x,          // Input signal
  output reg z      // Output signal
);
  reg [3:0] ns, ps; // Next state and present state registers

  // State encoding
  parameter s0 = 0, s1 = 1, s10 = 2, s100 = 3, s101 = 4, s10X1 = 5;

  // Sequential logic for state transitions
  always @(posedge clk or posedge reset) begin
    if (reset) begin
      ps <= s0;
      ns <= s0;
      z <= 0;
    end
    else begin
      ps <= ns;
    end
  end

  // Combinational logic for state transitions and output
  always @(ps, x) begin
    case (ps)
      s0: begin
        z = 0;
        ns = x ? s1 : s0;
      end
      
      s1: begin
        z = 0;
        ns = x ? s1 : s10;
      end
      
      s10: begin
        z = 0;
        ns = x ? s101 : s100;
      end

      s101: begin
        z = 0;
        ns = x ? s10X1 : s10;
      end
      
      s100: begin
        z = 0;
        ns = x ? s10X1 : s0;
      end
      
      s10X1: begin
        z = 1; // Output high when the sequence '10X1' is detected
        ns = x ? s1 : s0;
      end
      
      default: begin
        z = 0;
        ns = s0;
      end
    endcase
  end
endmodule

```
# Testbench Code 

<b>Test Sequence</b>

The test sequence applied in the testbench is 1111101101001000. This sequence was chosen because it covers multiple scenarios:

	•	Initial Noise (11111): The sequence starts with several 1s, testing the machine’s ability to ignore irrelevant patterns.
	•	Valid Sequence Detection (0110100): The sequence 0110100 contains a valid instance of 10X1, which should trigger the output.
	•	Resetting to Initial State (1000): After detecting a sequence, the machine should reset to detect new valid patterns in subsequent inputs.
<b> Expected Behavior</b>

The expected behavior of the state machine when processing the test sequence is as follows:

	1.	For the first few 1s: The machine remains in state s1, waiting for a 0 to move to the next state.
	2.	Upon detecting 0: The machine transitions through the states until it detects a full match for 10X1.
	3.	After the match is found: The output z should be high, and the state machine should reset to search for another non-overlapping occurrence.

<b>Importance of Non-Overlapping Detection</b>

This test sequence also ensures that overlapping sequences do not trigger incorrect output. For instance, after detecting 10X1, if another 1 follows immediately, the machine should reset and not trigger the output again until a fresh sequence is detected.

This section provides a clear explanation of how the testbench operates and the significance of the chosen test sequence in verifying the sequence detector’s functionality.
 
```verilog
 
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

```

# Output Results
Testbench Output Waveform

In a waveform view, one would observe:

	•	The output z being asserted high (switching from 0 to 1) only when the 10X1 sequence is detected.
	•	The output remains low for all other parts of the sequence, confirming that the machine does not respond to irrelevant patterns.
	•	After detecting the sequence, the output should return to low, showing that the state machine is correctly handling non-overlapping sequences.

Key Points of the Output

	•	Single-Cycle Assertion: The output is asserted for only one clock cycle, corresponding to the detection of the sequence.
	•	Reset Behavior: After detecting 10X1, the output returns low, indicating that the state machine is ready to detect another instance of the sequence.
	•	Edge Case Coverage: The test sequence includes edge cases, such as multiple 1s at the beginning and sequences that don’t match 10X1, ensuring robustness of the design.

This output analysis provides insight into what you should expect when running the testbench, helping to verify that your sequence detector is working as intended.

<img width="1700" alt="Screenshot 2024-08-26 at 12 27 18 AM" src="https://github.com/user-attachments/assets/40f85d9d-62cb-411f-9a05-0592087f5f36">













 
     




