
//For compiling and simulation,


$ vlog *_tb.sv *.sv

//for compiling designware components
$ vlog /home/home4/pmilder/ese507/synthesis/sim_ver/DW02_mult*.v

$ vsim -sv_seed 5 tbench_name -c -do "run -all"

//for synthesis
$ dc_shell -f runsynth.tcl | tee output.txt
