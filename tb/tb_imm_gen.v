`timescale 1ns/1ps

module tb_imm_gen;

    reg [31:0] instr;
    wire [31:0] imm_out;

    imm_gen uut (
        .instr(instr),
        .imm_out(imm_out)
    );

    initial begin
        $dumpfile("immgen_wave.vcd");
        $dumpvars(0, tb_imm_gen);

        // I-type: addi x1, x2, -5  -> expect imm_out = -5 = 0xFFFFFFFB
        instr = 32'hFFB10093; #10;

        // S-type: sw x1, 4(x2) -> expect imm_out = 4
        instr = 32'h00112223; #10;

        // B-type: beq x1, x2, 8 -> expect imm_out = 8
        instr = 32'h00208463; #10;

        // U-type: lui x1, 0x12345 -> expect imm_out = 0x12345000
        instr = 32'h123450B7; #10;

        // J-type: jal x1, 16 -> expect imm_out = 16
        instr = 32'h010000EF; #10;

        #10 $finish;
    end

endmodule
