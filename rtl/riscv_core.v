`timescale 1ns/1ps

module riscv_core (
    input  wire        clk,
    input  wire        rst,

    // Instruction Memory Interface
    output wire [31:0] instr_addr,
    input  wire [31:0] instr,

    // Data Memory Interface
    output wire [31:0] mem_addr,
    output wire [31:0] mem_wdata,
    input  wire [31:0] mem_rdata,
    output wire        mem_write,
    output wire        mem_read,
    output wire [2:0]  mem_funct3
);

    // Internal Datapath Wires
    wire [31:0] pc, pc_next, pc_plus4, pc_target;
    wire [31:0] imm;
    wire [31:0] rs1_data, rs2_data;
    wire [31:0] alu_a, alu_b, alu_result;
    wire [31:0] wb_data;

    wire [6:0]  opcode, funct7;
    wire [4:0]  rd, rs1, rs2;
    wire [2:0]  funct3;

    wire        reg_write, alu_src, mem_to_reg;
    wire        branch, jump, pc_src, alu_zero;
    wire [3:0]  alu_op;
    wire [1:0]  a_sel;

    // Fetch Logic
    assign pc_plus4   = pc + 32'd4;
    assign pc_next    = pc_src ? pc_target : pc_plus4;
    assign instr_addr = pc;

    program_counter u_pc (
        .clk(clk), .rst(rst), .pc_next(pc_next), .pc_out(pc)
    );

    // Decode Logic
    instr_decoder u_dec (
        .instr(instr), .opcode(opcode), .rd(rd), .funct3(funct3),
        .rs1(rs1), .rs2(rs2), .funct7(funct7)
    );

    control_unit u_ctrl (
        .opcode(opcode), .funct3(funct3), .funct7(funct7),
        .reg_write(reg_write), .alu_src(alu_src),
        .mem_read(mem_read), .mem_write(mem_write),
        .mem_to_reg(mem_to_reg), .branch(branch), .jump(jump),
        .alu_op(alu_op), .a_sel(a_sel)
    );

    imm_gen u_imm (
        .instr(instr), .imm_out(imm)
    );

    register_file u_rf (
        .clk(clk), .we(reg_write & ~rst),
        .rs1_addr(rs1), .rs2_addr(rs2), .rd_addr(rd),
        .rd_data(wb_data), .rs1_data(rs1_data), .rs2_data(rs2_data)
    );

    // ALU Operand Selection
    assign alu_a = (a_sel == 2'b01) ? pc :
                   (a_sel == 2'b10) ? 32'b0 :
                                      rs1_data;
    assign alu_b = alu_src ? imm : rs2_data;

    alu u_alu (
        .a(alu_a), .b(alu_b), .alu_op(alu_op),
        .result(alu_result), .zero(alu_zero)
    );

    branch_jump_logic u_bj (
        .branch(branch), .jump(jump), .funct3(funct3),
        .rs1_data(rs1_data), .rs2_data(rs2_data),
        .pc(pc), .imm(imm), .opcode(opcode),
        .pc_src(pc_src), .pc_target(pc_target)
    );

    // Memory Bus Out
    assign mem_addr   = alu_result;
    assign mem_wdata  = rs2_data;
    assign mem_funct3 = funct3;

    // Write-Back Mux
    assign wb_data = jump        ? pc_plus4 :
                     mem_to_reg ? mem_rdata :
                                  alu_result;

endmodule
