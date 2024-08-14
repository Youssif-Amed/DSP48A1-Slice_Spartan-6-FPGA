#create Work Folder
vlib work

#Compile files with names
vlog DSP48A1.v DSP48A1_tb.v Mux1_2.v Mux1_4.v  peline_stage_mod.v  Post_adder_substract.v  Pre_adder_substract.v

#simulate The TB file with module Name
vsim -voptargs=+acc work.DSP48A1_tb

#add objects name to wave Window
add wave -position insertpoint  \sim:/DSP48A1_tb/DUT/*

run -all

wave zoom full

