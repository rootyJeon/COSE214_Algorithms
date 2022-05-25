//
//  Author: Prof. Taeweon Suh
//          Computer Science & Engineering
//          Korea University
//  Date: July 14, 2020
//  Description: Skeleton design of RV32I Single-cycle CPU
//
//  Edited by Byungwoo Jeon, Korea University
//  Edited Date : Dec 10, 2021

`timescale 1ns/1ns
`define simdelay 1

module rv32i_cpu (
		        input         clk, reset,
            output [31:0] pc,		  		// program counter for instruction fetch
            input  [31:0] inst, 			// incoming instruction
            output        Memwrite, 	// 'memory write' control signal
            output [31:0] Memaddr,  	// memory address 
            output [31:0] MemWdata, 	// data to write to memory
            input  [31:0] MemRdata); 	// data read from memory

  wire [31:0] IF_ID_inst;
  wire [4:0]  alucontrol;
  wire        auipc, lui, alusrc, regwrite, memtoreg, memwrite, memread, branch, jal, jalr;


  controller i_controller(
    .opcode		(IF_ID_inst[6:0]), 
		.funct7		(IF_ID_inst[31:25]), 
		.funct3		(IF_ID_inst[14:12]),
    .memread  (memread),
		.auipc		(auipc),
		.lui			(lui),
		.memtoreg	(memtoreg),
		.memwrite	(memwrite),
		.branch		(branch),
		.alusrc		(alusrc),
		.regwrite	(regwrite),
		.jal			(jal),
		.jalr			(jalr),
		.alucontrol	(alucontrol));


  datapath i_datapath(
		.clk				(clk),
		.reset			(reset),
		.auipc			(auipc),
		.lui				(lui),
		.memtoreg		(memtoreg),
		.memwrite		(memwrite),
    .memread    (memread),
		.branch			(branch),
		.alusrc			(alusrc),
		.regwrite		(regwrite),
		.jal				(jal),
		.jalr				(jalr),
		.alucontrol	(alucontrol),
		.pc				  (pc),
		.inst				(inst),
		.MemWdata		(MemWdata),
		.MemRdata		(MemRdata),
		.EXE_MEM_aluout	(Memaddr),
    .IF_ID_inst (IF_ID_inst),
    .EXE_MEM_memwrite (Memwrite));

endmodule


//
// Instruction Decoder 
// to generate control signals for datapath
//
module controller(input  [6:0] opcode,
                  input  [6:0] funct7,
                  input  [2:0] funct3,
                  output       auipc,
                  output       lui,
                  output       alusrc,
                  output [4:0] alucontrol,
                  output       branch,
                  output       jal,
                  output       jalr,
                  output       memtoreg,
                  output       memwrite,
                  output       regwrite,
                  output       memread);

	maindec i_maindec(
		.opcode		(opcode),
		.auipc		(auipc),
		.lui			(lui),
		.memtoreg	(memtoreg),
		.memwrite	(memwrite),
		.branch		(branch),
		.alusrc		(alusrc),
		.regwrite	(regwrite),
		.jal			(jal),
		.jalr			(jalr),
    .memread  (memread));

	aludec i_aludec( 
		.opcode     (opcode),
		.funct7     (funct7),
		.funct3     (funct3),
		.alucontrol (alucontrol));

endmodule


//
// RV32I Opcode map = Inst[6:0]
//
`define OP_R			7'b0110011
`define OP_I_ARITH	7'b0010011
`define OP_I_LOAD  	7'b0000011
`define OP_I_JALR  	7'b1100111
`define OP_S			7'b0100011
`define OP_B			7'b1100011
`define OP_U_LUI		7'b0110111
`define OP_J_JAL		7'b1101111
`define OP_U_AUIPC  7'b0010111

//
// Main decoder generates all control signals except alucontrol 
//
//
module maindec(input  [6:0] opcode,
               output       auipc,
               output       lui,
               output       regwrite,
               output       alusrc,
               output       memtoreg, memwrite,
               output       branch, 
               output       jal,
               output       jalr,
               output       memread);

  reg [9:0] controls;

  assign {auipc, lui, regwrite, alusrc, memtoreg, 
          memwrite, branch, jal, jalr, memread} = controls;

  always @ (*)
  begin
    case(opcode)
      `OP_R: 			controls <=  10'b0010_0000_00; // R-type
      `OP_I_ARITH: 	controls <=  10'b0011_0000_00; // I-type Arithmetic
      `OP_I_LOAD: 	controls <=  10'b0011_1000_01; // I-type Load
      `OP_S: 			controls <=  10'b0001_0100_00; // S-type Store
      `OP_B: 			controls <=  10'b0000_0010_00; // B-type Branch
      `OP_U_LUI: 		controls <=  10'b0111_0000_00; // LUI
      `OP_J_JAL: 		controls <=  10'b0011_0001_00; // JAL
      `OP_I_JALR: controls <=  10'b0011_0000_10; // JALR
      default:    	controls <=  10'b0000_0000_00; // ???
    endcase
  end

endmodule

//
// ALU decoder generates ALU control signal (alucontrol)
//
module aludec(input      [6:0] opcode,
              input      [6:0] funct7,
              input      [2:0] funct3,
              output reg [4:0] alucontrol);

  always @ (*)

    case(opcode)

      `OP_R:   		// R-type
		begin
			case({funct7,funct3})
			 10'b0000000_000: alucontrol <=  5'b00000; // addition (add)
       10'b0000000_001: alucontrol <= #`simdelay 5'b00100; // sll (slli)
			 10'b0100000_000: alucontrol <=  5'b10000; // subtraction (sub)
			 10'b0000000_111: alucontrol <=  5'b00001; // and (and)
			 10'b0000000_110: alucontrol <=  5'b00010; // or (or)
          default:         alucontrol <=  5'bxxxxx; // ???
        endcase
		end

      `OP_I_ARITH:   // I-type Arithmetic
		begin
			case(funct3)
			 3'b000:  alucontrol <=  5'b00000; // addition (addi)
       3'b001:  alucontrol <=  5'b00100; // sll (slli)
			 3'b110:  alucontrol <=  5'b00010; // or (ori)
			 3'b111:  alucontrol <=  5'b00001; // and (andi)
       3'b100:  alucontrol <=  5'b00011; // xor (xori)
          default: alucontrol <=  5'bxxxxx; // ???
        endcase
		end

      `OP_I_LOAD: 	// I-type Load (LW, LH, LB...)
      	alucontrol <=  5'b00000;  // addition 

      `OP_B:   		// B-type Branch (BEQ, BNE, ...)
      	alucontrol <=  5'b10000;  // subtraction 

      `OP_S:   		// S-type Store (SW, SH, SB)
      	alucontrol <=  5'b00000;  // addition 

      `OP_U_LUI: 		// U-type (LUI)
      	alucontrol <=  5'b00000;  // addition

      `OP_I_JALR:   //I-type JALR
        alucontrol <=  5'b00000; // addition

      default: 
      	alucontrol <=  5'b00000;  // 

    endcase
    
endmodule


//
// CPU datapath
//
module datapath(input             clk, reset,
                input [31:0]      inst,
                input             auipc,
                input             lui,
                input             regwrite,
                input             memtoreg,
                input             memwrite,
                input             memread,
                input             alusrc, 
                input [4:0]       alucontrol,
                input             branch,
                input             jal,
                input             jalr,
                input [31:0]      MemRdata,
                output reg [31:0] pc,
                output reg [31:0] EXE_MEM_aluout,
                output reg [31:0] IF_ID_inst,
                output reg        EXE_MEM_memwrite,
                output [31:0]     MemWdata);

  wire [4:0]  rs1, rs2, rd;
  wire [2:0]  funct3;
  reg  [31:0] rs1_data, rs2_data;
  reg  [31:0] rd_data;
  wire [20:1] jal_imm;
  wire [31:0] se_jal_imm;
  wire [12:1] br_imm;
  wire [31:0] se_br_imm;
  wire [31:0] se_imm_itype;
  wire [31:0] se_imm_stype;
  wire [31:0] auipc_lui_imm;
  reg  [31:0] alusrc1;
  reg  [31:0] alusrc2;
  wire [31:0] branch_dest, jal_dest, jalr_dest;
  wire [31:0] aluout;
  wire		    Nflag, Zflag, Cflag, Vflag;
  wire		    beq_taken;
  wire		    blt_taken;
  wire        bgeu_taken;
  // ###### Byungwoo Jeon : Start ######
  wire        bltu_taken, bge_taken;
  wire        f3beq, f3blt, f3bgeu, f3bltu, f3bge;
  // ###### Byungwoo Jeon : End ######

  wire        bne_taken;
  wire		    f3bne;
  wire        IF_ID_flush, ID_EXE_flush, EXE_MEM_flush, MEM_WB_flush;
  wire [31:0] init_rs1_data, init_rs2_data, pre_sum;
  wire [31:0] pre_b2;
  wire	      pre_Nflag, pre_Zflag, pre_Cflag, pre_Vflag;

  reg [31:0]  IF_ID_pc, ID_EXE_pc, EXE_MEM_pc, MEM_WB_pc;
  reg [4:0]   ID_EXE_rd, EXE_MEM_rd, MEM_WB_rd;
  reg [4:0]   ID_EXE_rs1, ID_EXE_rs2;
  reg [31:0]  ID_EXE_rs1_data;
  reg [31:0]  ID_EXE_rs2_data, EXE_MEM_rs2_data;
  reg [2:0]   ID_EXE_funct3;
  reg [31:0]  ID_EXE_se_jal_imm, ID_EXE_se_br_imm, ID_EXE_se_imm_itype, ID_EXE_se_imm_stype, ID_EXE_auipc_lui_imm;
  reg [4:0]   ID_EXE_alucontrol;
  reg         ID_EXE_auipc, ID_EXE_lui, ID_EXE_regwrite, ID_EXE_memtoreg, ID_EXE_memwrite, ID_EXE_memread, ID_EXE_alusrc, ID_EXE_branch, ID_EXE_jal, ID_EXE_jalr, stall;
  reg [31:0]  EXE_MEM_jal_dest, EXE_MEM_branch_dest;
  reg         EXE_MEM_regwrite, EXE_MEM_memtoreg, EXE_MEM_memread, EXE_MEM_jal, EXE_MEM_jalr;
  reg [31:0]  MEM_WB_MemRdata, MEM_WB_aluout;
  reg         MEM_WB_regwrite, MEM_WB_memtoreg, MEM_WB_jal, MEM_WB_jalr;

  assign rs1 = IF_ID_inst[19:15];
  assign rs2 = IF_ID_inst[24:20];
  assign funct3  = IF_ID_inst[14:12];

  adder_32bit i_preALU(
            .a    (rs1_data),
			     	.b    (pre_b2),
						.cin  (alucontrol[4]),
						.sum  (pre_sum),
						.N    (pre_Nflag),
						.Z    (pre_Zflag),
						.C    (pre_Cflag),
						.V    (pre_Vflag));

  // IF_ID_ff
  always @ (posedge clk)
    begin

      if (stall)
        begin
          IF_ID_inst <= IF_ID_inst; 
          IF_ID_pc <= IF_ID_pc;
        end

      else if (IF_ID_flush)
        begin
          IF_ID_pc <= 32'b0;
          IF_ID_inst <= 32'b0;
        end

      else
        begin   
          IF_ID_inst <= inst;
          IF_ID_pc <= pc;
        end
      
    end

  // ID_EXE_ff
  always @ (posedge clk)
    begin
      if (stall | ID_EXE_flush)
        begin

          ID_EXE_rs1 <= 5'b0;
          ID_EXE_rs2 <= 5'b0;
          ID_EXE_rd <= 5'b0;
          ID_EXE_rs1_data <= 32'b0;
          ID_EXE_rs2_data <= 32'b0;
          ID_EXE_auipc <= 1'b0;
          ID_EXE_lui <= 1'b0;
          ID_EXE_regwrite <= 1'b0;
          ID_EXE_memtoreg <= 1'b0;
          ID_EXE_memwrite <= 1'b0;
          ID_EXE_memread <= 1'b0;
          ID_EXE_alusrc <= 1'b0;
          ID_EXE_branch <= 1'b0;
          ID_EXE_jal <= 1'b0;
          ID_EXE_jalr <= 1'b0;
          ID_EXE_alucontrol <= 5'b0;

        end
      
      else
        begin

          ID_EXE_pc <= IF_ID_pc;
          ID_EXE_rs1 <= rs1;
          ID_EXE_rs2 <= rs2;
          ID_EXE_rd <= IF_ID_inst[11:7];
          ID_EXE_rs1_data <= rs1_data;
          ID_EXE_rs2_data <= rs2_data;
          ID_EXE_funct3 <= funct3;
          ID_EXE_auipc_lui_imm <= auipc_lui_imm;
          ID_EXE_se_br_imm <= se_br_imm;
          ID_EXE_se_imm_itype <= se_imm_itype;
          ID_EXE_se_imm_stype <= se_imm_stype;
          ID_EXE_se_jal_imm <= se_jal_imm;
          ID_EXE_auipc <= auipc;
          ID_EXE_lui <= lui;
          ID_EXE_regwrite <= regwrite;
          ID_EXE_memtoreg <= memtoreg;
          ID_EXE_memwrite <= memwrite;
          ID_EXE_memread <= memread;
          ID_EXE_alusrc <= alusrc;
          ID_EXE_branch <= branch;
          ID_EXE_jal <= jal;
          ID_EXE_jalr <= jalr;
          ID_EXE_alucontrol <= alucontrol;

        end
    end

  // EXE_MEM_ff
  always @ (posedge clk)
    begin
        EXE_MEM_pc <= ID_EXE_pc;
        EXE_MEM_rd <= ID_EXE_rd;
        EXE_MEM_rs2_data <= ID_EXE_rs2_data;
        EXE_MEM_regwrite <= ID_EXE_regwrite;
        EXE_MEM_memtoreg <= ID_EXE_memtoreg;
        EXE_MEM_memwrite <= ID_EXE_memwrite;
        EXE_MEM_memread <= ID_EXE_memread;
        EXE_MEM_jal <= ID_EXE_jal;
        EXE_MEM_jalr <= ID_EXE_jalr;
        EXE_MEM_aluout <= aluout;
        EXE_MEM_jal_dest <= jal_dest;
    end

  // MEM_WB_ff
  always @ (posedge clk)
    begin
        MEM_WB_pc <= EXE_MEM_pc;
        MEM_WB_rd <= EXE_MEM_rd;
        MEM_WB_regwrite <= EXE_MEM_regwrite;
        MEM_WB_memtoreg <= EXE_MEM_memtoreg;
        MEM_WB_jal <= EXE_MEM_jal;
        MEM_WB_jalr <= EXE_MEM_jalr;
        MEM_WB_aluout <= EXE_MEM_aluout;
        MEM_WB_MemRdata <= MemRdata;
    end


  // Interlock
  always @ (*)
    begin
        if(
          ID_EXE_memread & 
            (ID_EXE_rd == rs1 | ID_EXE_rd == rs2)) stall = 1'b1;
        else stall = 1'b0;
    end

  // Data_Forwarding
  always @ (*)
    begin

      if (~ID_EXE_memwrite &
                ID_EXE_rd != 0 && ID_EXE_rd == rs1)   rs1_data[31:0] = aluout[31:0];
    
      else if (EXE_MEM_memread &
                EXE_MEM_rd != 0 && EXE_MEM_rd == rs1) rs1_data[31:0] = MemRdata[31:0];

      else if (~EXE_MEM_memread &
                EXE_MEM_rd != 0 && EXE_MEM_rd == rs1) rs1_data[31:0] = EXE_MEM_aluout[31:0];

      else if (MEM_WB_rd != 0 && MEM_WB_rd == rs1)    rs1_data[31:0] = rd_data[31:0];

      else                                            rs1_data[31:0] = init_rs1_data[31:0];

    end

  always @ (*)
    begin

      if (~ID_EXE_memwrite &
            ID_EXE_rd != 0 && ID_EXE_rd == rs2)       rs2_data[31:0] = aluout[31:0];

      else if (EXE_MEM_memread &
                EXE_MEM_rd != 0 && EXE_MEM_rd == rs2) rs2_data[31:0] = MemRdata[31:0];

      else if (~EXE_MEM_memread &
                EXE_MEM_rd != 0 && EXE_MEM_rd == rs2) rs2_data[31:0] = EXE_MEM_aluout[31:0];

      else if (MEM_WB_rd != 0 && MEM_WB_rd == rs2)    rs2_data[31:0] = rd_data[31:0];

      else                                            rs2_data[31:0] = init_rs2_data[31:0];

    end

  //
  // PC (Program Counter) logic 
  //
  assign f3beq  = (funct3 == 3'b000); 
  assign f3blt  = (funct3 == 3'b100);
  assign f3bgeu = (funct3 == 3'b111);
  assign f3bne = (funct3 == 3'b001);

  // ###### Byungwoo Jeon : Start ######
  assign f3bltu = (funct3 == 3'b110);
  assign f3bge  = (funct3 == 3'b101);
  // ###### Byungwoo Jeon : End ######

  assign beq_taken  =  branch & f3beq & pre_Zflag;
  assign blt_taken  =  branch & f3blt & (pre_Nflag != pre_Vflag);
  assign bgeu_taken = branch & f3bgeu & pre_Cflag;
  assign bne_taken = branch & f3bne & ~pre_Zflag;

  // ###### Byungwoo Jeon : Start ######
  assign bltu_taken = branch & f3bltu & ~pre_Cflag;
  assign bge_taken = branch & f3bge & (pre_Nflag == pre_Vflag);
  // ###### Byungwoo Jeon : End ######

  assign pre_b2 = alucontrol[4] ? ~rs2_data:rs2_data;
  assign branch_dest = (IF_ID_pc + se_br_imm);
  assign jal_dest 	 = (IF_ID_pc + se_jal_imm);
  assign jalr_dest   = (rs1_data + se_imm_itype);


  // ###### Byungwoo Jeon : Start ######
  assign IF_ID_flush = ~stall & (beq_taken | bne_taken | blt_taken | bgeu_taken | jal | jalr | bltu_taken | bge_taken);
  // ###### Byungwoo Jeon : End ######

  always @ (posedge clk, posedge reset)
    begin
      if (reset)  pc <= 32'b0;

      else
        begin
            if (stall)
              pc <=  #`simdelay pc;

            else if (jal)
              pc <=  #`simdelay jal_dest;

            else if (jalr)
              pc <=  #`simdelay jalr_dest;

  // ###### Byungwoo Jeon : Start ######
            else if (beq_taken | bne_taken | bgeu_taken | blt_taken | bltu_taken | bge_taken)
              pc <=  #`simdelay branch_dest;
  // ###### Byungwoo Jeon : End ######

            else
              pc <=  #`simdelay (pc + 4); // No branch and no stall case
        end
    end


  // JAL immediate
  assign jal_imm[20:1] = {IF_ID_inst[31],IF_ID_inst[19:12],IF_ID_inst[20],IF_ID_inst[30:21]};
  assign se_jal_imm[31:0] = {{11{jal_imm[20]}},jal_imm[20:1],1'b0};

  // Branch immediate
  assign br_imm[12:1] = {IF_ID_inst[31],IF_ID_inst[7],IF_ID_inst[30:25],IF_ID_inst[11:8]};
  assign se_br_imm[31:0] = {{19{br_imm[12]}},br_imm[12:1],1'b0};


  // 
  // Register File 
  //
  regfile i_regfile(
    .clk			(clk),
    .we			  (MEM_WB_regwrite),
    .rs1			(rs1),
    .rs2			(rs2),
    .rd			  (MEM_WB_rd),
    .rd_data	(rd_data),
    .rs1_data	(init_rs1_data),
    .rs2_data	(init_rs2_data));

	assign MemWdata = EXE_MEM_rs2_data;

	//
	// ALU 
	//
	alu i_alu(
		.a			  (alusrc1),
		.b			  (alusrc2),
		.alucont  (ID_EXE_alucontrol),
		.result	  (aluout),
		.N			  (Nflag),
		.Z			  (Zflag),
		.C			  (Cflag),
		.V			  (Vflag));


	// 1st source to ALU (alusrc1) : Mux alpha case
	always @ (*)
    begin

      if      (ID_EXE_auipc)	                                    alusrc1[31:0] = ID_EXE_pc;
      else if (ID_EXE_lui) 		                                    alusrc1[31:0] = 32'b0;
      else if (EXE_MEM_regwrite &&
                EXE_MEM_rd != 5'b0 & EXE_MEM_rd == ID_EXE_rs1)    alusrc1[31:0] = EXE_MEM_aluout[31:0];
      else if (MEM_WB_regwrite &&
                MEM_WB_rd != 5'b0 && MEM_WB_rd == ID_EXE_rs1)     alusrc1[31:0] = rd_data[31:0];
      else          		                                          alusrc1[31:0] = ID_EXE_rs1_data[31:0];
      
    end
	
	// 2nd source to ALU (alusrc2) : Mux beta case
	always @ (*)
    begin

      if	    (ID_EXE_auipc | ID_EXE_lui)			                    alusrc2[31:0] = ID_EXE_auipc_lui_imm[31:0];
      else if (ID_EXE_alusrc & ID_EXE_memwrite)	                  alusrc2[31:0] = ID_EXE_se_imm_stype[31:0];
      else if (ID_EXE_alusrc)					                            alusrc2[31:0] = ID_EXE_se_imm_itype[31:0];
      else if (~ID_EXE_alusrc & EXE_MEM_regwrite &&
                EXE_MEM_rd != 5'b0 && EXE_MEM_rd == ID_EXE_rs2)   alusrc2[31:0] = EXE_MEM_aluout[31:0];
      else if (~ID_EXE_alusrc & MEM_WB_regwrite &&
                MEM_WB_rd != 5'b0 && MEM_WB_rd == ID_EXE_rs2)     alusrc2[31:0] = rd_data[31:0];
      else									                                      alusrc2[31:0] = ID_EXE_rs2_data[31:0];

    end
	
	assign se_imm_itype[31:0] = {{20{IF_ID_inst[31]}},IF_ID_inst[31:20]};
	assign se_imm_stype[31:0] = {{20{IF_ID_inst[31]}},IF_ID_inst[31:25],IF_ID_inst[11:7]};
	assign auipc_lui_imm[31:0] = {IF_ID_inst[31:12],12'b0};

	// Data selection for writing to RF
	always @ (*)
    begin
        if	      (MEM_WB_jal | MEM_WB_jalr)  rd_data[31:0] = MEM_WB_pc + 4;
        else if   (MEM_WB_memtoreg)	          rd_data[31:0] = MEM_WB_MemRdata;
        else						                      rd_data[31:0] = MEM_WB_aluout;
    end
	
endmodule