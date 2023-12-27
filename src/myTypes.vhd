library ieee;
use ieee.std_logic_1164.all;

package myTypes is

-- Control unit input sizes
    constant OP_CODE_SIZE : integer :=  6;                                              -- OPCODE field size
    constant FUNC_SIZE    : integer :=  11;                                             -- FUNC field size
    --constant aluOp   : integer :=  6;   
-- R-Type instruction -> FUNC field     FUNC_SIZE=11
	constant RTYPE_ADD : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000000000";    -- ADD RS1,RS2,RD
	constant RTYPE_SUB : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000000001";    -- SUB RS1,RS2,RD
	constant RTYPE_AND : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000000010";    -- AND RS1,RS2,RD
	constant RTYPE_OR : std_logic_vector(FUNC_SIZE - 1 downto 0) :=   "00000000011";    -- OR RS1,RS2,RD
	--constant NOP : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "11111111100";          -- NOP
	constant NOP : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000000000";

-- R-Type instruction -> OPCODE field
    constant RTYPE : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "000000";          -- for ADD, SUB, AND, OR register-to-register operation

-- I-Type instruction -> OPCODE field      
	constant ITYPE_ADDI1 : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "000001";    -- ADDI1 RS1,RD,INP1
	constant ITYPE_SUBI1 : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "000010";    -- SUBI1 RS1,RD,INP1
	constant ITYPE_ANDI1 : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "000011";    -- ANDI1 RS1,RD,INP1
	constant ITYPE_ORI1  : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "000100";    -- ORI1 RS1,RD,INP1
	constant ITYPE_ADDI2 : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "000101";    -- ADDI2 RS1,RD,INP1
	constant ITYPE_SUBI2 : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "000110";    -- SUBI2 RS1,RD,INP2
	constant ITYPE_ANDI2 : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "000111";    -- ANDI2 RS1,RD,INP1
	constant ITYPE_ORI2  : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "001000";    -- ORI2 RS1,RD,INP1
	constant ITYPE_MOV   : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "001001";    -- MOV RS1,RD
	constant ITYPE_S_REG1 : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "001010";    -- S_REG1 R2,INP1
	constant ITYPE_S_REG2 : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "001011";    -- S_REG2 R2,INP2
	constant ITYPE_S_MEM2 : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "001100";    -- S_MEM2 R1,R2,INP2
	constant ITYPE_L_MEM1 : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "001101";    -- L_MEM1 R1,R2,INP1
	constant ITYPE_L_MEM2 : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "001110";    -- L_MEM2 R1,R2,INP2
    
-- Change the values of the instructions coding as you want, depending also on the type of control unit choosen

end myTypes;

