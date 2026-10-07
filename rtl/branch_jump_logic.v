module branch_jump_logic (
    input  wire        branch,
    input  wire        jump,
    input  wire [2:0]  funct3,
    input  wire [31:0] rs1_data,
    input  wire [31:0] rs2_data,
    input  wire [31:0] pc,
    input  wire [31:0] imm,
    input  wire [6:0]  opcode,
    output wire        pc_src,
    output wire [31:0] pc_target
);

    localparam OP_JALR = 7'b1100111;

    wire branch_taken;

    assign branch_taken =
        (funct3 == 3'b000) ? (rs1_data == rs2_data) :
        (funct3 == 3'b001) ? (rs1_data != rs2_data) :
        (funct3 == 3'b100) ? ($signed(rs1_data) <  $signed(rs2_data)) :
        (funct3 == 3'b101) ? ($signed(rs1_data) >= $signed(rs2_data)) :
        (funct3 == 3'b110) ? (rs1_data <  rs2_data) :
        (funct3 == 3'b111) ? (rs1_data >= rs2_data) :
        1'b0;

    assign pc_src = jump || (branch && branch_taken);

    assign pc_target = (jump && (opcode == OP_JALR))
                        ? ((rs1_data + imm) & ~32'b1)
                        : (pc + imm);

endmodule
