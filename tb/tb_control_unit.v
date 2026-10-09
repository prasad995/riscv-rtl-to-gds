`timescale 1ns/1ps

module tb_control_unit;

    reg [6:0] opcode;
    reg [2:0] funct3;
    reg [6:0] funct7;
    wire reg_write, alu_src, mem_read, mem_write, mem_to_reg, branch, jump;
    wire [3:0] alu_op;

    control_unit uut (
        .opcode(opcode), .funct3(funct3), .funct7(funct7),
        .reg_write(reg_write), .alu_src(alu_src),
        .mem_read(mem_read), .mem_write(mem_write),
        .mem_to_reg(mem_to_reg), .branch(branch), .jump(jump),
        .alu_op(alu_op)
    );

    initial begin
        $dumpfile("control_wave.vcd");
        $dumpvars(0, tb_control_unit);

        $monitor("t=%0t opcode=%b funct7=%b | reg_write=%b alu_src=%b mem_read=%b mem_write=%b mem_to_reg=%b branch=%b jump=%b alu_op=%b",
                  $time, opcode, funct7, reg_write, alu_src, mem_read, mem_write, mem_to_reg, branch, jump, alu_op);

        // add
        opcode=7'b0110011; funct3=3'b000; funct7=7'b0000000; #10;
        // sub
        opcode=7'b0110011; funct3=3'b000; funct7=7'b0100000; #10;
        // lw
        opcode=7'b0000011; funct3=3'b000; funct7=7'b0000000; #10;
        // sw
        opcode=7'b0100011; funct3=3'b000; funct7=7'b0000000; #10;
        // beq
        opcode=7'b1100011; funct3=3'b000; funct7=7'b0000000; #10;

        #10 $finish;
    end

endmodule
