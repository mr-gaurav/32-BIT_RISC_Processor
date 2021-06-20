`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 13.06.2021 17:38:19
// Design Name: 
// Module Name: program2
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module program2();
    logic clk1=0, clk2=0;
        Pipelined_MIPS32 dut(.clk1(clk1), .clk2(clk2));
        
        initial begin
            #3 clk1=1;
            forever begin
                #3 clk1=0;
                #9 clk1=1;
            end
        end

        initial begin
            #9 clk2=1;
            forever begin
                #3 clk2=0;
                #9 clk2=1;
            end
        end

        initial begin
            for (int i=0; i<32; i++) 
                dut.Register[i]=0;
            dut.Register[0]=0;      // FOR MAKE SURE REGISTER0 CONTAINS 0
            $readmemh("D:/Learn VLSI/Apps data/Xilinx Vivado/MIPS32/program2.txt", dut.MEM);
            dut.MEM[120]=100;

            dut.HALTED=0;
            dut.BRANCH_TAKEN=0;
            dut.PC=0;

            /* #200 for (int i=0; i<6; i++)
                $$display("Register[%0d]=%d\n",i,dut.Register[i]);
            
            #250 $finish; */ 

        end


        initial begin
            $dumpfile("program2.vcd");
            $dumpvars;

            #10 $display("----Value in Memory stored----");
            for (int i = 0; i<10; i++) begin
                $display("Memory[%0d]=%h",i, dut.MEM[i]);
            end
            $display("Memory[120]=%0d", dut.MEM[120]);

            #900 
            $display("Memory[121]=%0d", dut.MEM[121]);
            $display("%0d + 45 = %0d", dut.MEM[120], dut.MEM[121]);

            #10 $display("----Value in Memory stored----");
            for (int i = 120; i<122; i++) begin
                $display("Memory[%0d]=%0d",i, dut.MEM[i]);
            end
            #10 $finish;
                
        end

endmodule
