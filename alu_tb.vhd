--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   15:32:07 11/14/2021
-- Design Name:   
-- Module Name:   /home/ise/CALC_FINAL/alu_tb.vhd
-- Project Name:  CALC_FINAL
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: alu
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY alu_tb IS
END alu_tb;
 
ARCHITECTURE behavior OF alu_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT alu
    PORT(
         A : IN  std_logic_vector(7 downto 0);
         B : IN  std_logic_vector(7 downto 0);
         OP_SEL : IN  std_logic_vector(3 downto 0);
         CLK : IN  std_logic;
         enable : IN  std_logic;
         ready : OUT  std_logic;
         O : OUT  std_logic_vector(15 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal A : std_logic_vector(7 downto 0) := (others => '0');
   signal B : std_logic_vector(7 downto 0) := (others => '0');
   signal OP_SEL : std_logic_vector(3 downto 0) := (others => '0');
   signal CLK : std_logic := '0';
   signal enable : std_logic := '0';

 	--Outputs
   signal ready : std_logic;
   signal O : std_logic_vector(15 downto 0);

   -- Clock period definitions
   constant CLK_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: alu PORT MAP (
          A => A,
          B => B,
          OP_SEL => OP_SEL,
          CLK => CLK,
          enable => enable,
          ready => ready,
          O => O
        );

   -- Clock process definitions
   CLK_process :process
   begin
		CLK <= '0';
		wait for CLK_period/2;
		CLK <= '1';
		wait for CLK_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;
		
	   enable <= '1';
		OP_SEL <= "0000";
		A <= "00000010"; -- 2
		B <= "00010001"; -- 17
		wait for CLK_period; -- Result should be A+B -> 19 = 0001 0011
		
		enable <= '0';
		wait for CLK_period;
		
		enable <= '1';
		OP_SEL <= "0001";
		A <= "00000010"; -- 2
		B <= "00010001"; -- 17
		wait for CLK_period; -- Result should be A-B -> -15 = 1111 0001
		
		enable <= '0';
		wait for CLK_period;
		
		enable <= '1';
		OP_SEL <= "0010";
		A <= "00000100"; -- 4
		B <= "00000100"; -- 4
		wait for CLK_period; -- Result should be A*B -> 16 = 0001 0000
		
		enable <= '0';
		wait for CLK_period;
		
		enable <= '1';
		OP_SEL <= "0011";
		A <= "00000010"; -- 2
		B <= "00010001"; -- 17
		wait for CLK_period; -- Result should be -A -> -2 = 1111 1110
		
		enable <= '0';
		wait for CLK_period;
		
		enable <= '1';
		OP_SEL <= "0100";
		A <= "00000010"; -- 2
		B <= "00010001"; -- 17
		wait for CLK_period; -- Result should be A*A -> 4 = 0000 0100
		
		enable <= '0';
		wait for CLK_period;
		
		enable <= '1';
		OP_SEL <= "0101";
		A <= "00010000"; -- 16
		B <= "00010001"; -- 17
		wait for CLK_period; -- Result should be 2 * A -> 32 = 0010 0000
		
		enable <= '0';
		wait for CLK_period;
		
		enable <= '1';
		OP_SEL <= "0110";
		A <= "00000010";
		B <= "00010011";
		wait for CLK_period; -- Result should be A AND B -> 0000 0010
		
		enable <= '0';
		wait for CLK_period;
		
		enable <= '1';
		OP_SEL <= "0111";
		A <= "00000010"; -- 2
		B <= "00010001"; -- 17
		wait for CLK_period; -- Result should be A OR B -> 0001 0011
		
		enable <= '0';
		wait for CLK_period;
		
		enable <= '1';
		OP_SEL <= "1000";
		A <= "00000011";
		B <= "00010011";
		wait for CLK_period; -- Result should be A NAND B -> 1111 1100
		
		enable <= '0';
		wait for CLK_period;
		
		enable <= '1';
		OP_SEL <= "1001";
		A <= "00000010";
		B <= "00010001"; 
		wait for CLK_period; -- Result should be A NOR B -> 1110 1100
		
		enable <= '0';
		wait for CLK_period;
		
		enable <= '1';
		OP_SEL <= "1010";
		A <= "00000011";
		B <= "00010001"; 
		wait for CLK_period; -- Result should be A XOR B -> 0001 0010
		
		enable <= '0';
		wait for CLK_period;
		
		enable <= '1';
		OP_SEL <= "1011";
		A <= "00000011";
		B <= "00010001"; 
		wait for CLK_period; -- Result should be A++ -> 0000 0100
		
		enable <= '0';
		wait for CLK_period;
		
		enable <= '1';
		OP_SEL <= "1100";
		A <= "00000011";
		B <= "00010001"; 
		wait for CLK_period; -- Result should be A-- -> 0000 0010
		
		enable <= '0';
		wait for CLK_period;
		
		enable <= '1';
		OP_SEL <= "1101";
		A <= "00000011";
		B <= "00010001"; 
		wait for CLK_period; -- Result should be LSLA-- -> 0000 0110
		
		enable <= '0';
		wait for CLK_period;
		
		enable <= '1';
		OP_SEL <= "1110";
		A <= "00000011";
		B <= "00010001"; 
		wait for CLK_period; -- Result should be LSRA-- -> 0000 0001
		
		enable <= '0';
		wait for CLK_period;
		
		enable <= '1';
		OP_SEL <= "1111";
		A <= "00000011";
		B <= "00010001"; 
		wait for CLK_period; -- Result should be ASRA-- -> 0000 0001
		
		enable <= '0';
		wait for CLK_period;
		
		enable <= '1';
		OP_SEL <= "1111";
		A <= "10000011";
		B <= "00010001"; 
		wait for CLK_period; -- Result should be ASRA-- -> 1100 0001
		
		enable <= '0';
		wait for CLK_period;
		
		enable <= '1';
		OP_SEL <= "0000";
		A <= "11111010";
		B <= "11111010"; 
		wait for CLK_period; -- Result should be -6 + -6 = -12 = 1111 1111 1111 0100
		
		enable <= '0';
		wait for CLK_period;
		
		enable <= '1';
		OP_SEL <= "0010";
		A <= "10000000";
		B <= "01111111"; 
		wait for CLK_period; -- Result should be 1100000010000000
		
		enable <= '0';
		wait for CLK_period;

      wait for CLK_period*10;

      -- insert stimulus here 

      wait;
   end process;

END;
