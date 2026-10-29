`timescale 1ns/1ps

module tb_riscv_cpu;

    reg clk, rst;

    riscv_cpu #(.MEM_FILE("tb/test_addsub.hex")) uut (
        .clk(clk), .rst(rst)
    );

    // 10 ns period clock
    initial clk = 0;
    always #5 clk = ~clk;

    integer pass_count, fail_count;

    task check_reg;
        input [4:0]  rnum;
        input [31:0] expected;
        begin
            if (uut.u_rf.registers[rnum] === expected) begin
                $display("PASS  x%0d = 0x%08h", rnum, expected);
                pass_count = pass_count + 1;
            end else begin
                $display("FAIL  x%0d: expected=0x%08h  got=0x%08h",
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

        // Hold reset for 2 clock cycles
        rst = 1;
        repeat(2) @(posedge clk);
        rst = 0;

        // Run 20 cycles -- more than enough for 6 instructions
        repeat(20) @(posedge clk);

        // Check register values
        $display("--- Register Check ---");
        check_reg(1, 32'd5);
        check_reg(2, 32'd10);
        check_reg(3, 32'd15);
        check_reg(4, 32'hFFFFFFFF);
        check_reg(5, 32'hFFFFFFFA);
        $display("----------------------");

        if (fail_count == 0)
            $display("ALL %0d TESTS PASSED", pass_count);
        else
            $display("%0d PASSED  %0d FAILED", pass_count, fail_count);

        $finish;
    end

    // Show PC and instruction every cycle so we can trace execution
    always @(posedge clk)
        $display("t=%0t rst=%b PC=%08h instr=%08h",
                 $time, rst, uut.pc, uut.instr);

endmodule
