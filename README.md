# DSP48A1 Slice Design for Spartan-6 FPGA
This repository contains the design, implementation, and verification of the DSP48A1 slice for Spartan-6 FPGAs. The project includes Verilog source files, testbenches, and documentation, along with detailed schematics for elaboration and synthesis. The design flow involves the use of Vivado for synthesis and implementation, and QuestaSim for simulation and verification.

## Repository Structure
├── src/
│ ├── DSP48A1.v # Main Verilog file for DSP48A1 slice
│ ├── Mux1_2.v # Verilog file for 1-to-2 multiplexer
│ ├── peline_stage_mod.v # Verilog file for pipeline stage module
│ ├── Post_adder_subtract.v # Verilog file for post-adder/subtractor
│ └── Pre_adder_subtract.v # Verilog file for pre-adder/subtractor

├── testbench/
│ ├── DSP48A1_tb.v # Testbench for DSP48A1 slice
│ └── run_DSP48A1.do # QuestaSim DO file for running simulations
├── docs/
│ ├── Youssi.pdf # Project manual/report
│ ├── Elaboration_sch_1.jpg # Elaboration schematic screenshot 1
│ ├── Elaboration_sch_2.jpg # Elaboration schematic screenshot 2
│ ├── synthesis_sch_1.jpg # Synthesis schematic screenshot 1
│ └── synthesis_sch_2.jpg # Synthesis schematic screenshot 2

## Tools Used
- **Vivado**: Used for the elaboration, synthesis, and implementation of the DSP48A1 design on Spartan-6 FPGAs.
- **QuestaSim**: Employed for simulation and verification of the design using directed test patterns.

## Key Features
- **Modular Design**: Includes Verilog modules for the DSP48A1 slice, multiplexers, and adder/subtractor stages.
- **Testbench & Simulation**: Provides a comprehensive testbench and DO file for functional verification using QuestaSim.
- **Elaboration & Synthesis**: Includes elaboration and synthesis schematics captured from Vivado, illustrating the design's implementation.
- **Documentation**: Complete project manual detailing the design, simulation, and synthesis processes.
