library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_textio.all;

library std;
use std.textio.all;
--CONTENT TYPE (0 code, 1 data) 
entity fetch is
  generic (
    CONTENT_TYPE : integer := 0;
    tco : time := 1 ns;
    tpd : time := 1 ns);    
  port (
    CLK      : in  std_logic;
    RSTn     : in  std_logic;
    MEM_RDY  : in std_logic;
    INST     : out std_logic_vector(31 downto 0)
	);
end entity fetch;

architecture beh of fetch is

    file fp0_inb : text open READ_MODE is "./main.bin";
    file fp1_inb : text open READ_MODE is "./data.bin";  

  impure function fetcher (
    constant CT : integer)
    return std_logic_vector is
    variable line_in : line;    
    variable value : std_logic_vector(31 downto 0) := (others => '0');
  begin  -- function fInit_offset
    case CT is
      when 0 =>
        if not endfile(fp0_inb) then
          readline(fp0_inb, line_in);
          hread(line_in, value);     
          
        end if;
      when 1 =>
        if not endfile(fp1_inb) then
          readline(fp1_inb, line_in);
          hread(line_in, value);          
        end if;                  
      when others => null;
    end case;
    return value;    
  end function fetcher;  

  type tState is (RST_S, IDLE_S, REQ_ON_S, WAIT_RDY_S, REQ_OFF_S);
  signal sState : tState;  
  
  signal sAddr : std_logic_vector(31 downto 0);
  
begin  -- architecture beh

  -----------------------------------------------------------------------------
  -- ADDR generation
  -----------------------------------------------------------------------------
  process (CLK, RSTn) is
  begin  -- process
    if RSTn = '0' then                  -- asynchronous reset (active low)
    elsif CLK'event and CLK = '1' then  -- rising clock edge

      if (MEM_RDY = '1') then
         sAddr <= fetcher(0);
        --sAddr <= fetcher(1);
        --sAddr <= sAddr after tco;
      end if;

    end if;
  end process;

  INST <= sAddr;


end architecture beh;
