`timescale 1ns/1ps

module tb_riscv_cpu;

    reg clk, rst;

    riscv_cpu #(.MEM_FILE("tb/test_jal.hex")) uut (
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

        // Run 20 cycles
        repeat(20) @(posedge clk);

        $display("--- Register Check (Test 6: JAL and JALR Function Call/Return) ---");
        check_reg(1, 32'h00000008); // x1 (ra) = saved PC+4 return address
        check_reg(2, 32'd15);        // x2 = modified by function (10 + 5 = 15)
        check_reg(3, 32'd99);        // x3 = executed after return (99 = 0x63)
        $display("-------------------------------------------------------------------");

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
