`timescale 1ns / 1ps

`define BIT_32 31:0
`define OPCODE 31:26
`define RS 25:21
`define RT 20:16
`define RD 15:11
`define OFFSET 15:0
`define DELAY 1

module Pipelined_MIPS32(
    input clk1, clk2 
    );
    parameter delay=1;
    reg [`BIT_32] PC, IF_ID_IR, IF_ID_NPC;
    reg [`BIT_32] ID_EX_NPC, ID_EX_A, ID_EX_B, ID_EX_IR, ID_EX_IMM;
    reg [`BIT_32] EX_MEM_ALUOUT, EX_MEM_B, EX_MEM_IR;
    reg          EX_MEM_CONDITION;
    reg [`BIT_32] MEM_WB_IR, MEM_WB_LMD, MEM_WB_ALUOUT;
    reg [2:0]    ID_EX_TYPE, EX_MEM_TYPE, MEM_WB_TYPE;

    // declear memory and registers of mips32
    reg [`BIT_32] Register [0:31];   // 32 32BIT Register Bank
    reg [`BIT_32] MEM [0:500];   // 500 x 32BIT Memory

    //status flag
    reg HALTED, BRANCH_TAKEN;

    // declearing OPCODE
    parameter   // RR TYPE
                ADD =   6'b010000,
                SUB =   6'b010001,
                AND =   6'b010010,
                OR  =   6'b010011,
                XOR =   6'b010100,
                NOR =   6'b010101,
                XNOR=   6'b010110,
                NAND=   6'b010111,
                MUL =   6'b011000,
                DIV =   6'b011001,
                SLT =   6'b011010,
                SGT =   6'b011011,
                HLT =   6'b111111,

                // IMMIIDIATE TYPE OR RM TYPE
                ADDI =  6'b100010,
                SUBI =  6'b100011,
                MULI =  6'b100100,
                DIVI =  6'b100101,
                SLTI =  6'b100110,
                SGTI =  6'b100111,

                // BRANCH
                BNEQZ=  6'b101000,
                BEQZ =  6'b101001,

                // LOAD STORE
                LW =    6'b100000,
                SW =    6'b100001;

    parameter   // TYPE define
                RR_ALU =    3'b000,
                RM_ALU =    3'b001,
                LOAD   =    3'b010,
                STORE  =    3'b011,
                BRANCH =    3'b100,
                HALT   =    3'b111;



    //  INSTRUCTION FETCH (IF) STAGE 1

    always @(posedge clk1 ) begin
        if (HALTED == 0) begin
            if ((EX_MEM_IR[`OPCODE]==BEQZ && EX_MEM_CONDITION==0) || (EX_MEM_IR[`OPCODE]==BNEQZ && EX_MEM_CONDITION==1)) 
            begin
                BRANCH_TAKEN <= #(`DELAY) 1'b1;
                IF_ID_IR     <= #(`DELAY) MEM[EX_MEM_ALUOUT];
                IF_ID_NPC    <= #(`DELAY) EX_MEM_ALUOUT + 1;
                PC           <= #(`DELAY) EX_MEM_ALUOUT + 1;
            end
            else begin
                IF_ID_IR     <= #(`DELAY) MEM[PC];
                IF_ID_NPC    <= #(`DELAY) PC + 1;
                PC           <= #(`DELAY) PC + 1;
            end
        end
    end


    //   INSTRUCTION DECODE (ID) STAGE 2

    always @(posedge clk2) begin
        if (HALTED==0) begin
            ID_EX_IR  <= #(`DELAY) IF_ID_IR;
            ID_EX_NPC <= #(`DELAY) IF_ID_NPC;

            ID_EX_A   <= #(`DELAY) (IF_ID_IR[`RS]==5'b0) ? 0 : Register[IF_ID_IR[`RS]];
            ID_EX_B   <= #(`DELAY) (IF_ID_IR[`RT]==5'b0) ? 0 : Register[IF_ID_IR[`RT]];
            ID_EX_IMM <= #(`DELAY) { {16{IF_ID_IR[15]}} , IF_ID_IR[`OFFSET] };

            /* if (IF_ID_IR[`RS]==5'b0) 
                ID_EX_A   <= #(`DELAY) 32'b0;
            else
                ID_EX_A   <= #(`DELAY) Register[IF_ID_IR[`RS]];

            if (IF_ID_IR[`RT]==5'b0) 
                ID_EX_B   <= #(`DELAY) 32'b0;
            else
                ID_EX_B   <= #(`DELAY) Register[IF_ID_IR[`RT]]; */


            case (IF_ID_IR[`OPCODE])
                ADD, SUB, AND, OR, XOR, NOR, XNOR, NAND : ID_EX_TYPE <= #(`DELAY) RR_ALU;
                MUL, DIV, SLT, SGT                      : ID_EX_TYPE <= #(`DELAY) RR_ALU;
                LW                                      : ID_EX_TYPE <= #(`DELAY) LOAD;
                SW                                      : ID_EX_TYPE <= #(`DELAY) STORE;
                BNEQZ, BEQZ                             : ID_EX_TYPE <= #(`DELAY) BRANCH;
                HLT                                     : ID_EX_TYPE <= #(`DELAY) HALT; 
                ADDI, SUBI, MULI, DIVI, SLTI, SGTI      : ID_EX_TYPE <= #(`DELAY) RM_ALU; 
                default                                 : ID_EX_TYPE <= #(`DELAY) HALT;   //review it later
            endcase
        end
    end

    //EXECUTION (EX) STAGE 3

    always @(posedge clk1 ) begin
        if (HALTED == 0) begin
            EX_MEM_TYPE     <= #(`DELAY) ID_EX_TYPE;
            EX_MEM_IR       <= #(`DELAY) ID_EX_IR;
            //EX_MEM_B        <= #(`DELAY) ID_EX_B;
            BRANCH_TAKEN    <= #(`DELAY) 1'b0;  // <<<REVIEW THIS

            case (ID_EX_TYPE)
                RR_ALU : 
                    case (ID_EX_IR[`OPCODE])
                        ADD : EX_MEM_ALUOUT <= #(`DELAY) ID_EX_A + ID_EX_B;
                        SUB : EX_MEM_ALUOUT <= #(`DELAY) ID_EX_A - ID_EX_B;
                        AND : EX_MEM_ALUOUT <= #(`DELAY) ID_EX_A & ID_EX_B;
                        OR  : EX_MEM_ALUOUT <= #(`DELAY) ID_EX_A | ID_EX_B;
                        XOR : EX_MEM_ALUOUT <= #(`DELAY) ID_EX_A ^ ID_EX_B;
                        NOR : EX_MEM_ALUOUT <= #(`DELAY) ~(ID_EX_A | ID_EX_B);
                        XNOR: EX_MEM_ALUOUT <= #(`DELAY) ~(ID_EX_A ^ ID_EX_B);
                        NAND: EX_MEM_ALUOUT <= #(`DELAY) ~(ID_EX_A & ID_EX_B);
                        MUL : EX_MEM_ALUOUT <= #(`DELAY) ID_EX_A * ID_EX_B;
                        DIV : EX_MEM_ALUOUT <= #(`DELAY) ID_EX_A / ID_EX_B;
                        SLT : EX_MEM_ALUOUT <= #(`DELAY) ID_EX_A < ID_EX_B;
                        SGT : EX_MEM_ALUOUT <= #(`DELAY) ID_EX_A > ID_EX_B;
                        default : EX_MEM_ALUOUT <= #(`DELAY) 32'bxxxx_xxxx;
                            
                    endcase
                
                RM_ALU :
                    case (ID_EX_IR[`OPCODE])
                        ADDI : EX_MEM_ALUOUT <= #(`DELAY) ID_EX_A + ID_EX_IMM;
                        SUBI : EX_MEM_ALUOUT <= #(`DELAY) ID_EX_A - ID_EX_IMM;
                        MULI : EX_MEM_ALUOUT <= #(`DELAY) ID_EX_A * ID_EX_IMM;
                        DIVI : EX_MEM_ALUOUT <= #(`DELAY) ID_EX_A / ID_EX_IMM;
                        SLTI : EX_MEM_ALUOUT <= #(`DELAY) ID_EX_A < ID_EX_IMM;
                        SGTI : EX_MEM_ALUOUT <= #(`DELAY) ID_EX_A > ID_EX_IMM;
                        default : EX_MEM_ALUOUT <= #(`DELAY) 32'bxxxx_xxxx;
                    endcase

                LOAD , STORE :
                    begin
                        EX_MEM_ALUOUT <= #(`DELAY) ID_EX_A + ID_EX_IMM;
                        EX_MEM_B      <= #(`DELAY) ID_EX_B;
                    end
                    
                BRANCH : begin
                    EX_MEM_ALUOUT    <= #(`DELAY) ID_EX_NPC - ID_EX_IMM;
                    if (ID_EX_A==0) 
                        EX_MEM_CONDITION <= #(`DELAY) 1'b0;
                    else
                        EX_MEM_CONDITION <= #(`DELAY) 1'b1;
                    //EX_MEM_CONDITION <= #(`DELAY) ((ID_EX_A == 0) ? 1'b0 : 1'b1);
                end                         
                
            endcase
        end    
    end


    //  MEMORY ACCESS (MEM) STAGE  4
    //  MEMORY IS ACCESSED ONLY BY LOAD AND STORE.

    always @(posedge clk2 ) begin
        if (HALTED==0) begin
            MEM_WB_TYPE    <= #(`DELAY) EX_MEM_TYPE;
            MEM_WB_IR      <= #(`DELAY) EX_MEM_IR;
            MEM_WB_ALUOUT  <= #(`DELAY) EX_MEM_ALUOUT;

            case (EX_MEM_TYPE)
                LOAD : MEM_WB_LMD <= #(`DELAY) MEM[EX_MEM_ALUOUT];
                STORE: begin
                    if (BRANCH_TAKEN==0) begin              // Disable memory write when branch taken
                        MEM[EX_MEM_ALUOUT] <= #(`DELAY) EX_MEM_B;
                    end       
                end   
            endcase

        end
    end


    // WRITE-BACK (WB) STAGE  5

    always @(posedge clk1) begin
        if (BRANCH_TAKEN==0) begin                       // Disable Register write when branch taken
            case (MEM_WB_TYPE)
                RR_ALU : begin 
                            if(MEM_WB_IR[`RD]==6'b0) begin
                                $display("Error [at time=%g]! Cannot write to Register0 \nBecause Register0 is a special register and always contain Value '0'",$time);
                                $display("Check the destination Register in the intruction code and change it from Register0 to any other");
                            end
                            else
                                Register[MEM_WB_IR[`RD]] <= #(`DELAY) MEM_WB_ALUOUT; 
                end

                RM_ALU : begin
                            if(MEM_WB_IR[`RT]==6'b0) begin
                                $display("Error [at time=%g]! Cannot write to Register0 \nBecause Register0 is a special register and always contain Value '0'",$time);
                                $display("Check the destination Register in the intruction code and change it from Register0 to any other");
                            end
                            else
                                Register[MEM_WB_IR[`RT]] <= #(`DELAY) MEM_WB_ALUOUT;
                end 

                LOAD   : begin
                            if(MEM_WB_IR[`RT]==6'b0) begin
                                $display("Error [at time=%g]! Cannot write to Register0 \nBecause Register0 is a special register and always contain Value '0'",$time);
                                $display("Check the destination Register in the intruction code and change it from Register0 to any other");
                            end
                            else
                                Register[MEM_WB_IR[`RT]] <= #(`DELAY) MEM_WB_LMD;
                end

                HALT   : begin HALTED <= #(`DELAY) 1'b1; end

            endcase
        end
    end


endmodule