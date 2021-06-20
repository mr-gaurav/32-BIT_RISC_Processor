`timescale 1ns / 1ps

module program3();
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
        //always clk2 = #10 clk1;

        /* initial begin
            $dumpfile("program1.vcd");
            $dumpvars;
            $monitor("time=%g, clk1=%b, clk2=%b", $time, clk1, clk2);
        end */

        initial begin
            for (int i=0; i<32; i++) 
                dut.Register[i]=0;
            //dut.Register[3]=1;
            $readmemh("program3.dat", dut.MEM);
            dut.MEM[200]=7;

            //setting flags
            dut.HALTED=0;
            dut.BRANCH_TAKEN=0;
            dut.PC=0;

            /* #200 for (int i=0; i<6; i++)
                $$display("Register[%0d]=%d\n",i,dut.Register[i]);
            
            #250 $finish; */

        end


        initial begin
            $dumpfile("program3.vcd");
            $dumpvars;
            /* $monitor("Register[1]=%0d , Register[2]=%0d , Register[3]=%0d", dut.Register[1], dut.Register[2] ,dut.Register[3]);
            $monitor("PC=%0d , ALUOUT = %0d",dut.PC, dut.EX_MEM_ALUOUT); */
            /* #10 $display("-At time 10---Value in Memory stored----");
            for (int i = 0; i<20; i++) begin
                $display("Memory[%0d]=%h",i, dut.MEM[i]); 
            end */

            /* $display("Memory[200]=%0d", dut.MEM[200]); */

            //$display("%0d + 45 = %0d", dut.MEM[120], dut.MEM[121]);

            /* #10 $display("-At time 320---Value in Memory stored----");
            for (int i = 0; i<15; i++) begin
                $display("Memory[%0d]=%h",i, dut.MEM[i]);
            end */

            #1000 $display("Factorial of %0d is stored at Memory[198]=%0d",dut.MEM[200], dut.MEM[198]);
            #10 $finish;
                
        end

endmodule
