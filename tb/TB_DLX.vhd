library IEEE;

use IEEE.std_logic_1164.all;
use WORK.all;

entity tb_dlx is
end tb_dlx;

architecture TEST of tb_dlx is


    constant SIZE_IR      : integer := 32;       -- Instruction Register Size
    constant SIZE_PC      : integer := 32;       -- Program Counter Size
    constant SIZE_ALU_OPC : integer := 6;        -- ALU Op Code Word Size in case explicit coding is used
	
	signal Clock: std_logic := '0';
	signal Reset: std_logic := '1';
	signal opcd_tb:  std_logic_vector(5 downto 0);
	signal instruct:  std_logic_vector(31 downto 0);	 
	signal alutest:  std_logic_vector(31 downto 0);	 
	signal dlx_a_tbs:  std_logic_vector(31 downto 0);		 
	signal dlx_b_tbs:  std_logic_vector(31 downto 0);
	signal cw1 : std_logic_vector(1 downto 0);      -- first stage  15=15
	signal cw2 : std_logic_vector(2 downto 0); -- second stage 15=15
	signal cw3 : std_logic_vector(3 downto 0); -- third stage  15=15
	signal cw4 : std_logic_vector(3 downto 0); -- fourth stage  15=15
	signal cw5 : std_logic_vector(1 downto 0); -- fifth stage  15=15	 
  
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
  
    component DLX 	   -- ALU_OPC_SIZE is explicit ALU Op Code Word Size
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
			output:out std_logic_vector(31 downto 0);
			
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
    end component;
begin
        -- instance of DLX
	U1: DLX
	Port Map (
	cw1 ,
	cw2 ,
	cw3 ,
	cw4 ,
	cw5 ,
	dlx_a_tbs,
	dlx_b_tbs,
	Clock, 
	Reset,
	opcd_tb,
	instruct,
	alutest,
	 ltag_flr2rsm,
	 ltag_rsm2flr,
	 ltag_flr2rsa,
	 ltag_rsa2flr,
	 lid_dest_flr2rs,
	 lid_dest_rsa2flr,
	 lid_dest_rsm2flr,
	 lflr_data1,			 
	 lflr_data2,			 
	 ldata_dest_m,				 
	 ldata_dest_a 	
	);	
PCLOCK : process(Clock)
	begin
		Clock <= not(Clock) after 0.5 ns;	
	end process;	
	Reset <= 
	'1' after 1 ns,
	'0' after 2 ns;    	
	
   
end TEST;
-------------------------------
configuration CFG_TB of tb_dlx  is
	for TEST
	end for;
end CFG_TB;

