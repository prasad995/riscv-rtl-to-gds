`timescale 1ns/1ps

module tb_register_file;

    reg clk;
    reg we;
    reg [4:0] rs1_addr, rs2_addr, rd_addr;
    reg [31:0] rd_data;
    wire [31:0] rs1_data, rs2_data;

    register_file uut (
        .clk(clk),
        .we(we),
        .rs1_addr(rs1_addr),
        .rs2_addr(rs2_addr),
        .rd_addr(rd_addr),
        .rd_data(rd_data),
        .rs1_data(rs1_data),
        .rs2_data(rs2_data)
    );

    always #5 clk = ~clk;

    initial begin
        $dumpfile("regfile_wave.vcd");
        $dumpvars(0, tb_register_file);

        clk = 0;
        we = 0;
        rs1_addr = 0; rs2_addr = 0; rd_addr = 0; rd_data = 0;

        // Test 1: write 100 into x5
        #10 rd_addr = 5'd5; rd_data = 32'd100; we = 1;
        #10 we = 0;

        // Test 2: read back x5
        #10 rs1_addr = 5'd5;

        // Test 3: try to write 999 into x0
        #10 rd_addr = 5'd0; rd_data = 32'd999; we = 1;
        #10 we = 0;

        // Test 4: read x0, should still be 0
        #10 rs2_addr = 5'd0;

        // Test 5: write 200 into x10, then read x5 and x10 simultaneously
        #10 rd_addr = 5'd10; rd_data = 32'd200; we = 1;
        #10 we = 0;
        #10 rs1_addr = 5'd5; rs2_addr = 5'd10;

        #20 $finish;
    end

endmodule
