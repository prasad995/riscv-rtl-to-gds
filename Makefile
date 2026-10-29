RTL_SRC = rtl/riscv_cpu.v rtl/program_counter.v rtl/instr_mem.v rtl/instr_decoder.v \
          rtl/control_unit.v rtl/imm_gen.v rtl/register_file.v rtl/alu.v \
          rtl/branch_jump_logic.v rtl/data_mem.v

TB_SRC = tb/tb_riscv_cpu.v
SIM_DIR = sim
BIN = $(SIM_DIR)/tb_cpu

.PHONY: all compile sim wave clean

all: compile sim

compile:
	@mkdir -p $(SIM_DIR)
	iverilog -Wall -o $(BIN) $(TB_SRC) $(RTL_SRC)

sim: compile
	vvp $(BIN)

wave:
	gtkwave $(SIM_DIR)/cpu_wave.vcd &

clean:
	rm -rf $(SIM_DIR)/*
