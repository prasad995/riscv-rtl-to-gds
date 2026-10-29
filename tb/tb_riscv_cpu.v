`timescale 1ns/1ps

module tb_riscv_cpu;

    reg clk, rst;

    riscv_cpu #(.MEM_FILE("tb/test_logic.hex")) uut (
        .clk(clk), .rst(rst)
    );

    // 10 ns clock
    initial clk = 0;
    always #5 clk = ~clk;

    integer pass_count, fail_count;

    task check_reg;
        input [4:0]  rnum;
        input [31:0] expected;
        begin
            if (uut.u_rf.registers[rnum] === expected) begin
                $display("PASS  x%02d = 0x%08h", rnum, expected);
                pass_count = pass_count + 1;
            end else begin
                $display("FAIL  x%02d: expected=0x%08h  got=0x%08h",
                         rnum, expected, uut.u_rf.registers[rnum]);
                fail_count = fail_count + 1;
            end
        end
    endtask

    initial begin
        $dumpfile("sim/cpu_wave.vcd");
        $dumpvars(0, tb_riscv_cpu);

        pass_count = 0;
        fail_count = 0;

        // Reset for 2 clock cycles
        rst = 1;
        repeat(2) @(posedge clk);
        rst = 0;

        // Run 25 cycles for 12 instructions
        repeat(25) @(posedge clk);

        $display("--- Register Check (Test 2: Logic & Shifts) ---");
        check_reg(1,  32'h000000FF);
        check_reg(2,  32'h0000000F);
        check_reg(3,  32'h0000000F); // and
        check_reg(4,  32'h000000FF); // or
        check_reg(5,  32'h000000F0); // xor
        check_reg(6,  32'h00000004); // shift amount
        check_reg(7,  32'h00000FF0); // sll
        check_reg(8,  32'h0000000F); // srl (positive)
        check_reg(9,  32'hFFFFFF00); // negative constant
        check_reg(10, 32'hFFFFFFF0); // sra (arithmetic: F enters)
        check_reg(11, 32'h0FFFFFF0); // srl (logical: 0 enters)
        $display("------------------------------------------------");

        if (fail_count == 0)
            $display("ALL %0d TESTS PASSED", pass_count);
        else
            $display("%0d PASSED  %0d FAILED", pass_count, fail_count);

        $finish;
    end

    always @(posedge clk)
        $display("t=%0t rst=%b PC=%08h instr=%08h",
                 $time, rst, uut.pc, uut.instr);

endmodule
