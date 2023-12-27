library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
--use ieee.numeric_std.all; 
use WORK.constants.all;
entity datapath is
	port(
		data_path_reg:out std_logic_vector(31 downto 0);
		reg_pc: in std_logic_vector(31 downto 0);
		func7 : in std_logic_vector(6 downto 0);
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
		reset,
		clock: in std_logic;
		rf_en : in std_logic 
	);

end datapath;

architecture Behavioral of datapath is
	type regFile is array(0 to 31) of std_logic_vector(31 downto 0);
	signal registers : regFile;
	type mem is array(0 to 4095) of std_logic_vector(31 downto 0);
	signal memory : mem;	
	signal add_wb_locol :std_logic_vector(5-1 downto 0);
	signal rf_wbk:std_logic_vector(31 downto 0);
	signal rf_a:std_logic_vector(31 downto 0);
	signal rf_b:std_logic_vector(31 downto 0);
	signal pc_tmp:std_logic_vector(31 downto 0);	
	signal add_32:std_logic_vector(31 downto 0);	
	signal path_tmp:std_logic_vector(31 downto 0);	
	signal sll_tmp :std_logic_vector(5 downto 0);	
	signal sll_tmp2 : integer range 0 to 31;
	signal add_tmp :std_logic_vector(5-1 downto 0);	
	signal add_b_tmp :std_logic_vector(5-1 downto 0);		
	signal jm_indx :std_logic_vector(31 downto 0);	
begin
	
regFileProcess : process  (clock) is
	 variable sll_tmp3 : integer range 0 to 31;
	 begin
if(clock = '1' and clock'event)then
	if(reset = '1')then
		registers <= (others =>(others =>'0'));
		rf_wbk<= (others =>'0');
		add_wb_locol<= (others =>'0');
		pc_tmp<=(others =>'0');
		memory <= (others =>(others =>'0'));
		add_32<= (others =>'0');
		add_tmp<= (others =>'0');
		add_b_tmp<= (others =>'0');	
		path_tmp	<= (others =>'0');		
		sll_tmp2<= 0;	
		data_path_reg<= (others =>'0');		
		jm_indx<= (others =>'0');		
	else
--------------------------------------------------------------------
--data_out_port_a<=sll_tmp2;
--data_path_reg(0)<='0';
case reg_opcode is
when "0000011"	=>
	case conv_integer(unsigned(func)) is
			when 0 => --lb		  
			when 1 => -- lh
			when 2 => --lw
			when 3 =>
			when 4 =>
			when 5 =>--
			when 6 => --
			when others =>
				end case;
when "0001111" 	=>	
when "0010011" 	=>	
	case conv_integer(unsigned(func)) is
		when 0 =>--addi
		data_out_port_b<=data_out_port_a + data_path_reg(31 downto 20);
		when 1 => 
		when 2 =>
		when 3 =>
		when 4 =>
		when 5 =>--
		when 6 => --
		when 7 => 
			when others =>
			end case;
when "0010111" 	=>--auipc Load absolute address
data_out_port_b(31 downto 12)<=reg_imm20;
data_out_port_b(12 downto 0)<=(others =>'0');
when "0011011" 	=>	
	case conv_integer(unsigned(func)) is
		when 0 =>--addiw
				case conv_integer(unsigned(func7)) is
					when 0 =>--add
					when others =>
				end case;
		when 1 => --slliw
		when 5 =>--srliw
		when others =>
			end case;
when "1101111" 	=>	--jal
when "0110111" =>--lui
when"0100011" =>
	case conv_integer(unsigned(func)) is
		when  2=>--sw
	when others =>		
	end case;
when"1100111" =>
		case conv_integer(unsigned(func)) is
		when  0=>--jalr
		when others =>
		end case;
when"1100011" =>
		case conv_integer(unsigned(func)) is
			when  5=>--bge
			when  6=>--bltu
			when others =>
		  end case;
when "0110011" 	=>	
			case conv_integer(unsigned(func)) is
				when 0 =>
						case conv_integer(unsigned(func7)) is
							when 0100000 =>--sub
							when others =>
						end case;
						when others =>
					end case;
when others =>
	end case; 

			if reg_ctr_byte(7)='1' then--ALU_OUT addi
				registers(conv_integer(unsigned(add_wb_locol))) <= rf_wbk;--wb_buff(2);--rf_wbk;
				data_out_port_a <= rf_wbk;
			end if;
			if reg_ctr_byte(6)='1' then-- sw
				memory(conv_integer(unsigned(add_32))) <= rf_wbk;--wb_buff(2);--rf_wbk;
			end if;		
			if reg_ctr_byte(5)='1' then-- lw use the 5 bit
					registers(conv_integer(unsigned(address_port_b)))<=memory(conv_integer(unsigned(add_32)));
					data_out_port_b <=memory(conv_integer(unsigned(add_32)));				
			end if;				
			if reg_ctr_byte(0)='1' then--shift left use wrb--jal shouldn't access here if
				registers(conv_integer(unsigned(add_wb_locol))) <= rf_wbk;--wb_buff(2);--rf_wbk;
				data_out_port_a <= rf_wbk;
			end if;						
		end if;
    end if; --clock if
 end process;

end Behavioral;


