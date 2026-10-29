`timescale 1ns/1ps

module tb_control_unit;

    reg [6:0] opcode;
    reg [2:0] funct3;
    reg [6:0] funct7;

    wire        reg_write, alu_src, mem_read, mem_write, mem_to_reg, branch, jump;
    wire [3:0]  alu_op;
    wire [1:0]  a_sel;

    integer pass_count;
    integer fail_count;

    control_unit uut (
        .opcode(opcode), .funct3(funct3), .funct7(funct7),
        .reg_write(reg_write), .alu_src(alu_src),
        .mem_read(mem_read),   .mem_write(mem_write),
        .mem_to_reg(mem_to_reg), .branch(branch), .jump(jump),
        .alu_op(alu_op),       .a_sel(a_sel)
    );

    task check_signals;
        input [7:0]  test_num;
        input        exp_rw, exp_as, exp_mr, exp_mw, exp_m2r, exp_br, exp_j;
        input [3:0]  exp_op;
        input [1:0]  exp_asel;
        reg          ok;
        begin
            ok = (reg_write  == exp_rw)  &&
                 (alu_src    == exp_as)   &&
                 (mem_read   == exp_mr)   &&
                 (mem_write  == exp_mw)   &&
                 (mem_to_reg == exp_m2r)  &&
                 (branch     == exp_br)   &&
                 (jump       == exp_j)    &&
                 (alu_op     == exp_op)   &&
                 (a_sel      == exp_asel);
            if (ok) begin
                $display("TEST %0d PASSED", test_num);
                pass_count = pass_count + 1;
            end else begin
                $display("TEST %0d FAILED  opcode=%b funct3=%b funct7=%b",
                         test_num, opcode, funct3, funct7);
                $display("  GOT rw=%b as=%b mr=%b mw=%b m2r=%b br=%b j=%b op=%b asel=%b",
                         reg_write, alu_src, mem_read, mem_write, mem_to_reg,
                         branch, jump, alu_op, a_sel);
                $display("  EXP rw=%b as=%b mr=%b mw=%b m2r=%b br=%b j=%b op=%b asel=%b",
                         exp_rw, exp_as, exp_mr, exp_mw, exp_m2r,
                         exp_br, exp_j, exp_op, exp_asel);
                fail_count = fail_count + 1;
            end
        end
    endtask

    initial begin
        pass_count = 0;
        fail_count = 0;

        // T1: R-type ADD
        opcode=7'b0110011; funct3=3'b000; funct7=7'b0000000; #1;
        check_signals( 1,  1,0,0,0,0,0,0,  4'b0000, 2'b00);

        // T2: R-type SUB
        opcode=7'b0110011; funct3=3'b000; funct7=7'b0100000; #1;
        check_signals( 2,  1,0,0,0,0,0,0,  4'b0001, 2'b00);

        // T3: R-type SLL
        opcode=7'b0110011; funct3=3'b001; funct7=7'b0000000; #1;
        check_signals( 3,  1,0,0,0,0,0,0,  4'b0101, 2'b00);

        // T4: R-type SRA
        opcode=7'b0110011; funct3=3'b101; funct7=7'b0100000; #1;
        check_signals( 4,  1,0,0,0,0,0,0,  4'b0111, 2'b00);

        // T5: I-type ADDI
        opcode=7'b0010011; funct3=3'b000; funct7=7'b0000000; #1;
        check_signals( 5,  1,1,0,0,0,0,0,  4'b0000, 2'b00);

        // T6: I-type SLLI -- was falling through to ADD before fix
        opcode=7'b0010011; funct3=3'b001; funct7=7'b0000000; #1;
        check_signals( 6,  1,1,0,0,0,0,0,  4'b0101, 2'b00);

        // T7: I-type SRAI -- was falling through to ADD before fix
        opcode=7'b0010011; funct3=3'b101; funct7=7'b0100000; #1;
        check_signals( 7,  1,1,0,0,0,0,0,  4'b0111, 2'b00);

        // T8: LOAD (LW)
        opcode=7'b0000011; funct3=3'b010; funct7=7'b0000000; #1;
        check_signals( 8,  1,1,1,0,1,0,0,  4'b0000, 2'b00);

        // T9: STORE (SW)
        opcode=7'b0100011; funct3=3'b010; funct7=7'b0000000; #1;
        check_signals( 9,  0,1,0,1,0,0,0,  4'b0000, 2'b00);

        // T10: BRANCH (BEQ)
        opcode=7'b1100011; funct3=3'b000; funct7=7'b0000000; #1;
        check_signals(10,  0,0,0,0,0,1,0,  4'b0001, 2'b00);

        // T11: JAL
        opcode=7'b1101111; funct3=3'b000; funct7=7'b0000000; #1;
        check_signals(11,  1,0,0,0,0,0,1,  4'b0000, 2'b00);

        // T12: JALR
        opcode=7'b1100111; funct3=3'b000; funct7=7'b0000000; #1;
        check_signals(12,  1,1,0,0,0,0,1,  4'b0000, 2'b00);

        // T13: LUI -- a_sel=10 (force A=0), was missing before fix
        opcode=7'b0110111; funct3=3'b000; funct7=7'b0000000; #1;
        check_signals(13,  1,1,0,0,0,0,0,  4'b0000, 2'b10);

        // T14: AUIPC -- a_sel=01 (force A=PC), was missing before fix
        opcode=7'b0010111; funct3=3'b000; funct7=7'b0000000; #1;
        check_signals(14,  1,1,0,0,0,0,0,  4'b0000, 2'b01);

        #1;
        $display("----------------------------------");
        if (fail_count == 0)
            $display("ALL %0d TESTS PASSED", pass_count);
        else
            $display("%0d PASSED  %0d FAILED", pass_count, fail_count);
        $display("----------------------------------");
        $finish;
    end

endmodule
