--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   15:32:50 11/14/2021
-- Design Name:   
-- Module Name:   /home/ise/CALC_FINAL/binary_bcd_tb.vhd
-- Project Name:  CALC_FINAL
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: binary_bcd
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
 
ENTITY binary_bcd_tb IS
END binary_bcd_tb;
 
ARCHITECTURE behavior OF binary_bcd_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT binary_bcd
    PORT(
         clk : IN  std_logic;
         reset : IN  std_logic;
         binary_in : IN  std_logic_vector(15 downto 0);
         bcd0 : OUT  std_logic_vector(3 downto 0);
         bcd1 : OUT  std_logic_vector(3 downto 0);
         bcd2 : OUT  std_logic_vector(3 downto 0);
         bcd3 : OUT  std_logic_vector(3 downto 0);
         bcd4 : OUT  std_logic_vector(3 downto 0);
         is_neg : OUT  std_logic;
         ready : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal reset : std_logic := '0';
   signal binary_in : std_logic_vector(15 downto 0) := (others => '0');

 	--Outputs
   signal bcd0 : std_logic_vector(3 downto 0);
   signal bcd1 : std_logic_vector(3 downto 0);
   signal bcd2 : std_logic_vector(3 downto 0);
   signal bcd3 : std_logic_vector(3 downto 0);
   signal bcd4 : std_logic_vector(3 downto 0);
   signal is_neg : std_logic;
   signal ready : std_logic;

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: binary_bcd PORT MAP (
          clk => clk,
          reset => reset,
          binary_in => binary_in,
          bcd0 => bcd0,
          bcd1 => bcd1,
          bcd2 => bcd2,
          bcd3 => bcd3,
          bcd4 => bcd4,
          is_neg => is_neg,
          ready => ready
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
		
		reset <= '1';
		binary_in <= "1110111100011111"; -- -4321
		wait for clk_period;
		reset <= '0';		
		wait for 200 ns;

		reset <= '1';
		binary_in <= "0000010011010010"; -- 1234
		wait for clk_period;
		reset <= '0';
		wait for 200 ns;
		
		reset <= '1';
		binary_in <= "0111101101000010"; -- 31554
		wait for clk_period;
		reset <= '0';
		wait for 200 ns;
		
		reset <= '1';
		binary_in <= "1000010010111110"; -- -31554
		wait for clk_period;
		reset <= '0';
		wait for 200 ns;
		
		reset <= '1';
		binary_in <= "0000000101000000"; -- 320
		wait for clk_period;
		reset <= '0';
		wait for 200 ns;
		
      wait for clk_period*10;

      -- insert stimulus here 

      wait;
   end process;

END;
