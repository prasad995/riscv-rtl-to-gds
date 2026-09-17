`timescale 1ns/1ps

module tb_alu;

    reg [31:0] a, b;
    reg [3:0] alu_op;
    wire [31:0] result;
    wire zero;

    alu uut (
        .a(a),
        .b(b),
        .alu_op(alu_op),
        .result(result),
        .zero(zero)
    );

    initial begin
        $dumpfile("alu_wave.vcd");
        $dumpvars(0, tb_alu);

        // ADD
        a = 32'd10; b = 32'd5; alu_op = 4'b0000; #10;
        // SUB
        a = 32'd10; b = 32'd5; alu_op = 4'b0001; #10;
        // AND
        a = 32'hFF; b = 32'h0F; alu_op = 4'b0010; #10;
        // OR
        a = 32'hF0; b = 32'h0F; alu_op = 4'b0011; #10;
        // XOR
        a = 32'hFF; b = 32'h0F; alu_op = 4'b0100; #10;
        // SLL
        a = 32'd1; b = 32'd4; alu_op = 4'b0101; #10;
        // SRL
        a = 32'd16; b = 32'd4; alu_op = 4'b0110; #10;
        // SRA
        a = 32'h80000000; b = 32'd4; alu_op = 4'b0111; #10;
        // SLT
        a = 32'hFFFFFFFF; b = 32'd1; alu_op = 4'b1000; #10;
        // SLTU
        a = 32'hFFFFFFFF; b = 32'd1; alu_op = 4'b1001; #10;

        #10 $finish;
    end

endmodule
