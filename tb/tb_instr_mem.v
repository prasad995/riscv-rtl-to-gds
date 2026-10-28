`timescale 1ns/1ps

module tb_instr_mem;

    reg  [31:0] addr;
    wire [31:0] instr;

    instr_mem #(.MEM_FILE("tb/imem_test.hex")) uut (
        .addr(addr),
        .instr(instr)
    );

    initial begin
        $dumpfile("imem_wave.vcd");
        $dumpvars(0, tb_instr_mem);

        $monitor("t=%0t addr=%0d instr=%h", $time, addr, instr);

        addr = 32'd0;  #10;
        addr = 32'd4;  #10;
        addr = 32'd8;  #10;
        addr = 32'd12; #10;
        addr = 32'd16; #10;   // beyond the program

        #10 $finish;
    end

endmodule

