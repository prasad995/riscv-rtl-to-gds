read_liberty /opt/pdks/sky130/sky130_fd_sc_hd__tt_025C_1v80.lib
read_verilog /home/prasad/riscv-rtl-to-gds/results/riscv_core_sky130.v
link_design riscv_core
read_sdc /home/prasad/riscv-rtl-to-gds/constraints/riscv_core.sdc
check_setup
report_checks -path_delay min_max -fields {slew cap input fanout} -format full_clock_expanded -digits 4
report_worst_slack -max
report_tns -max
report_worst_slack -min
report_tns -min
exit
