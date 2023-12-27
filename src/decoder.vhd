library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use IEEE.math_real.all;
-- use ieee.numeric_std.all;
--use WORK.all;
--use work.constants.all;
--use work.constants.all;


entity decoder is
GENERIC (N_BIT: integer:= 32;   -- NBit_Regs 32;	
		 N_ADDR: integer:= 6); -- NBit_addr := 6;
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
end decoder;
architecture behavioral of decoder is
 
	component datapath is
	port(
	   data_path_reg:out std_logic_vector(31 downto 0);
	   reg_pc: in std_logic_vector(31 downto 0);
		func7 :in std_logic_vector(6 downto 0);
		func :in std_logic_vector(2 downto 0);

		reg_opcode :in std_logic_vector(6 downto 0);
		reg_ctr_byte:in std_logic_vector(14 downto 0);
		rf_alu_ctrl_bit: in std_logic;
		reg_imm20:in std_logic_vector(19 downto 0);

		data_in_port_w : in std_logic_vector(32-1 downto 0);
		data_out_port_a : OUT std_logic_vector(32-1 downto 0);
		data_out_port_b : OUT std_logic_vector(32-1 downto 0);
		address_port_a : in std_logic_vector(5-1 downto 0);

		address_port_b : in std_logic_vector(5-1 downto 0);
		address_port_w : in std_logic_vector(5-1 downto 0);
		r_signal_port_a : in std_logic;
		r_signal_port_b : in std_logic;

		w_signal :in std_logic;
		reset,clock: in std_logic;
		rf_en : in std_logic 
	);
	end component;

	-- suggested structures
	signal IR_T : std_logic_vector(31 downto 0); 	
	signal data_a : std_logic_vector(32-1 downto 0); 
	signal data_b : std_logic_vector(32-1 downto 0); 
	signal data_in_a : std_logic_vector(32-1 downto 0);-- 
	signal data_in_b : std_logic_vector(32-1 downto 0); 		
	signal wrt_a_add : std_logic_vector(31  downto 0); 
	signal wrt_b_add : std_logic_vector(31  downto 0); 
	subtype REG_ADDR is natural range 0 to ((2**N_ADDR)-1); -- using natural type. We have 32 registers in Register File
	type REG_ARRAY is array(REG_ADDR) of std_logic_vector(N_BIT-1 downto 0); -- Each register is of ?? bits
	signal REGISTERS : REG_ARRAY; 
  signal Clock: std_logic;
  signal reset_0:std_logic;	
  signal testbit:std_logic:='0'; 
  SIGNAL rf_a_out:std_logic_vector(31  downto 0); 
  SIGNAL rf_b_out:std_logic_vector(31  downto 0);   
  signal rdadd_a:std_logic_vector(31  downto 0); 
  signal rdadd_b:std_logic_vector(31  downto 0);   
  signal data_wb:std_logic_vector(31  downto 0);  
  signal d_a_tmp:std_logic_vector(31  downto 0);  
  signal d_b_tmp:std_logic_vector(31  downto 0); 
  signal alutmp:std_logic_vector(3  downto 0):="0000";   
  
 	signal	reg_feed_back:std_logic_vector(31  downto 0);  
	signal	mem_out:std_logic_vector(31  downto 0);  
	signal	mem_rd_add:std_logic_vector(31  downto 0);  
	signal	mem_wr_add:std_logic_vector(31  downto 0);  
	signal   rf_0_wrt_en:std_logic;
	signal   rf_0_rd_en:std_logic;

	signal opcode  :  std_logic_vector(5 downto 0);
	signal func    :  std_logic_vector(10 downto 0);
	signal imm16_extend    :  std_logic_vector(31 downto 0);
	signal IR_RS :  std_logic_vector(4 downto 0);--
	signal IR_RD : std_logic_vector(4 downto 0);--
	signal IR_RS1: std_logic_vector(4 downto 0);--
	signal IR_RS2: std_logic_vector(4 downto 0);--
	signal IR_RD2:   std_logic_vector(4 downto 0);--
	signal	RF_AD1: std_logic;--
	signal	RF_RD2: std_logic;
	signal	RF_WR: std_logic;
	signal	rf_wbk:std_logic_vector(31  downto 0);  

begin 
rf_A_B : datapath 
	Port Map (--
	path_bk_dec,
	pc_dec,
	dec_funcode7,
	dec_funcode,

	dec_opcode,
	ctrl_byte,
	dec_alu_ctrl_bit,
	imm20_dec,

	data_wb,--rf_wbk,
	rf_a_out,--alu_out,--
	rf_b_out,
	ADD_RD1,--IR_T(25 downto 21),

	ADD_RD2,-- IR_T(20 downto 16),
	ADD_WR,--IR_T(25 downto 21),
	RF_AD1,--RD1,
	RF_RD2,--RD2,
	
	RF_WR,
	reset_0,
	clock,
	enable
);
	
	reset_0<=reset;
	clock<=CLK;
	IR_T<=Istrct_f;

	opcode       <=istrct_f(31 downto 26 );--: in std_logic_vector(5 downto 0);
	func         <=istrct_f(10 downto 0);--: in std_logic_vector(10 downto 0);
--	decode_IMM16 <=istrct_f(31 downto 0);--   : in std_logic_vector(31 downto 0);
	IR_RS        <=istrct_f(25 downto 21 );--: in std_logic_vector(4 downto 0);-
	IR_RD        <=istrct_f(20 downto 16);--:in std_logic_vector(4 downto 0);--
	IR_RS1       <=istrct_f(25 downto 21);--:in std_logic_vector(4 downto 0);--
	IR_RS2       <=istrct_f(20 downto 16);--:in std_logic_vector(4 downto 0);--
	IR_RD2       <=istrct_f(15 downto 11);--:  in std_logic_vector(4 downto 0);
	
	RF_AD1<=RD1;--
	RF_RD2<=RD2;
	RF_WR<=WR;
	alu_out     <=rf_a_out;--
	decode_out_b<=rf_b_out;
	--data_a<=out1;
RF_process: process(clock) is
begin
	if (clock='1' and clock'event) then 
		if (reset_0 = '1') then
			--registers <= (others=>(others=>'0'));
			--data_in_a<=Istrct_f;
		d_a_tmp<= (others =>'0');			
		d_b_tmp<= (others =>'0');
		
		else
		--alutmp;--<="0000";
		end if;--end reset
	end if;--end clk
end process;

end behavioral;



