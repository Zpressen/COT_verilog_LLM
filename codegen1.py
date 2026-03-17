import json
import time
import threading
from concurrent.futures import ThreadPoolExecutor
from openai import OpenAI

# 配置DeepSeek API
llm_config = {
    'model': "deepseek-chat",
    'api_key': "sk-e912f0d4808342869d846ee83d3ac7c5",
    'base_url': "https://api.deepseek.com/v1"
}

Verilog_Prompt = """You are a Verilog RTL designer that only writes code using correct Verilog syntax and verify the functionality. Please generate the thought process based on the above problem_description and code, including subtasks and code generation. The generated thought process should be in English
[Example Begins]
### Input
  {
    "file_name": "ov2640_read.v",
    "problem description": "### Problem Description:  \nThis Verilog module, `camera_reader`, implements an interface for reading image data from an **OV2640 camera sensor** (or similar CSI interface). It captures pixel data from the camera, processes it, and stores it in memory.  \n\n#### Key Functions:  \n1. **Clock Generation**:  \n   - Outputs `csi_xclk` (camera clock) when `reset_n` is active.  \n2. **Pixel Data Capture**:",
    "code": "`timescale 1ns/ 1ps\n\nmodule camera_reader\n(\n\tinput \twire \t\tclk,\n\tinput \twire \t\treset_n,\n\t\n\toutput \twire \t\tcsi_xclk,\n\t\n\tinput \twire \t\tcsi_pclk,\n\tinput \twire [7:0] \tcsi_data,\n\tinput \twire \t\tcsi_vsync,\n\tinput \twire \t\tcsi_hsync,\n\t\n\toutput \treg  [15:0] data_out = 0,\n\toutput \twire \t\twrreq,\n\toutput \twire \t\twrclk,\n\toutput \treg  [19:0]\twraddr\n);\n\nreg [19:0] pixel_counter = 0;\nassign csi_xclk  = (reset_n == 1) ? clk : 0;\nreg vsync_passed = 0;\nreg write_pixel  = 0;\nreg [7:0] \tsubpixel;\nreg [15:0] \tcurrent_pixel;\nreg wrclk1 = 0;\n\nalways@(posedge csi_pclk)\nbegin\n\twrclk1 <= ~wrclk1;\nend\n\nalways@(negedge wrclk1)\nbegin\n\tif(csi_hsync == 1)\n\t\twrite_pixel <= 1;\n\telse\n\t\twrite_pixel <= 0;\nend\n\nalways@(posedge wrreq )\nbegin\n\tdata_out <= current_pixel;\nend\n\nalways@(posedge csi_pclk or negedge reset_n)\nbegin\n\tif(reset_n == 0)\n\tbegin\n\t\tpixel_counter <= 0;\n\t\tvsync_passed <= 0;\n\tend\n\telse\n\tbegin\n\t\tif(csi_vsync == 1)\n\t\tbegin\n\t\t\tpixel_counter <= 0;\n\t\t\tvsync_passed <= 1;\n\t\t\twraddr <= 0;\n\t\tend\n\t\telse\n\t\t\tif(csi_hsync == 1 && vsync_passed == 1)\n\t\t\tbegin\n\t\t\t\tif(pixel_counter[0] == 0)\n\t\t\t\tbegin\n\t\t\t\t\tpixel_counter <= pixel_counter + 1;\n\t\t\t\t\tsubpixel <= csi_data;\n\t\t\t\tend\n\t\t\t\telse\n\t\t\t\tbegin\n\t\t\t\t\t//current_pixel <= { subpixel, csi_data };\n\t\t\t\t\tcurrent_pixel <= { csi_data , subpixel };\n\t\t\t\t\tpixel_counter <= pixel_counter + 1;\n\t\t\t\t\twraddr <= wraddr + 1;\n\t\t\t\tend\n\t\t\tend\n\t\t\telse\n\t\t\tbegin\n\t\t\t\tif(write_pixel == 1)\n\t\t\t\t\tpixel_counter <= pixel_counter + 1;\n\t\t\t\telse\n\t\t\t\t\tpixel_counter <= 0;\n\t\t\tend\n\tend\nend\n\nassign wrreq = (write_pixel == 1) && pixel_counter > 2 ? wrclk1 : 0;\nassign wrclk = ~csi_pclk;//~csi_pclk;\n\nendmodule\n"
  },

### Output
<think>
Let's think step by step. 

[Instruction]
Based on the Problem description, set up a sequential implementation plans. Each subtask should focus on implement only one signal at a time. 
Extract the corresponding source contexts in the [Target Problem] section of each subtask into the 'source' field. 

- If the 'source' is a part of K-map, you must extract the corresponding row or column. Below is an example of extracting a row or a column in K-map.
[K-map Table Example]:
             a,b      
  c,d  0,0 0,1 1,1 1,0 
  0,0 | 0 | 0 | 0 | 1 |
  0,1 | 1 | 0 | 0 | 0 |
  1,1 | d | 1 | 0 | 1 |
  1,0 | 0 | 0 | 0 | 0 |

  [Extract Row (c,d) = (1,1)]
  ```
  The output row is below
             a,b
  c,d  0,0 0,1 1,1 1,0
  1,1 | d | 1 | 0 | 1 |
  ```

  [Extract Column (a,b) = (1,0)]
  ```
  The output column is below. 
       a,b
  c,d  1,0  
  0,0 | 1 |
  0,1 | 0 | 
  1,1 | 1 | 
  1,0 | 0 |
  ```

[K-map Table Example End]

The task id number indicates the sequential orders. Return the subtasks in json format as below. 
```json
{SubtaskExample}
```

[Rules]
Make sure the task plans satisfy the following rules! Do not make the plans that violate the following rules!!!
- Make a plan to define the module with its input and output first.
- Do not plan the implementation of logic or signal from the input ports.
- There is test bench to test the functional correctness. Do not plan generating testbench to test the generated verilog code. 
- Don't make a plan only with clock or control signals. The clock or control signals should be planned with register or wire signal.
- Don't make a plan on implementing the signal or next state logics which are not related to the module outputs.
- For module related to Finite State Machine (FSM), try to determine the number of states first and then make the plan to implement FSM.
- For module related to Finite State Machine or Moore State Machine, if the state or current_state is a input port signal of the module, You must Do Not implement the state flip-flops for state transition as the example below in TopModule. 
  [State flip-flops for Transition Block Example]
  always@(*) begin
    ...
    state <= next_state;
    ...
  end
  [State flip-flops for Transition Block Example End]

Based on the problem description and code, we need to generate an implementation plan.
Steps:
1. Analysis module function: The main function of this module is to generate camera clock (CSIuxclk), capture camera data (CSIudata), process synchronization signals (CSIuvsync, CSIuhsync), and then store the processed pixel data in memory (through signals such as data_out, wrreq, wrclk, wradr, etc.).
2. Generate implementation plans (subtasks) based on Verilog-Plan_Template-Prompt. Pay attention to the rules:
-Firstly, define the module and its input/output.
-Do not implement logic for input ports.
-Do not generate a testing platform.
-For a state machine, first determine the number of states, and then implement the state machine.
3. Since this module involves data capture and state control (such as processing VSYNC and HSYNC), we can consider it as a state machine (waiting for VSYNC, waiting for HSYNC, capturing data, etc.)? But there is no obvious status register in the code, instead it is controlled by some flag signals (vsync_cassed) and counters (pixelcounter). Therefore, we may need to decompose the implementation into several subtasks.
4. Based on the code, we can decompose the implementation into the following subtasks:
a. Define modules and ports.
b. Generate camera clock (csi_xclk).
c. Processing VSYNC signal: When VSYNC is valid, reset the address and counter, and set the vsync_cassed flag.
d. Processing HSYNC signal: When HSYNC is valid and has passed VSYNC (vsync_cassed=1), data capture begins. Note that each pixel consists of two bytes (distinguished by the parity of pixelcounter).
e. Generate write requests (wrreq) and write clocks (wrclk).
f. Output the concatenated pixel data (16 bits) (data_out) and increment the write address (wradr).
5. Generate code in the order of subtasks.
6. Attention: When generating code, follow the rules:
-Only implement the current subtask.
-Do not modify the previous code.
-Declare ports and signals using the logic type.
-For combinational logic, use always @ (*), and for sequential logic, use always @ (pose clk or negege reset_n), etc.
7. JSON format for generating subtasks:
```json
{
  "subtasks": [
    {
      "id": "1",
      "content": "Define module camera_reader with input ports: clk, reset_n, csi_pclk, csi_data[7:0], csi_vsync, csi_hsync; and output ports: csi_xclk, data_out[15:0], wrreq, wrclk, wraddr[19:0]. Declare internal registers: pixel_counter[19:0], vsync_passed, write_pixel, subpixel[7:0], current_pixel[15:0], wrclk1.",
      "subcode": "timescale 1ns/ 1ps\n\nmodule camera_reader\n"
    },
    {
      "id": "2",
      "content": "Generate the camera clock (csi_xclk) from the system clock (clk) when reset_n is active, otherwise output 0.",
      "subcode": "assign csi_xclk  = (reset_n == 1) ? clk : 0;"
    },
    {
      "id": "3",
      "content": "Generate the write clock domain signal (wrclk1) by toggling on every positive edge of csi_pclk. Then assign the output wrclk to be the inverted csi_pclk.",
      "subcode": "always@(posedge csi_pclk)\nbegin\n\twrclk1 <= ~wrclk1;\nend\n\nassign wrclk = ~csi_pclk;"
    },
    {
      "id": "4",
      "content": "Generate the write_pixel signal by sampling csi_hsync on the negative edge of wrclk1.",
      "subcode": "always@(negedge wrclk1)\nbegin\n\tif(csi_hsync == 1)\n\t\twrite_pixel <= 1;\n\telse\n\t\twrite_pixel <= 0;\nend"
    },
    {
      "id": "5",
      "content": "Implement the main control logic: handle reset, vsync, hsync, and data capture. This includes capturing two bytes to form a 16-bit pixel and updating the write address (wraddr).",
      "subcode": "always@(posedge csi_pclk or negedge reset_n)\nbegin\n\tif(reset_n == 0)\n\tbegin\n\t\tpixel_counter <= 0;\n\t\tvsync_passed <= 0;\n\tend\n\telse\n\tbegin\n\t\tif(csi_vsync == 1)\n\t\tbegin\n\t\t\tpixel_counter <= 0;\n\t\t\tvsync_passed <= 1;\n\t\t\twraddr <= 0;\n\t\tend\n\t\telse\n\t\t\tif(csi_hsync == 1 && vsync_passed == 1)\n\t\t\tbegin\n\t\t\t\tif(pixel_counter[0] == 0)\n\t\t\t\tbegin\n\t\t\t\t\tpixel_counter <= pixel_counter + 1;\n\t\t\t\t\tsubpixel <= csi_data;\n\t\t\t\tend\n\t\t\t\telse\n\t\t\t\tbegin\n\t\t\t\t\tcurrent_pixel <= { csi_data , subpixel };\n\t\t\t\t\tpixel_counter <= pixel_counter + 1;\n\t\t\t\t\twraddr <= wraddr + 1;\n\t\t\t\tend\n\t\t\tend\n\t\t\telse\n\t\t\tbegin\n\t\t\t\tif(write_pixel == 1)\n\t\t\t\t\tpixel_counter <= pixel_counter + 1;\n\t\t\t\telse\n\t\t\t\t\tpixel_counter <= 0;\n\t\t\tend\n\tend\nend"
    },
    {
      "id": "6",
      "content": "Generate the write request (wrreq) signal: it is active (wrclk1) when write_pixel is 1 and pixel_counter is greater than 2, otherwise 0.",
      "subcode": "assign wrreq = (write_pixel == 1) && pixel_counter > 2 ? wrclk1 : 0;"
    },
    {
      "id": "7",
      "content": "Update the data_out register on the rising edge of wrreq.",
      "subcode": "always@(posedge wrreq )\nbegin\n\tdata_out <= current_pixel;\nend"
    }
  ]
}
```
8. Then, generate code for each subtask. Note that we gradually build modules in the order of subtasks.
9. Finally, we generate the complete module code.
[Hints]:Make a plan to construct the state machine transition table. In the plan, you must explain the state transitions with bulletins.
</think>
<code>
"`timescale 1ns/ 1ps\n\nmodule camera_reader\n(\n\tinput \twire \t\tclk,\n\tinput \twire \t\treset_n,\n\t\n\toutput \twire \t\tcsi_xclk,\n\t\n\tinput \twire \t\tcsi_pclk,\n\tinput \twire [7:0] \tcsi_data,\n\tinput \twire \t\tcsi_vsync,\n\tinput \twire \t\tcsi_hsync,\n\t\n\toutput \treg  [15:0] data_out = 0,\n\toutput \twire \t\twrreq,\n\toutput \twire \t\twrclk,\n\toutput \treg  [19:0]\twraddr\n);\n\nreg [19:0] pixel_counter = 0;\nassign csi_xclk  = (reset_n == 1) ? clk : 0;\nreg vsync_passed = 0;\nreg write_pixel  = 0;\nreg [7:0] \tsubpixel;\nreg [15:0] \tcurrent_pixel;\nreg wrclk1 = 0;\n\nalways@(posedge csi_pclk)\nbegin\n\twrclk1 <= ~wrclk1;\nend\n\nalways@(negedge wrclk1)\nbegin\n\tif(csi_hsync == 1)\n\t\twrite_pixel <= 1;\n\telse\n\t\twrite_pixel <= 0;\nend\n\nalways@(posedge wrreq )\nbegin\n\tdata_out <= current_pixel;\nend\n\nalways@(posedge csi_pclk or negedge reset_n)\nbegin\n\tif(reset_n == 0)\n\tbegin\n\t\tpixel_counter <= 0;\n\t\tvsync_passed <= 0;\n\tend\n\telse\n\tbegin\n\t\tif(csi_vsync == 1)\n\t\tbegin\n\t\t\tpixel_counter <= 0;\n\t\t\tvsync_passed <= 1;\n\t\t\twraddr <= 0;\n\t\tend\n\t\telse\n\t\t\tif(csi_hsync == 1 && vsync_passed == 1)\n\t\t\tbegin\n\t\t\t\tif(pixel_counter[0] == 0)\n\t\t\t\tbegin\n\t\t\t\t\tpixel_counter <= pixel_counter + 1;\n\t\t\t\t\tsubpixel <= csi_data;\n\t\t\t\tend\n\t\t\t\telse\n\t\t\t\tbegin\n\t\t\t\t\t//current_pixel <= { subpixel, csi_data };\n\t\t\t\t\tcurrent_pixel <= { csi_data , subpixel };\n\t\t\t\t\tpixel_counter <= pixel_counter + 1;\n\t\t\t\t\twraddr <= wraddr + 1;\n\t\t\t\tend\n\t\t\tend\n\t\t\telse\n\t\t\tbegin\n\t\t\t\tif(write_pixel == 1)\n\t\t\t\t\tpixel_counter <= pixel_counter + 1;\n\t\t\t\telse\n\t\t\t\t\tpixel_counter <= 0;\n\t\t\tend\n\tend\nend\n\nassign wrreq = (write_pixel == 1) && pixel_counter > 2 ? wrclk1 : 0;\nassign wrclk = ~csi_pclk;//~csi_pclk;\n\nendmodule\n"
</code>
[Example End]

[Example Begin]
### Input
{
    "file_name": "debounce.v",
    "problem description": "### Problem Description:  \nThis Verilog module implements a **debounce circuit** for `N` input keys (buttons or switches). It filters out mechanical bounce noise from the inputs, ensuring stable output pulses (`key_pulse`) only when a key is pressed and held for approximately **20ms** (configurable via `CNT_20MS`).  \n\n#### Key Features:  \n1. **Debounce Time**: Uses a counter (`cnt`) to wait for `CNT_20MS",
    "code": "module debounce \n#(\n\tparameter  N         =  2,\n\tparameter  CNT_20MS  =  19'h75601//?μí3ê±?ó24MHz￡?òa?óê±20ms×óóòê±??\n)\n(\n\tinput\twire         clk,\n\tinput\twire         rst_n,\n\t// key\n\tinput   wire [N-1:0] key,\n\toutput\twire [N-1:0] key_pulse\n); \n  \nreg [18:0]\tcnt; //2úéú?óê±?ùó?μ???êy?÷￡??μí3ê±?ó24MHz￡?òa?óê±20ms×óóòê±??   \n\nalways@(posedge clk or negedge rst_n)\nbegin\n     if(!rst_n)\n          cnt <= 0;\n     else if(cnt == CNT_20MS)\n          cnt <= 0;\n     else\n          cnt <= cnt + 1'h1;\nend  \n\nreg [N-1:0] key_sec_pre;                \nreg [N-1:0] key_sec;                      \n\nalways@(posedge clk  or  negedge rst_n)\nbegin\n     if(!rst_n) \n         key_sec <= {N{1'b1}};                \n     else if(cnt == CNT_20MS)\n         key_sec <= key;  \nend\n\nalways@(posedge clk  or  negedge rst_n)\nbegin\n     if(!rst_n)\n         key_sec_pre <= {N{1'b1}};\n     else                   \n         key_sec_pre <= key_sec;             \nend  \n    \nassign  key_pulse = ~key_sec & key_sec_pre ;     \n \nendmodule"
},

### Output
<think>
Let's think step by step.

[Instruction]
Based on the Problem description, set up a sequential implementation plans. Each subtask should focus on implement only one signal at a time. 
Extract the corresponding source contexts in the [Target Problem] section of each subtask into the 'source' field. 

- If the 'source' is a part of K-map, you must extract the corresponding row or column. Below is an example of extracting a row or a column in K-map.
[K-map Table Example]:
             a,b      
  c,d  0,0 0,1 1,1 1,0 
  0,0 | 0 | 0 | 0 | 1 |
  0,1 | 1 | 0 | 0 | 0 |
  1,1 | d | 1 | 0 | 1 |
  1,0 | 0 | 0 | 0 | 0 |

  [Extract Row (c,d) = (1,1)]
  ```
  The output row is below
             a,b
  c,d  0,0 0,1 1,1 1,0
  1,1 | d | 1 | 0 | 1 |
  ```

  [Extract Column (a,b) = (1,0)]
  ```
  The output column is below. 
       a,b
  c,d  1,0  
  0,0 | 1 |
  0,1 | 0 | 
  1,1 | 1 | 
  1,0 | 0 |
  ```

[K-map Table Example End]

The task id number indicates the sequential orders. Return the subtasks in json format as below. 
```json
{SubtaskExample}
```

[Rules]
Make sure the task plans satisfy the following rules! Do not make the plans that violate the following rules!!!
- Make a plan to define the module with its input and output first.
- Do not plan the implementation of logic or signal from the input ports.
- There is test bench to test the functional correctness. Do not plan generating testbench to test the generated verilog code. 
- Don't make a plan only with clock or control signals. The clock or control signals should be planned with register or wire signal.
- Don't make a plan on implementing the signal or next state logics which are not related to the module outputs.
- For module related to Finite State Machine (FSM), try to determine the number of states first and then make the plan to implement FSM.
- For module related to Finite State Machine or Moore State Machine, if the state or current_state is a input port signal of the module, You must Do Not implement the state flip-flops for state transition as the example below in TopModule. 
  [State flip-flops for Transition Block Example]
  always@(*) begin
    ...
    state <= next_state;
    ...
  end
  [State flip-flops for Transition Block Example End]

Based on the problem description and code, we need to generate an implementation plan.
Steps:
1. Analysis module function: The main function of this module is to debounce N input keys by filtering out mechanical bounce noise and generating stable output pulses (key_pulse) only when a key is pressed and held for approximately 20ms.
2. Generate implementation plans (subtasks) based on Verilog-Plan_Template-Prompt. Pay attention to the rules:
- First, define the module and its input/output.
- The module uses a counter to implement the debounce timing.
- It needs to sample the input keys at specific intervals (20ms).
- The output pulse is generated when a key transition is detected (from not pressed to pressed).
3. Since this module involves several modules, we may need to decompose theimplementation into several subtasks.
4. Based on the code, we can decompose the implementation into following subtasks:
5. Define module and parameters (N, CNT_20MS).
b. Implement the 20ms counter (cnt).
c. Sample the input keys at 20ms intervals (key_sec).
d. Register the previous key state (key_sec_pre).
e. Generate output pulses when key transitions are detected (key_pulse).
5. Generate code in the order of subtasks.
6. Attention: When generating code, follow the rules:
-Only implement the current subtask.
-Do not modify the previous code.
-Declare ports and signals using the logic type.
-For combinational logic, use always @ (*), and for sequential logic, use always @ (pose clk or negege reset_n), etc.
7. JSON format for generating subtasks:
```json
{
  "subtasks": [
    {
      "id": "1",
      "content": "Define module debounce with parameters N (number of keys) and CNT_20MS (20ms counter value). Declare input ports: clk, rst_n, key[N-1:0]; and output port: key_pulse[N-1:0]. Declare internal registers: cnt[18:0], key_sec[N-1:0], key_sec_pre[N-1:0].",
      "subcode": "module debounce 
#(
	parameter  N         =  2,
	parameter  CNT_20MS  =  19'h75601"
    },
    {
      "id": "2",
      "content": "Implement the 20ms counter (cnt) that resets when reaching CNT_20MS or when reset is active.",
      "subcode": "always@(posedge clk or negedge rst_n)
begin
     if(!rst_n)
          cnt <= 0;
     else if(cnt == CNT_20MS)
          cnt <= 0;
     else
          cnt <= cnt + 1'h1;
end"
    },
    {
      "id": "3",
      "content": "Sample the input keys (key) into key_sec register at every 20ms interval (when cnt == CNT_20MS). Initialize to all 1's during reset.",
      "subcode": "always@(posedge clk  or  negedge rst_n)
begin
     if(!rst_n) 
         key_sec <= {N{1'b1}};                
     else if(cnt == CNT_20MS)
         key_sec <= key;  
end"
    },
    {
      "id": "4",
      "content": "Register the previous key state (key_sec_pre) by delaying key_sec by one clock cycle. Initialize to all 1's during reset.",
      "subcode": "always@(posedge clk  or  negedge rst_n)
begin
     if(!rst_n)
         key_sec_pre <= {N{1'b1}};
     else                   
         key_sec_pre <= key_sec;             
end"
    },
    {
      "id": "5",
      "content": "Generate output pulses (key_pulse) when a key transition from not pressed (1) to pressed (0) is detected.",
      "subcode": "assign  key_pulse = ~key_sec & key_sec_pre ;"
    }
  ]
}
```
8. Then, generate code for each subtask in order.
9. Finally, we generate the complete module code.
</think>
<code>
module debounce 
#(
	parameter  N         =  2,
	parameter  CNT_20MS  =  19'h75601//?μí3ê±?ó24MHz￡?òa?óê±20ms×óóòê±??
)
(
	input	wire         clk,
	input	wire         rst_n,
	// key
	input   wire [N-1:0] key,
	output	wire [N-1:0] key_pulse
); 

reg [18:0]	cnt; //2úéú?óê±?ùó?μ???êy?÷￡??μí3ê±?ó24MHz￡?òa?óê±20ms×óóòê±??   

always@(posedge clk or negedge rst_n)
begin
     if(!rst_n)
          cnt <= 0;
     else if(cnt == CNT_20MS)
          cnt <= 0;
     else
          cnt <= cnt + 1'h1;
end  

reg [N-1:0] key_sec_pre;                
reg [N-1:0] key_sec;                      

always@(posedge clk  or  negedge rst_n)
begin
     if(!rst_n) 
         key_sec <= {N{1'b1}};                
     else if(cnt == CNT_20MS)
         key_sec <= key;  
end

always@(posedge clk  or  negedge rst_n)
begin
     if(!rst_n)
         key_sec_pre <= {N{1'b1}};
     else                   
         key_sec_pre <= key_sec;             
end  

assign  key_pulse = ~key_sec & key_sec_pre ;     

endmodule
</code>
[Example End]
"""


def get_deepseek_response(question, client):
    """调用DeepSeek API获取响应"""
    conversation_history = [
        {"role": "system", "content": Verilog_Prompt},
        {"role": "user", "content": question}
    ]

    try:
        response = client.chat.completions.create(
            model=llm_config['model'],
            messages=conversation_history,
            temperature=0.7,
            max_tokens=8192,
            stream=False
        )
        return response.choices[0].message.content
    except Exception as e:
        print(f"API调用错误: {str(e)}")
        return None


def process_single_module(module, index, total, results, lock, output_file):
    """处理单个Verilog模块"""
    print(f"处理模块 {index + 1}/{total}: {module['file_name']}")

    # 为每个线程创建独立的API客户端
    client = OpenAI(api_key=llm_config['api_key'], base_url=llm_config['base_url'])

    # 构造问题
    question = f"""
    Input:
      {{
        "file_name": "{module['file_name']}",
        "problem description": "{module['problem description']}",
        "code": "{module['code']}"
      }},
    please generate the Output(first <think> then <code>), and the <think> should be consistent with the example".
    """

    # 获取API响应
    response = get_deepseek_response(question, client)

    if response:
        try:
            # 解析响应中的<think>和<code>
            think_content = response.split("<think>")[1].split("</think>")[0].strip()
            code_content = response.split("<code>")[1].split("</code>")[0].strip()

            result = {
                "input": module,
                "output": {
                    "think": think_content,
                    "code": code_content
                }
            }
        except Exception as e:
            print(f"解析响应失败: {str(e)}")
            result = {
                "input": module,
                "output": f"响应解析失败: {str(e)}"
            }
    else:
        result = {
            "input": module,
            "output": "API调用失败"
        }

    # 使用锁保护共享资源
    with lock:
        results.append(result)
        # 保存进度
        with open(output_file, 'w') as f:
            json.dump(results, f, indent=2)

    print(f"模块 {index + 1} 处理完成")
    return result


def process_verilog_modules(input_file, output_file, max_workers=5):
    """批量处理Verilog模块（并行版）"""
    # 读取输入数据
    with open(input_file, 'r', encoding='utf-8') as f:
        modules = json.load(f)

    results = []
    lock = threading.Lock()
    total_modules = len(modules)

    # 使用线程池并行处理
    with ThreadPoolExecutor(max_workers=max_workers) as executor:
        futures = []
        for i, module in enumerate(modules):
            future = executor.submit(
                process_single_module,
                module, i, total_modules,
                results, lock, output_file
            )
            futures.append(future)

        # 等待所有任务完成
        for future in futures:
            future.result()  # 可以处理异常或获取结果

    print(f"处理完成！结果已保存至 {output_file}")
    return results


# 使用示例
if __name__ == "__main__":
    input_json = "process2.json"
    output_json = "processed_output_parallel2.json"

    # 设置并发工作线程数（根据API限制调整）
    process_verilog_modules(input_json, output_json, max_workers=2)