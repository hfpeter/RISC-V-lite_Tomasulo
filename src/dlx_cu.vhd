library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use work.myTypes.all;
--use WORK.constants.all; 
--use ieee.numeric_std.all;
--use work.all;
entity dlx_cu is
  generic (
		MICROCODE_MEM_SIZE :     integer := 13;  -- Microcode Memory Size
		FUNC_SIZE          :     integer := 11;  -- Func Field Size for R-Type Ops
		OP_CODE_SIZE       :     integer := 6;  -- Op Code Size
		-- ALU_OPC_SIZE       :     integer := 6;  -- ALU Op Code Word Size
		IR_SIZE            :     integer := 32;  -- Instruction Register Size    
		CW_SIZE            :     integer := 15;
		
		PC_SIZE      	    :     integer := 32       -- Program Counter Size	 
	 );  -- Control Word Size
  port (
	 pc_dlx		:in std_logic_vector(31 downto 0);
    Clk                : in  std_logic;  -- Clock
    Rst                : in  std_logic;  -- Reset:Active-Low
    -- Instruction Register
    IR_IN              : in  std_logic_vector(IR_SIZE - 1 downto 0);--32bit   
    -- Instruction Register
    -- IF Control Signal
    IR_LATCH_EN        : buffer std_logic;  -- Instruction Register Latch Enable
    NPC_LATCH_EN       : buffer std_logic;
    -- ID Control Signals
    RegA_LATCH_EN      : buffer std_logic;  -- Register A Latch Enable
    RegB_LATCH_EN      : buffer std_logic;  -- Register B Latch Enable
    RegIMM_LATCH_EN    : buffer std_logic;  -- Immediate Register Latch Enable
    -- EX Control Signals
    MUXA_SEL           : buffer std_logic;  -- MUX-A Sel
    MUXB_SEL           : buffer std_logic;  -- MUX-B Sel
    ALU_OUTREG_EN      : buffer std_logic;  -- ALU Output Register Enable
    EQ_COND            : buffer std_logic;  -- Branch if (not) Equal to Zero
    -- ALU Operation Code
    ALU_OPCODE         : out std_logic_vector(OP_CODE_SIZE - 1 downto 0); -- choose between implicit or exlicit coding, like std_logic_vector(ALU_OPC_SIZE -1 downto 0);   
    -- MEM Control Signals
    DRAM_WE            : buffer std_logic;  -- Data RAM Write Enable
    LMD_LATCH_EN       : buffer std_logic;  -- LMD Register Latch Enable
    JUMP_EN            : buffer std_logic;  -- JUMP Enable Signal for PC input MUX
    PC_LATCH_EN        : buffer std_logic;  -- Program Counte Latch Enable
    -- WB Control signals
    WB_MUX_SEL         : buffer std_logic;  -- Write Back MUX Sel
    RF_WE              : buffer std_logic;
	 ---test
	cu_out_a    : out std_logic_vector(32-1 downto 0);
	cu_out_b    : out std_logic_vector(32-1 downto 0); 
	alu_out_cu		:out std_logic_vector(31 downto 0);
	
				tag_flr2rsm:out std_logic_vector(4 downto 0);
				tag_rsm2flr:out std_logic_vector(4 downto 0);
				tag_flr2rsa:out std_logic_vector(4 downto 0);
				tag_rsa2flr:out std_logic_vector(4 downto 0);
				id_dest_flr2rs:out std_logic_vector(4 downto 0);
				id_dest_rsa2flr:out std_logic_vector(4 downto 0);
				id_dest_rsm2flr:out std_logic_vector(4 downto 0);
				flr_data1:out std_logic_vector(32 - 1 downto 0);				 
				flr_data2:out std_logic_vector(32 - 1 downto 0);				 
				data_dest_m:out std_logic_vector(32 - 1 downto 0);				 
				data_dest_a:out std_logic_vector(32 - 1 downto 0)	
	 );  -- Register File Write Enable
end dlx_cu;
architecture dlx_cu_hw of dlx_cu is

        --component  ROB is 
	--port (
	--ins_type :in std_logic_vector(31 downto 0);
	--value    :in std_logic_vector(31 downto 0);
	--ready_done    :in std_logic;
	--destination :out std_logic_vector(7 downto 0);
	--);	
  component  CDB port(rst :in std_logic;clk :in std_logic; 
				 instr :in std_logic_vector(32 - 1 downto 0);
				 bus_out :out std_logic_vector(32 - 1 downto 0);
				r_tag_flr2rsm:out std_logic_vector(4 downto 0);
				r_tag_rsm2flr:out std_logic_vector(4 downto 0);
				r_tag_flr2rsa:out std_logic_vector(4 downto 0);
				r_tag_rsa2flr:out std_logic_vector(4 downto 0);
				r_id_dest_flr2rs:out std_logic_vector(4 downto 0);
				r_id_dest_rsa2flr:out std_logic_vector(4 downto 0);
				r_id_dest_rsm2flr:out std_logic_vector(4 downto 0);
				r_flr_data1:out std_logic_vector(32 - 1 downto 0);				 
				r_flr_data2:out std_logic_vector(32 - 1 downto 0);				 
				r_data_dest_m:out std_logic_vector(32 - 1 downto 0);				 
				r_data_dest_a:out std_logic_vector(32 - 1 downto 0)  
				 ); 
				 end component;	
	component ROB_RenameRF is 
	port (
	ins :in std_logic_vector(31 downto 0);
	rst :in std_logic
	);
	end component;	
	component decoder is
	port(
	   path_bk_dec :out std_logic_vector(31 downto 0);
	   pc_dec		:in std_logic_vector(31 downto 0);
		dec_funcode7:in std_logic_vector(6 downto 0);
		dec_funcode:in std_logic_vector(2 downto 0);

		dec_opcode:in std_logic_vector(6 downto 0);
		ctrl_byte:in std_logic_vector(14 downto 0);
		dec_alu_ctrl_bit:in std_logic;	
		imm20_dec : in std_logic_vector(19 downto 0);

	   alutype: out std_logic_vector(3 downto 0);
		dec_IMM_LATCH_EN:in std_logic;		
		dec_writebk	:in std_logic_vector(31 downto 0);--
	   Istrct_f: in std_logic_vector(32-1 downto 0);--

		decode_out_a    : OUT std_logic_vector(32-1 downto 0);--
		decode_out_b    : OUT std_logic_vector(32-1 downto 0);--
		ADD_RD1 : IN std_logic_vector(4 downto 0);--
		ADD_RD2 : IN std_logic_vector(4 downto 0);--

		ADD_WR  : in std_logic_vector(4 downto 0);--
		RD1   : IN std_logic;
		RD2   : IN std_logic;
		WR    : IN std_logic;

		rf_0_read_write:in std_logic;
		enable: in std_logic;		
		reset : in std_logic;
		CLK   : in std_logic;

		alu_out		:out std_logic_vector(31 downto 0)		
	);
	end component;

  type INARR is array (integer range 0 to 6) of std_logic_vector(31 downto 0);
  signal INARR_0 : INARR;  
  
  type mem_array is array (integer range 0 to 63) of std_logic_vector(14 downto 0);
    signal cw_mem : mem_array := (
"101111100000011",--when "nop" can the 7th be 0 affect the lw and sw
"100100000001000",
"100100000001000",--Jump (0X02) instruction encoding corresponds to the address to this ROM
"100110000001000", -- JAL  R type: 
"110110001001100", ----beqz
"111110001001100", ----BNEZ  
"100110001000000", -- 
"100110001000000", -- 
"101111110000011", -- addi
"101111110000011",-- addui
"101111110000011", --subi
"101111110000011", --
"101111110000011",--andi
"101111110000011",--ori
"101111110000011",--xori
"101101110110010",
"101101110110010",
"101101110110010",
"101101110110010",
"101101110110010",
"101111100000011",--slli
"101101110110010",--nop
"101111100000011",--srli
"101101110110010",
"101101110110010",
"101111100000011",--snei
"101101110110010",
"101101110110010",
"101101110110010",
"101111110000011",--sgei
"101101110110010",
"000100000000001",
"000100000000010",
"000100000000000",
"000100000000000",
"101110000100000",--lw mem to r
"000000000000000",
"000000000000000",
"000000000000000",
"000000000000000",
"000000000000000",
"000000000000000",
"000000000000000",
"101110001000000",--sw 
"101101110110010",
"101101110110010",
"101101110110010",
"101101110110010",
"101101110110010",
"101101110110010",
"101101110110010",
"101101110110010",
"101101110110010",
"101101110110010",
"101101110110010",
"101101110110010",
"101101110110010",
"101101110110010",
"101101110110010",
"101101110110010",
"101101110110010",
"101101110110010",
"101101110110010",
"101101110111010"


--"000000000000000"
										  
										  );-- to be completed (enlarged and filled)
	signal IR_opcode : std_logic_vector(OP_CODE_SIZE -1 downto 0);  -- OpCode part of ir_tmp
	signal IR_func : std_logic_vector(10 downto 0);   -- Func part of ir_tmp when Rtype
	signal cw   : std_logic_vector(CW_SIZE - 1 downto 0); -- full control word read from cw_mem
	-- control word is shifted to the correct stage
	signal cw1 : std_logic_vector(CW_SIZE-1 downto 0);      -- first stage  CW_SIZE=15
	signal cw2 : std_logic_vector(CW_SIZE-1-2 downto 0); -- second stage CW_SIZE=15
	signal cw3 : std_logic_vector(CW_SIZE-1-5 downto 0); -- third stage  CW_SIZE=15
	signal cw4 : std_logic_vector(CW_SIZE-1-9 downto 0); -- fourth stage  CW_SIZE=15
	signal cw5 : std_logic_vector(CW_SIZE-1-13 downto 0); -- fifth stage  CW_SIZE=15

	signal aluOpcode_i: std_logic_vector(CW_SIZE -1 downto 0); -- ALUOP defined in package
	signal aluOpcode1: std_logic_vector(CW_SIZE -1 downto 0);
	signal aluOpcode2: std_logic_vector(CW_SIZE -1 downto 0);
	signal aluOpcode3: std_logic_vector(CW_SIZE -1 downto 0);
	--signal data_wrtback : std_logic_vector(32-1 downto 0);
	signal data_A : std_logic_vector(32-1 downto 0); 
	signal data_B : std_logic_vector(32-1 downto 0); 
	signal RS1 : std_logic_vector(4  downto 0);  
	signal RS2 : std_logic_vector(4  downto 0);    
	signal W_addr : std_logic_vector(4  downto 0);   
	signal PC : std_logic_vector(PC_SIZE - 1 downto 0);
	-- Datapath Bus signals
	signal PC_BUS : std_logic_vector(PC_SIZE -1 downto 0);
	signal Clock: std_logic;
	signal reset_0:std_logic;
	signal rf_rd1:std_logic:= '0';
	signal rf_rd2:std_logic:= '0';
	signal rf_ab_en:std_logic:='0';
	signal aluout_tmp :std_logic_vector(31 downto 0);
	signal   alu_ctrl:std_logic_vector(3 downto 0);
	signal exe_ctrl_byte:std_logic_vector(15 downto 0);
	signal imm16_extend:std_logic_vector(15 downto 0);
	signal cu_out_a_tmp: std_logic_vector(31 downto 0);
	signal cu_out_b_tmp: std_logic_vector(31 downto 0);	
	signal	exe_out  	  : std_logic_vector(31 downto 0);	
	signal	exe_out_tmp : std_logic_vector(31 downto 0);	
	signal   ctrl_byte :std_logic_vector(14 downto 0);
	signal   ir_tmp:std_logic_vector(31 downto 0);	
	signal   cu_reg_exchng:std_logic_vector(31 downto 0);	
   signal clkcnt : std_logic_vector(PC_SIZE - 1 downto 0);
   
   signal ltag_flr2rsm: std_logic_vector(4 downto 0);
   signal ltag_rsm2flr: std_logic_vector(4 downto 0);
   signal ltag_flr2rsa: std_logic_vector(4 downto 0);
   signal ltag_rsa2flr: std_logic_vector(4 downto 0);
   signal lid_dest_flr2rs: std_logic_vector(4 downto 0);
   signal lid_dest_rsa2flr: std_logic_vector(4 downto 0);
   signal lid_dest_rsm2flr: std_logic_vector(4 downto 0);
   signal lflr_data1: std_logic_vector(32 - 1 downto 0);				 
   signal lflr_data2: std_logic_vector(32 - 1 downto 0);				 
   signal ldata_dest_m: std_logic_vector(32 - 1 downto 0);				 
   signal ldata_dest_a: std_logic_vector(32 - 1 downto 0);  
begin  -- dlx_cu_rtl
    ROB_RenameRF0 : ROB_RenameRF
	Port Map (INARR_0(0),reset_0);
--    rob_0 :ROB  
--	Port Map  (
	--INARR_0(0),
	--INARR_0(0),
	--ready_done,
	--destination
	--);
cdb0:CDB port map(rst=>Rst ,clk => Clk,
				 instr=> INARR_0(0),
				 bus_out=> alu_out_cu,
				r_tag_flr2rsm           =>tag_flr2rsm,
				r_tag_rsm2flr           =>tag_rsm2flr,
				r_tag_flr2rsa           =>tag_flr2rsa,
				r_tag_rsa2flr           =>tag_rsa2flr,
				r_id_dest_flr2rs        =>id_dest_flr2rs,
				r_id_dest_rsa2flr       =>id_dest_rsa2flr,
				r_id_dest_rsm2flr       =>id_dest_rsm2flr,
				r_flr_data1		=>flr_data1,			 
				r_flr_data2		=>flr_data2,			 
				r_data_dest_m		=>data_dest_m,				 
				r_data_dest_a           =>data_dest_a 				
				 ); 	
decode0 : decoder 
	Port Map (
	cu_reg_exchng,
	pc_dlx,
	INARR_0(3)(31 downto 25),
	INARR_0(3)(14 downto 12),

	INARR_0(3)(6 downto 0),--opcode ir_in(6 downto 0),
	ctrl_byte,
	ALU_OUTREG_EN,
	INARR_0(3)(19 downto 0),--imm16_extend,

	alu_ctrl,
	dec_imm_latch_en=> RegIMM_LATCH_EN,
	dec_writebk=>exe_out,
	Istrct_f=>INARR_0(3),--ir_in,--INARR_0(0),--ir_tmp,ir_in,--

	decode_out_a=>data_A,
	decode_out_b=>data_B,
	ADD_RD1=>INARR_0(3)(19 downto 15),--ir_tmp
	ADD_RD2=>INARR_0(3)(11 downto 7),

	ADD_WR=> INARR_0(3)(15 downto 11),--W_addr,
	RD1=>cw2(CW_SIZE - 3),--cw1(CW_SIZE-2),
	RD2=>cw2(CW_SIZE - 4),--cw1(CW_SIZE-3),
	WR=>RF_WE,--cw1(3),

	rf_0_read_write=>cw1(CW_SIZE-15),--
	enable=>cw1(CW_SIZE-1),
	reset=>reset_0,
	CLK=>Clock,

	alu_out=>exe_out_tmp--alu_out_cu--aluout_tmp
	);

		reset_0<=rst;
		clock<=clk;
		ir_tmp<=IR_IN;

		-- stage 1 fetch
		ctrl_byte(14)  <= cw1(CW_SIZE - 1);--'1';--
		ctrl_byte(13) <= cw1(CW_SIZE - 2);--CW_SIZE=15
		--ctrl_byte()decode
		ctrl_byte(12) <= cw2(CW_SIZE - 3);--CW_SIZE=15
		ctrl_byte(11) <= cw2(CW_SIZE - 4);--CW_SIZE=15
		ctrl_byte(10) <= cw2(CW_SIZE - 5);--CW_SIZE=15
		--ctrl_byte()execute
		ctrl_byte(9)   <= cw3(CW_SIZE - 6);--CW_SIZE=15
		ctrl_byte(8)   <= cw3(CW_SIZE - 7);--CW_SIZE=15
		ctrl_byte(7) <= cw3(CW_SIZE - 8);--CW_SIZE=15
		ctrl_byte(6)   <= cw3(CW_SIZE - 9);--CW_SIZE=15
		--ctrl_byte()access memory
		ctrl_byte(5)  <= cw4(CW_SIZE - 10);--CW_SIZE=15
		ctrl_byte(4) <= cw4(CW_SIZE - 11);--CW_SIZE=15
		ctrl_byte(3)  <= cw4(CW_SIZE - 12);--CW_SIZE=15
		ctrl_byte(2)  <= cw4(CW_SIZE - 13);--CW_SIZE=15
		--ctrl_byte()write back
		ctrl_byte(1)<= cw5(CW_SIZE - 14);--CW_SIZE=15
		ctrl_byte(0)<= cw5(CW_SIZE - 15);--CW_SIZE=15
		
		--ALU_OPCODE(14 downto 0)<= cw_mem(conv_integer( IR_IN(31 downto 26)));
		IR_opcode(5 downto 0) <= ir_in(31 downto 26);	
		ALU_OPCODE            <= ir_in(31 downto 26);		
		IR_func(10 downto 0)  <= ir_in(10 downto 0);	
		
		IR_LATCH_EN  <= cw1(CW_SIZE - 1);--'1';--
		NPC_LATCH_EN <= cw1(CW_SIZE - 2);--CW_SIZE=15
		-- stage 2 decode
		RegA_LATCH_EN   <= cw2(CW_SIZE - 3);--CW_SIZE=15
		RegB_LATCH_EN   <= cw2(CW_SIZE - 4);--CW_SIZE=15
		RegIMM_LATCH_EN <= cw2(CW_SIZE - 5);--CW_SIZE=15
		-- stage 3 execute
		MUXA_SEL      <= cw3(CW_SIZE - 6);--CW_SIZE=15
		MUXB_SEL      <= cw3(CW_SIZE - 7);--CW_SIZE=15
		ALU_OUTREG_EN <= cw3(CW_SIZE - 8);--CW_SIZE=15
		EQ_COND       <= cw3(CW_SIZE - 9);--CW_SIZE=15
		-- stage 4 access memory
		DRAM_WE      <= cw4(CW_SIZE - 10);--CW_SIZE=15
		LMD_LATCH_EN <= cw4(CW_SIZE - 11);--CW_SIZE=15
		JUMP_EN      <= cw4(CW_SIZE - 12);--CW_SIZE=15
		PC_LATCH_EN  <= cw4(CW_SIZE - 13);--CW_SIZE=15
		-- stage 5 write back
		WB_MUX_SEL <= cw5(CW_SIZE - 14);--CW_SIZE=15
		RF_WE      <= cw5(CW_SIZE - 15);--CW_SIZE=15
  -- process to pipeline control words
CW_PIPE: process (clock, reset_0)
begin  -- process Clk

    if reset_0 = '1' 
	 then                   -- asynchronous reset (active low)
	 --ALU_OPCODE<="101010";
     --cw1 <= "110000000000100";--(others => '0');
	 cw1 <= (others => '0');
     cw2 <= (others => '0');
     cw3 <= (others => '0');
     cw4 <= (others => '0');
     cw5 <= (others => '0');
	  --cu_reg_exchng<=(others => '0');
    elsif clock'event and clock = '1' then  -- rising clock edge
	    if INARR_0(0)=x"00000000" then
		   cw1<="111111000000000";
		 else
			cw1        <= cw_mem(conv_integer( IR_opcode));--
		 end if;

			cw2 <= cw1(12 downto 0);-- cw1(CW_SIZE-1-2 downto 0);- -CW_SIZE=15 --
			cw3 <= cw2(9 downto 0); -- cw2(CW_SIZE-1-5 downto 0);- -CW_SIZE=15   
			cw4 <= cw3(5 downto 0); -- cw3(CW_SIZE-1-9 downto 0);- -CW_SIZE=15   
			cw5 <= cw4(1 downto 0); -- cw4(CW_SIZE-1-13 downto 0); -CW_SIZE=15  	

			cu_out_a(14 downto 0)<=ctrl_byte;--
			cu_out_a(31 downto 15)<="00000000000000000";
			cu_out_b<=data_B;--
			
			INARR_0(0)<=IR_IN;
			INARR_0(1)<=INARR_0(0);
			INARR_0(2)<=INARR_0(1);
			INARR_0(3)<=INARR_0(2);
			INARR_0(4)<=INARR_0(3);
			INARR_0(5)<=INARR_0(4);
			INARR_0(6)<=INARR_0(5);			

			cu_reg_exchng<=INARR_0(3);

		---------------------------------------------------------------

    end if;
  end process CW_PIPE;
  -- ALU_OPCODE <= aluOpcode3;
  -- purpose: Generation of ALU OpCode
  -- type   : combinational
  -- inputs : IR_i
  -- outputs: aluOpcode
   ALU_OP_CODE_P : process (IR_opcode, IR_func,clock)
   begin  -- process ALU_OP_CODE_P
	if clock'event and clock = '1' then
			imm16_extend(15 downto 0)<=INARR_0(2)(15 downto 0);--ir_tmp(15 downto 0);
	 end if;
	end process ALU_OP_CODE_P;
end dlx_cu_hw;
