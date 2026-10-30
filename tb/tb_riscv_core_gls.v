`timescale 1ns/1ps

module tb_riscv_core_gls;

    reg clk, rst;

    // Memory bus wires
    wire [31:0] instr_addr;
    wire [31:0] instr;
    wire [31:0] mem_addr;
    wire [31:0] mem_wdata;
    wire [31:0] mem_rdata;
    wire        mem_write;
    wire        mem_read;
    wire [2:0]  mem_funct3;

    // Instantiate synthesized gate-level core
    riscv_core uut (
        .clk(clk),
        .rst(rst),
        .instr_addr(instr_addr),
        .instr(instr),
        .mem_addr(mem_addr),
        .mem_wdata(mem_wdata),
        .mem_rdata(mem_rdata),
        .mem_write(mem_write),
        .mem_read(mem_read),
        .mem_funct3(mem_funct3)
    );

    // Attach Instruction Memory (loaded with test_jal.hex)
    instr_mem #(.MEM_FILE("tb/test_jal.hex")) u_imem (
        .addr(instr_addr),
        .instr(instr)
    );

    // Attach Data Memory
    data_mem u_dmem (
        .clk(clk),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .funct3(mem_funct3),
        .addr(mem_addr),
        .write_data(mem_wdata),
        .read_data(mem_rdata)
    );

    // 10 ns clock (100 MHz)
    initial clk = 0;
    always #5 clk = ~clk;

    integer pass_count, fail_count;

    task check_reg;
        input [31:0] actual;
        input [31:0] expected;
        input [4:0]  rnum;
        begin
            if (actual === expected) begin
                $display("[GLS PASS] x%02d = 0x%08h", rnum, expected);
                pass_count = pass_count + 1;
            end else begin
                $display("[GLS FAIL] x%02d: expected=0x%08h  got=0x%08h", rnum, expected, actual);
                fail_count = fail_count + 1;
            end
        end
    endtask

    initial begin
        $dumpfile("sim/cpu_gls_wave.vcd");
        $dumpvars(0, tb_riscv_core_gls);

        pass_count = 0;
        fail_count = 0;

        // Reset for 2 clock cycles
        rst = 1;
        repeat(2) @(posedge clk);
        rst = 0;

        // Run 20 cycles
        repeat(20) @(posedge clk);

        $display("--- Gate-Level Register Check (Test 6: JAL and JALR Call and Return) ---");
        check_reg(uut.\u_rf.registers[1] , 32'h00000008, 1);
        check_reg(uut.\u_rf.registers[2] , 32'd15,        2);
        check_reg(uut.\u_rf.registers[3] , 32'd99,        3);
        $display("-------------------------------------------------------------------");

        if (fail_count == 0)
            $display("ALL %0d GATE-LEVEL TESTS PASSED!", pass_count);
        else
            $display("%0d PASSED  %0d FAILED", pass_count, fail_count);

        $finish;
    end

    always @(posedge clk)
        $display("t=%0t rst=%b PC=%08h instr=%08h", $time, rst, instr_addr, instr);

endmodule
