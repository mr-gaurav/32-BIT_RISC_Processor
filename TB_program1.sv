`timescale 1ns / 1ps

module program1();

    logic clk1=0, clk2=0;
    Pipelined_MIPS32 dut(.clk1(clk1), .clk2(clk2));
    
    initial begin
        #5 clk1=1;
        forever begin
            #5 clk1=0;
            #15 clk1=1;
        end
    end

    initial begin
        #15 clk2=1;
        forever begin
            #5 clk2=0;
            #15 clk2=1;
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
            dut.Register[i]=i;

        $readmemh("program1.dat", dut.MEM, 0, 13);

        dut.HALTED=0;
        dut.BRANCH_TAKEN=0;
        dut.PC=0;

        #500 $finish;
        /* #200 for (int i=0; i<6; i++)
            $$display("Register[%0d]=%d\n",i,dut.Register[i]);
        
        #250 $finish; */

    end


    initial begin
        $dumpfile("program1.vcd");
        $dumpvars;

        #10 $display("----Value in Memory stored----");
        for (int i = 0; i<20; i++) begin
            $display("Memory[%0d]=%h",i, dut.MEM[i]);
        end

        #0 $display("\nAt time 0");
        for (int i=0; i<6; i++) begin
            $display("Register[%0d]=%0d",i,dut.Register[i]);
        end
        #50 $display("\nAt time 50\n");
        for (int i=0; i<6; i++) begin
            $display("Register[%0d]=%0d",i,dut.Register[i]);
        end
        #100 $display("\nAt time 100\n");
        for (int i=0; i<6; i++) begin
            $display("Register[%0d]=%0d",i,dut.Register[i]);
        end
        #150 $display("\nAt time 150\n");
        for (int i=0; i<6; i++) begin
            $display("Register[%0d]=%0d",i,dut.Register[i]);
        end
        #400 $display("\nAt time 400\n");
        for (int i=0; i<6; i++) begin
            $display("Register[%0d]=%0d",i,dut.Register[i]);
        end
            
    end
endmodule
