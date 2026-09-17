`timescale 1ns/1ps

module tb_instr_decoder;

    reg [31:0] instr;
    wire [6:0] opcode, funct7;
    wire [4:0] rd, rs1, rs2;
    wire [2:0] funct3;

    instr_decoder uut (
        .instr(instr),
        .opcode(opcode),
        .rd(rd),
        .funct3(funct3),
        .rs1(rs1),
        .rs2(rs2),
        .funct7(funct7)
    );

    initial begin
        $dumpfile("decoder_wave.vcd");
        $dumpvars(0, tb_instr_decoder);

        // add x3, x1, x2
        instr = 32'h002081B3; #10;

        #10 $finish;
    end

endmodule
