`timescale 1ns/1ps

module tb_data_mem;

    reg         clk;
    reg         mem_read, mem_write;
    reg  [2:0]  funct3;
    reg  [31:0] addr, write_data;
    wire [31:0] read_data;

    data_mem uut (
        .clk(clk), .mem_read(mem_read), .mem_write(mem_write),
        .funct3(funct3), .addr(addr), .write_data(write_data),
        .read_data(read_data)
    );

    always #5 clk = ~clk;

    // Helper: one write spanning exactly one rising clock edge
    task write_mem(input [2:0] f3, input [31:0] a, input [31:0] d);
        begin
            mem_read = 0;
            @(negedge clk);
            mem_write = 1; funct3 = f3; addr = a; write_data = d;
            @(negedge clk);
            mem_write = 0;
        end
    endtask

    // Helper: one read, held for 10ns
    task read_mem(input [2:0] f3, input [31:0] a);
        begin
            mem_read = 1; funct3 = f3; addr = a;
            #10;
        end
    endtask

    initial begin
        $dumpfile("dmem_wave.vcd");
        $dumpvars(0, tb_data_mem);

        $monitor("t=%0t rd=%b f3=%b addr=%0d | read_data=%h",
                  $time, mem_read, funct3, addr, read_data);

        clk = 0; mem_read = 0; mem_write = 0;
        funct3 = 0; addr = 0; write_data = 0;

        write_mem(3'b010, 32'd0, 32'hDEADBEEF);   // sw 0xDEADBEEF at 0

        read_mem(3'b010, 32'd0);   // lw  -> expect DEADBEEF
        read_mem(3'b000, 32'd0);   // lb  -> expect FFFFFFEF
        read_mem(3'b100, 32'd0);   // lbu -> expect 000000EF
        read_mem(3'b001, 32'd0);   // lh  -> expect FFFFBEEF
        read_mem(3'b101, 32'd0);   // lhu -> expect 0000BEEF
        read_mem(3'b000, 32'd3);   // lb at byte 3 -> expect FFFFFFDE

        mem_read = 0; #10;         // read disabled -> expect 00000000

        write_mem(3'b000, 32'd8, 32'h0000007F);   // sb 0x7F at 8
        read_mem(3'b010, 32'd8);   // lw -> expect 0000007F

        write_mem(3'b001, 32'd12, 32'h00001234);  // sh 0x1234 at 12
        read_mem(3'b010, 32'd12);  // lw -> expect 00001234

        #10 $finish;
    end

endmodule
