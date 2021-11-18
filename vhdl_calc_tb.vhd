--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   17:11:37 11/14/2021
-- Design Name:   
-- Module Name:   /home/ise/CALC_FINAL/vhdl_calc_tb.vhd
-- Project Name:  CALC_FINAL
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: vhdl_calc
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
 
ENTITY vhdl_calc_tb IS
END vhdl_calc_tb;
 
ARCHITECTURE behavior OF vhdl_calc_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT vhdl_calc
    PORT(
         A : IN  std_logic_vector(7 downto 0);
         B : IN  std_logic_vector(7 downto 0);
         OP_SEL : IN  std_logic_vector(3 downto 0);
         CLK : IN  std_logic;
         ENABLE : IN  std_logic;
         IS_NEG : OUT  std_logic;
         SEG7_4 : OUT  std_logic_vector(6 downto 0);
         SEG7_3 : OUT  std_logic_vector(6 downto 0);
         SEG7_2 : OUT  std_logic_vector(6 downto 0);
         SEG7_1 : OUT  std_logic_vector(6 downto 0);
         SEG7_0 : OUT  std_logic_vector(6 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal A : std_logic_vector(7 downto 0) := (others => '0');
   signal B : std_logic_vector(7 downto 0) := (others => '0');
   signal OP_SEL : std_logic_vector(3 downto 0) := (others => '0');
   signal CLK : std_logic := '0';
   signal ENABLE : std_logic := '0';

 	--Outputs
   signal IS_NEG : std_logic;
   signal SEG7_4 : std_logic_vector(6 downto 0);
   signal SEG7_3 : std_logic_vector(6 downto 0);
   signal SEG7_2 : std_logic_vector(6 downto 0);
   signal SEG7_1 : std_logic_vector(6 downto 0);
   signal SEG7_0 : std_logic_vector(6 downto 0);

   -- Clock period definitions
   constant CLK_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: vhdl_calc PORT MAP (
          A => A,
          B => B,
          OP_SEL => OP_SEL,
          CLK => CLK,
          ENABLE => ENABLE,
          IS_NEG => IS_NEG,
          SEG7_4 => SEG7_4,
          SEG7_3 => SEG7_3,
          SEG7_2 => SEG7_2,
          SEG7_1 => SEG7_1,
          SEG7_0 => SEG7_0
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

		ENABLE <= '1';
		OP_SEL <= "0000";
		A <= "00001111";
		B<= "00001111"; -- 15 + 15 = 30 = 0001 1110
		wait for CLK_period;
		ENABLE <= '0';
		wait for 225 ns;
		
		
		ENABLE <= '1';
		OP_SEL <= "0011";
		A <= "10000000";
		B<= "01111111"; -- -128 * -1 = 128
		wait for CLK_period;
		ENABLE <= '0';
		wait for 225 ns;
		
		
		ENABLE <= '1';
		OP_SEL <= "0010";
		A <= "10000000";
		B<= "01111111"; -- -128 * 127 = -16256 = 1100000010000000
		wait for CLK_period;
		ENABLE <= '0';
		wait for 225 ns;
		
		
		

      wait for CLK_period*10;

      -- insert stimulus here 

      wait;
   end process;

END;
