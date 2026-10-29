module riscv_cpu #(
    parameter MEM_FILE = "program.hex"
) (
    input wire clk,
    input wire rst
);

    // ---------- Wires ----------
    wire [31:0] pc, pc_next, pc_plus4, pc_target;
    wire [31:0] instr, imm;
    wire [31:0] rs1_data, rs2_data;
    wire [31:0] alu_a, alu_b, alu_result;
    wire [31:0] mem_rdata, wb_data;

    wire [6:0]  opcode, funct7;
    wire [4:0]  rd, rs1, rs2;
    wire [2:0]  funct3;

    wire        reg_write, alu_src, mem_read, mem_write, mem_to_reg;
    wire        branch, jump, pc_src, alu_zero;
    wire [3:0]  alu_op;
    wire [1:0]  a_sel;

    // ---------- Glue 1 and 2: next-PC logic ----------
    assign pc_plus4 = pc + 32'd4;
    assign pc_next  = pc_src ? pc_target : pc_plus4;

    // ---------- Fetch ----------
    program_counter u_pc (
        .clk(clk), .rst(rst), .pc_next(pc_next), .pc_out(pc)
    );

    instr_mem #(.MEM_FILE(MEM_FILE)) u_imem (
        .addr(pc), .instr(instr)
    );

    // ---------- Decode ----------
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

    // ---------- Glue 3 and 4: ALU operand muxes ----------
    assign alu_a = (a_sel == 2'b01) ? pc :
                   (a_sel == 2'b10) ? 32'b0 :
                                      rs1_data;
    assign alu_b = alu_src ? imm : rs2_data;

    // ---------- Execute ----------
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

    // ---------- Memory ----------
    data_mem u_dmem (
        .clk(clk), .mem_read(mem_read), .mem_write(mem_write & ~rst),
        .funct3(funct3), .addr(alu_result), .write_data(rs2_data),
        .read_data(mem_rdata)
    );

    // ---------- Glue 5: write-back mux ----------
    assign wb_data = jump        ? pc_plus4 :
                     mem_to_reg ? mem_rdata :
                                  alu_result;

endmodule
