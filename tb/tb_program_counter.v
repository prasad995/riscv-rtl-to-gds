`timescale 1ns/1ps

module tb_program_counter;

    reg clk;
    reg rst;
    reg [31:0] pc_next;
    wire [31:0] pc_out;

    program_counter uut (
        .clk(clk),
        .rst(rst),
        .pc_next(pc_next),
        .pc_out(pc_out)
    );

    always #5 clk = ~clk;

    initial begin
        $dumpfile("pc_wave.vcd");
        $dumpvars(0, tb_program_counter);

        clk = 0;
        rst = 1;
        pc_next = 32'h00000000;

        #10 rst = 0;
        #10 pc_next = 32'h00000004;
        #10 pc_next = 32'h00000008;
        #10 pc_next = 32'h0000000C;
        #10 rst = 1;
        #10 rst = 0;
        #10 pc_next = 32'h00000100;

        #20 $finish;
    end

endmodule
