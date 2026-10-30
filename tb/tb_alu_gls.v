`timescale 1ns/1ps

module tb_alu_gls;
    reg [31:0] a, b;
    reg [3:0]  alu_op;
    wire [31:0] result;
    wire        zero;
    integer pass_count = 0;
    integer fail_count = 0;

    alu uut (
        .a(a),
        .b(b),
        .alu_op(alu_op),
        .result(result),
        .zero(zero)
    );

    task check(input [31:0] exp_res, input exp_zero, input [127:0] op_name);
        begin
            #1; // Allow gate propagation
            if (result === exp_res && zero === exp_zero) begin
                $display("[GLS PASS] %0s: result = 0x%08h, zero = %b", op_name, result, zero);
                pass_count = pass_count + 1;
            end else begin
                $display("[GLS FAIL] %0s: expected (0x%08h, zero=%b), got (0x%08h, zero=%b)",
                         op_name, exp_res, exp_zero, result, zero);
                fail_count = fail_count + 1;
            end
            #9;
        end
    endtask

    initial begin
        $dumpfile("sim/alu_gls_wave.vcd");
        $dumpvars(0, tb_alu_gls);
        $display("--- Running ALU Gate-Level Simulation (GLS) ---");

        // ADD: 10 + 5 = 15
        a = 32'd10; b = 32'd5; alu_op = 4'b0000;
        check(32'd15, 1'b0, "ADD");

        // SUB: 10 - 10 = 0 (zero flag test)
        a = 32'd10; b = 32'd10; alu_op = 4'b0001;
        check(32'd0, 1'b1, "SUB (zero=1)");

        // SUB: 10 - 5 = 5
        a = 32'd10; b = 32'd5; alu_op = 4'b0001;
        check(32'd5, 1'b0, "SUB");

        // AND: 0xFF & 0x0F = 0x0F
        a = 32'hFF; b = 32'h0F; alu_op = 4'b0010;
        check(32'h0F, 1'b0, "AND");

        // OR: 0xF0 | 0x0F = 0xFF
        a = 32'hF0; b = 32'h0F; alu_op = 4'b0011;
        check(32'hFF, 1'b0, "OR");

        // XOR: 0xFF ^ 0x0F = 0xF0
        a = 32'hFF; b = 32'h0F; alu_op = 4'b0100;
        check(32'hF0, 1'b0, "XOR");

        // SLL: 1 << 4 = 16
        a = 32'd1; b = 32'd4; alu_op = 4'b0101;
        check(32'd16, 1'b0, "SLL");

        // SRL: 16 >> 4 = 1
        a = 32'd16; b = 32'd4; alu_op = 4'b0110;
        check(32'd1, 1'b0, "SRL");

        // SRA: 0x80000000 >>> 4 = 0xF8000000 (sign extension)
        a = 32'h80000000; b = 32'd4; alu_op = 4'b0111;
        check(32'hF8000000, 1'b0, "SRA");

        // SLT: -1 < 1 -> 1
        a = 32'hFFFFFFFF; b = 32'd1; alu_op = 4'b1000;
        check(32'd1, 1'b0, "SLT (-1 < 1)");

        // SLTU: 0xFFFFFFFF < 1 -> 0 (unsigned)
        a = 32'hFFFFFFFF; b = 32'd1; alu_op = 4'b1001;
        check(32'd0, 1'b1, "SLTU (unsigned max < 1)");

        $display("--------------------------------------------------");
        $display("ALU GLS Summary: %0d PASSED, %0d FAILED", pass_count, fail_count);
        $display("--------------------------------------------------");
        $finish;
    end
endmodule
