module data_mem (
    input  wire        clk,
    input  wire        mem_read,
    input  wire        mem_write,
    input  wire [2:0]  funct3,
    input  wire [31:0] addr,
    input  wire [31:0] write_data,
    output reg  [31:0] read_data
);

    reg [7:0] mem [0:4095];
    integer i;

    initial begin
        for (i = 0; i < 4096; i = i + 1)
            mem[i] = 8'h00;
    end

    wire [11:0] a = addr[11:0];

    wire [7:0] b0 = mem[a];
    wire [7:0] b1 = mem[a+1];
    wire [7:0] b2 = mem[a+2];
    wire [7:0] b3 = mem[a+3];

    // Write: sb / sh / sw (little-endian)
    always @(posedge clk) begin
        if (mem_write) begin
            case (funct3[1:0])
                2'b00: mem[a] <= write_data[7:0];
                2'b01: begin
                    mem[a]   <= write_data[7:0];
                    mem[a+1] <= write_data[15:8];
                end
                2'b10: begin
                    mem[a]   <= write_data[7:0];
                    mem[a+1] <= write_data[15:8];
                    mem[a+2] <= write_data[23:16];
                    mem[a+3] <= write_data[31:24];
                end
                default: ;
            endcase
        end
    end

    // Read: lb / lh / lw / lbu / lhu
    always @(*) begin
        read_data = 32'b0;
        if (mem_read) begin
            case (funct3)
                3'b000:  read_data = {{24{b0[7]}}, b0};       // lb
                3'b001:  read_data = {{16{b1[7]}}, b1, b0};   // lh
                3'b010:  read_data = {b3, b2, b1, b0};        // lw
                3'b100:  read_data = {24'b0, b0};             // lbu
                3'b101:  read_data = {16'b0, b1, b0};         // lhu
                default: read_data = 32'b0;
            endcase
        end
    end

endmodule
