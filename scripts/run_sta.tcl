# ==============================================================================
# OpenSTA Static Timing Analysis Script for RISC-V RV32I Core
# Technology: SkyWater 130nm High-Density (sky130_fd_sc_hd)
# ==============================================================================

# 1. Read Standard Cell Timing Library (.lib)
read_liberty /opt/pdks/sky130/sky130_fd_sc_hd__tt_025C_1v80.lib

# 2. Read Synthesized Gate-Level Netlist (.v)
read_verilog results/riscv_core_sky130.v

# 3. Link Top Design
link_design riscv_core

# 4. Read Synopsys Design Constraints (.sdc)
read_sdc constraints/riscv_core.sdc

# 5. Check Timing Setup
check_setup

# 6. Report Clocks and Timing Checks
report_checks -path_delay min_max -fields {slew cap input nets fanout} -format full_clock_expanded -digits 4

# 7. Report Setup (Max) Timing & Worst Negative Slack (WNS)
report_worst_slack -max
report_tns -max

# 8. Report Hold (Min) Timing
report_worst_slack -min
report_tns -min

# 9. Print Top 5 Longest Delay Critical Paths
report_checks -max_paths 5 -digits 4
