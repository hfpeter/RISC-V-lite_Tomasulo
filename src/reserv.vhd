library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;



entity resev is
port(
busy in std_logic;
op   in std_logic_vector(31 downto 0);
vj	 in std_logic_vector(31 downto 0);
vk   in std_logic_vector(31 downto 0);
qj	 in std_logic_vector(31 downto 0);
qk   in std_logic_vector(31 downto 0);
a    in std_logic_vector(31 downto 0)
);
architecture behave of resev is
	type regFile is array(0 to 31) of std_logic_vector(31 downto 0);
begin

end behave;











