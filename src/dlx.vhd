library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use work.myTypes.all;

entity dlx is
  port (
		stg1:buffer std_logic_vector(1 downto 0);
		stg2:buffer std_logic_vector(2 downto 0);
		stg3:buffer std_logic_vector(3 downto 0);
		stg4:buffer std_logic_vector(3 downto 0);
		stg5:buffer std_logic_vector(1 downto 0);    
		dlx_a_tb: buffer std_logic_vector(31 downto 0);
		dlx_b_tb: buffer std_logic_vector(31 downto 0);
		Clk : in std_logic;
		Rst : in std_logic;
		opcd:out std_logic_vector(5 downto 0);
		instruct:out std_logic_vector(31 downto 0);
		output:out std_logic_vector(31 downto 0) ;

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
	 );                -- Active Low
end dlx;
-- This architecture is currently not complete
-- it just includes:
-- instruction register (complete)
-- program counter (complete)
-- instruction ram memory (complete)
-- control unit (UNCOMPLETE)
architecture dlx_rtl of dlx is
 --------------------------------------------------------------------
 -- Components Declaration
 component fetch 
 port (
  CLK      : in  std_logic;
  RSTn     : in  std_logic;
  MEM_RDY  : in std_logic;
  INST     : out std_logic_vector(31 downto 0)
 );
end component;
 component req_gen 
 port(
  CLK :in std_logic;
  RSTn  :in std_logic;
  PROC_REQ  :out std_logic;
  MEM_RDY  :in std_logic;
  WE :out std_logic;
  ADDR  : out std_logic_vector(31 downto 0);
  WDATA  : out std_logic_vector(31 downto 0)
    );      
  end component;
  component BTB
  port(
  instr_in :in  std_logic_vector(32 - 1 downto 0);
  brc_add : in  std_logic_vector(32 - 1 downto 0);
  tag_pc : in  std_logic_vector(32 - 1 downto 0);
  rst :in std_logic; 
  take:out std_logic
  );--(instr_in,brc_add,tag_pc,rst);
  end component;
 --------------------------------------------------------------------
  --Instruction Ram
  component IRAM
--     generic (
--       RAM_DEPTH : integer;
--       I_SIZE    : integer);
    port (
      Rst  : in  std_logic;
      Addr : in  std_logic_vector(32 - 1 downto 0);
      Dout : out std_logic_vector(32 - 1 downto 0)
      );
  end component;
  -- Data Ram (MISSING!You must include it in your final project!)

  -- Datapath (MISSING!You must include it in your final project!)
  
  -- Control Unit
  component dlx_cu
  generic (
    MICROCODE_MEM_SIZE :     integer := 10;  -- Microcode Memory Size
    FUNC_SIZE          :     integer := 11;  -- Func Field Size for R-Type Ops
    OP_CODE_SIZE       :     integer := 6;  -- Op Code Size
    --ALU_O32       :     integer := 6;  -- ALU Op Code Word Size  
    CW_SIZE            :     integer := 15);  -- Control Word Size
  port (
  	 pc_dlx				  :in std_logic_vector(31 downto 0);
    Clk                : in  std_logic;  -- Clock
    Rst                : in  std_logic;  -- Reset:Active-Low
    -- Instruction Register
    IR_IN              : in  std_logic_vector(32 - 1 downto 0);
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
    ALU_OPCODE         : out std_logic_vector(OP_CODE_SIZE - 1 downto 0); -- choose between implicit or exlicit coding, like std_logic_vector(ALU_O32 -1 downto 0);   
    -- MEM Control Signals
    DRAM_WE            : buffer std_logic;  -- Data RAM Write Enable
    LMD_LATCH_EN       : buffer std_logic;  -- LMD Register Latch Enable
    JUMP_EN            : buffer std_logic;  -- JUMP Enable Signal for PC input MUX
    PC_LATCH_EN        : buffer std_logic;  -- Program Counte Latch Enable
    -- WB Control signals
    WB_MUX_SEL         : buffer std_logic;  -- Write Back MUX Sel
    RF_WE              : buffer std_logic;
	 --out
	cu_out_a    : out std_logic_vector(32-1 downto 0);
	cu_out_b    : out std_logic_vector(32-1 downto 0); 
	alu_out_cu	:out std_logic_vector(31 downto 0);
	
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

  end component;


  ----------------------------------------------------------------
  -- Signals Declaration
  ----------------------------------------------------------------
  
  -- Instruction Register (IR) and Program Counter (PC) declaration
  signal IR : std_logic_vector(32 - 1 downto 0);
  signal PC : std_logic_vector(32 - 1 downto 0);
  signal clkcnt : std_logic_vector(32 - 1 downto 0);
  -- Instruction Ram Bus signals
  signal IRam_DOut : std_logic_vector(32 - 1 downto 0);

  -- Datapath Bus signals
  signal PC_BUS : std_logic_vector(32 -1 downto 0);

  -- Control Unit Bus signals
  signal IR_LATCH_EN_i : std_logic;
  signal NPC_LATCH_EN_i : std_logic;
  signal RegA_LATCH_EN_i : std_logic;
  signal RegB_LATCH_EN_i : std_logic;
  signal RegIMM_LATCH_EN_i : std_logic;
  signal EQ_COND_i : std_logic;
  signal JUMP_EN_i : std_logic;
  signal ALU_OPCODE_i : std_logic_vector(OP_CODE_SIZE - 1 downto 0);--aluOp;
  signal MUXA_SEL_i : std_logic;
  signal MUXB_SEL_i : std_logic;
  signal ALU_OUTREG_EN_i : std_logic;
  signal DRAM_WE_i : std_logic;
  signal LMD_LATCH_EN_i : std_logic;
  signal PC_LATCH_EN_i : std_logic;
  signal WB_MUX_SEL_i : std_logic;
  signal RF_WE_i : std_logic;

  signal test : std_logic_vector(31 downto 0);
   signal dlx_a_tmp: std_logic_vector(31 downto 0);
  signal dlx_b_tmp: std_logic_vector(31 downto 0);  
  signal pc_cu: std_logic_vector(31 downto 0);    
  signal pc_tmp: std_logic_vector(31 downto 0);    
  signal take_glb :std_logic;
  -- Data Ram Bus signals
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

   signal PROC_REQ :  std_logic;
   signal MEM_RDY  :  std_logic;
   signal WE       :  std_logic;
   signal WDATA    :  std_logic_vector(31 downto 0);
  begin  -- DLX
    PC_BUS <= (others => '0'); 

    IR_P: process (Clk, Rst)
    begin  -- process IR_P
      if Rst = '1' then                 -- asynchronous reset (active low)
		IR <= (others => '0');

		pc_cu <= (others => '0');
		pc_tmp<=(others =>'0');
      elsif Clk'event and Clk = '1' then  -- rising clock edge

				instruct<=IRam_DOut;

				pc_tmp<=pc_tmp+x"0001";
				--pc + 4 is skipping the decode, exe, mem access, write back 
				if take_glb='1' then --BTB is taken
				    pc_tmp<=pc_tmp+x"0004";
					pc<=pc_tmp;
					pc_cu<=pc_tmp;	
			    else 					
					pc<=pc_tmp;
					pc_cu<=pc_tmp;
				end if;
				if JUMP_EN_i='1'then
					pc    <=dlx_b_tmp;--test;--unconditional jump 
					pc_tmp<=dlx_b_tmp;--test;
				end if;
				output<=test;
		  --end if; 
      end if;
    end process IR_P;
    -- purpose: Program Counter Process
    -- type   : sequential
    -- inputs : Clk, Rst, PC_BUS
    -- outputs: IRam_Addr
    PC_P: process (Clk, Rst)
    begin  -- process PC_P
      if Rst = '1' then                 -- asynchronous reset (active low)
      elsif Clk'event and Clk = '1' then  -- rising clock edge
							
							  if (PC_LATCH_EN_i = '1') then

							  end if;
      end if;
    end process PC_P;

   btb0: BTB
  port map(
  instr_in =>  IR,
  brc_add  =>  IR,
  tag_pc   =>  IR,
  rst =>Rst ,
  take=>take_glb
  );--(instr_in,brc_add,tag_pc,rst);
  
    -- Control Unit Instantiation
    CU_I: dlx_cu
      port map (
			 pc_cu,--PC,
          Clk             => Clk,
          Rst             => Rst,
          IR_IN           => IR,
          IR_LATCH_EN     => IR_LATCH_EN_i,
          NPC_LATCH_EN    => take_glb , --NPC_LATCH_EN_i,
          RegA_LATCH_EN   => RegA_LATCH_EN_i,
          RegB_LATCH_EN   => RegB_LATCH_EN_i,
          RegIMM_LATCH_EN => RegIMM_LATCH_EN_i,
          MUXA_SEL        => MUXA_SEL_i,
          MUXB_SEL        => MUXB_SEL_i,
          ALU_OUTREG_EN   => ALU_OUTREG_EN_i,
          EQ_COND         => EQ_COND_i,
			 
          ALU_OPCODE      => 	 opcd,--ALU_OPCODE_i,
          DRAM_WE         => DRAM_WE_i,
          LMD_LATCH_EN    => LMD_LATCH_EN_i,
          JUMP_EN         => JUMP_EN_i,
          PC_LATCH_EN     => PC_LATCH_EN_i,
          WB_MUX_SEL      => WB_MUX_SEL_i,
          RF_WE           => RF_WE_i,
			 --
			cu_out_a=>dlx_a_tmp,
			cu_out_b=>dlx_b_tmp,
			alu_out_cu=>test,
			--
				tag_flr2rsm           =>tag_flr2rsm,
				tag_rsm2flr           =>tag_rsm2flr,
				tag_flr2rsa           =>tag_flr2rsa,
				tag_rsa2flr           =>tag_rsa2flr,
				id_dest_flr2rs        =>id_dest_flr2rs,
				id_dest_rsa2flr       =>id_dest_rsa2flr,
				id_dest_rsm2flr       =>id_dest_rsm2flr,
				flr_data1		=>flr_data1,			 
				flr_data2		=>flr_data2,			 
				data_dest_m		=>data_dest_m,				 
				data_dest_a           =>data_dest_a 		

			 );

    fetch0: fetch
    port map(
      Clk ,
       Rst, 
       MEM_RDY, 
       IR 
    );

        req_gen0: req_gen
        port map(
          Clk ,
           Rst,
           PROC_REQ, 
           MEM_RDY, 
           WE,
           IRam_DOut ,
          PC
        );   
        MEM_RDY<='1';
			stg1<=dlx_a_tb(14 downto 13);
			stg2<=dlx_a_tb(12 downto 10);
			stg3<=dlx_a_tb(9 downto 6);
			stg4<=dlx_a_tb(5 downto 2);
			stg5<=dlx_a_tb(1 downto 0);
			dlx_a_tb<=dlx_a_tmp;
			dlx_b_tb<=dlx_b_tmp;	
	 
end dlx_rtl;
