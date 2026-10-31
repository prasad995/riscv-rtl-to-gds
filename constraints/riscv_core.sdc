# ==============================================================================
# Synopsys Design Constraints (SDC) for RISC-V RV32I Core
# Target Node: SkyWater 130nm (sky130_fd_sc_hd)
# ==============================================================================

# 1. Define Primary Clock: 50 MHz (Period = 20.0 ns)
create_clock -name clk -period 20.000 [get_ports clk]

# 2. Clock Uncertainty (Jitter + Skew margin = 250 ps)
set_clock_uncertainty 0.250 [get_clocks clk]

# 3. Clock Transition Time (Slew = 150 ps)
set_clock_transition 0.150 [get_clocks clk]

# 4. Input Constraints: External memories arrive with 3.0 ns delay
set_input_delay -max 3.000 -clock clk [get_ports instr]
set_input_delay -min 0.500 -clock clk [get_ports instr]

set_input_delay -max 3.000 -clock clk [get_ports mem_rdata]
set_input_delay -min 0.500 -clock clk [get_ports mem_rdata]

set_input_delay -max 2.000 -clock clk [get_ports rst]
set_input_delay -min 0.500 -clock clk [get_ports rst]

# 5. Output Constraints: External memory setup time budget = 3.0 ns
set_output_delay -max 3.000 -clock clk [get_ports instr_addr]
set_output_delay -min 0.500 -clock clk [get_ports instr_addr]

set_output_delay -max 3.000 -clock clk [get_ports mem_addr]
set_output_delay -min 0.500 -clock clk [get_ports mem_addr]

set_output_delay -max 3.000 -clock clk [get_ports mem_wdata]
set_output_delay -min 0.500 -clock clk [get_ports mem_wdata]

set_output_delay -max 2.000 -clock clk [get_ports mem_write]
set_output_delay -max 2.000 -clock clk [get_ports mem_read]
set_output_delay -max 2.000 -clock clk [get_ports mem_funct3]

# 6. Output Driving Load: 20 fF per output pin (realistic CMOS load)
set_load 0.020 [all_outputs]
