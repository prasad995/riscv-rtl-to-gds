module instr_mem #(
    parameter MEM_FILE = "program.hex"
) (
    input  wire [31:0] addr,
    output wire [31:0] instr
);

    reg [31:0] mem [0:1023];
    integer i;

    initial begin
        for (i = 0; i < 1024; i = i + 1)
            mem[i] = 32'h00000013;   // NOP (addi x0, x0, 0)
`ifndef SYNTHESIS
        $readmemh(MEM_FILE, mem);
`endif
    end

    assign instr = mem[addr[11:2]];

endmodule
