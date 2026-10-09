module control_unit (
    input  wire [6:0] opcode,
    input  wire [2:0] funct3,
    input  wire [6:0] funct7,
    output reg        reg_write,
    output reg        alu_src,
    output reg        mem_read,
    output reg        mem_write,
    output reg        mem_to_reg,
    output reg        branch,
    output reg        jump,
    output reg  [3:0] alu_op
);

    localparam OP_RTYPE  = 7'b0110011;
    localparam OP_ITYPE  = 7'b0010011;
    localparam OP_LOAD   = 7'b0000011;
    localparam OP_STORE  = 7'b0100011;
    localparam OP_BRANCH = 7'b1100011;
    localparam OP_JAL    = 7'b1101111;
    localparam OP_JALR   = 7'b1100111;
    localparam OP_LUI    = 7'b0110111;

    always @(*) begin
        reg_write  = 0;
        alu_src    = 0;
        mem_read   = 0;
        mem_write  = 0;
        mem_to_reg = 0;
        branch     = 0;
        jump       = 0;
        alu_op     = 4'b0000;

        case (opcode)
            OP_RTYPE: begin
                reg_write = 1;
                alu_src   = 0;
                case (funct3)
                    3'b000:  alu_op = (funct7[5]) ? 4'b0001 : 4'b0000;
                    3'b111:  alu_op = 4'b0010;
                    3'b110:  alu_op = 4'b0011;
                    3'b100:  alu_op = 4'b0100;
                    3'b001:  alu_op = 4'b0101;
                    3'b101:  alu_op = (funct7[5]) ? 4'b0111 : 4'b0110;
                    3'b010:  alu_op = 4'b1000;
                    3'b011:  alu_op = 4'b1001;
                    default: alu_op = 4'b0000;
                endcase
            end

            OP_ITYPE: begin
                reg_write = 1;
                alu_src   = 1;
                case (funct3)
                    3'b000:  alu_op = 4'b0000;
                    3'b111:  alu_op = 4'b0010;
                    3'b110:  alu_op = 4'b0011;
                    3'b100:  alu_op = 4'b0100;
                    3'b010:  alu_op = 4'b1000;
                    3'b011:  alu_op = 4'b1001;
                    default: alu_op = 4'b0000;
                endcase
            end

            OP_LOAD: begin
                reg_write  = 1;
                alu_src    = 1;
                mem_read   = 1;
                mem_to_reg = 1;
                alu_op     = 4'b0000;
            end

            OP_STORE: begin
                alu_src   = 1;
                mem_write = 1;
                alu_op    = 4'b0000;
            end

            OP_BRANCH: begin
                branch = 1;
                alu_op = 4'b0001;
            end

            OP_JAL: begin
                reg_write = 1;
                jump      = 1;
            end

            OP_JALR: begin
                reg_write = 1;
                alu_src   = 1;
                jump      = 1;
                alu_op    = 4'b0000;
            end

            OP_LUI: begin
                reg_write = 1;
                alu_src   = 1;
            end

            default: begin
            end
        endcase
    end

endmodule
