`timescale 1ns/1ps

module tb_branch_jump_logic;

    reg branch, jump;
    reg [2:0] funct3;
    reg [31:0] rs1_data, rs2_data, pc, imm;
    reg [6:0] opcode;
    wire pc_src;
    wire [31:0] pc_target;

    branch_jump_logic uut (
        .branch(branch), .jump(jump), .funct3(funct3),
        .rs1_data(rs1_data), .rs2_data(rs2_data),
        .pc(pc), .imm(imm), .opcode(opcode),
        .pc_src(pc_src), .pc_target(pc_target)
    );

    initial begin
        $dumpfile("branch_wave.vcd");
        $dumpvars(0, tb_branch_jump_logic);

        $monitor("t=%0t pc_src=%b pc_target=%0d", $time, pc_src, pc_target);

        // Test 1: beq, taken (equal)
        branch=1; jump=0; funct3=3'b000;
        rs1_data=32'd5; rs2_data=32'd5; pc=32'd100; imm=32'd20; opcode=7'b0000000;
        #10;

        // Test 2: beq, not taken (not equal)
        branch=1; jump=0; funct3=3'b000;
        rs1_data=32'd5; rs2_data=32'd7; pc=32'd100; imm=32'd20; opcode=7'b0000000;
        #10;

        // Test 3: jal
        branch=0; jump=1; funct3=3'b000;
        rs1_data=32'd0; rs2_data=32'd0; pc=32'd200; imm=32'd16; opcode=7'b1101111;
        #10;

        // Test 4: jalr
        branch=0; jump=1; funct3=3'b000;
        rs1_data=32'd1000; rs2_data=32'd0; pc=32'd200; imm=32'd10; opcode=7'b1100111;
        #10;

        #10 $finish;
    end

endmodule
