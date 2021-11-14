--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   15:33:43 11/14/2021
-- Design Name:   
-- Module Name:   /home/ise/CALC_FINAL/bcd_seg7_tb.vhd
-- Project Name:  CALC_FINAL
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: bcd_seg7
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
 
ENTITY bcd_seg7_tb IS
END bcd_seg7_tb;
 
ARCHITECTURE behavior OF bcd_seg7_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT bcd_seg7
    PORT(
         bcd : IN  std_logic_vector(3 downto 0);
         enable : IN  std_logic;
         clk : IN  std_logic;
         is_neg_in : IN  std_logic;
         is_neg_out : OUT  std_logic;
         seg7_out : OUT  std_logic_vector(6 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal bcd : std_logic_vector(3 downto 0) := (others => '0');
   signal enable : std_logic := '0';
   signal clk : std_logic := '0';
   signal is_neg_in : std_logic := '0';

 	--Outputs
   signal is_neg_out : std_logic;
   signal seg7_out : std_logic_vector(6 downto 0);

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: bcd_seg7 PORT MAP (
          bcd => bcd,
          enable => enable,
          clk => clk,
          is_neg_in => is_neg_in,
          is_neg_out => is_neg_out,
          seg7_out => seg7_out
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;

		enable<='1';
		bcd <= "0000";
		wait for clk_period;
		enable<='0';
		wait for clk_period;
		
		enable<='1';
		bcd <= "0001";
		wait for clk_period;
		enable<='0';
		wait for clk_period;
		
		enable<='1';
		bcd <= "0010";
		wait for clk_period;
		enable<='0';
		wait for clk_period;
		
		enable<='1';
		bcd <= "0011";
		wait for clk_period;
		enable<='0';
		wait for clk_period;
		
		enable<='1';
		bcd <= "0100";
		wait for clk_period;
		enable<='0';
		wait for clk_period;
		
		enable<='1';
		bcd <= "0101";
		wait for clk_period;
		enable<='0';
		wait for clk_period;
		
		enable<='1';
		bcd <= "0110";
		wait for clk_period;
		enable<='0';
		wait for clk_period;
		
		enable<='1';
		bcd <= "0111";
		wait for clk_period;
		enable<='0';
		wait for clk_period;
		
		enable<='1';
		bcd <= "1000";
		wait for clk_period;
		enable<='0';
		wait for clk_period;
		
		enable<='1';
		bcd <= "1001";
		wait for clk_period;
		enable<='0';
		wait for clk_period;

      wait for clk_period*10;

      -- insert stimulus here 

      wait;
   end process;

END;
