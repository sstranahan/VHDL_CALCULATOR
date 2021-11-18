
-- NOTES:
-- 250 ns required between new inputs

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity alu is
	port(
		A      : in  std_logic_vector(7 downto 0);
		B      : in  std_logic_vector(7 downto 0);
		OP_SEL : in  std_logic_vector(3 downto 0);
 		CLK    : in  std_logic;
		enable : in  std_logic;
		ready  : out std_logic;
		O      : out std_logic_vector(15 downto 0)
	);
end alu;

architecture Behavioral of alu is
signal ones : std_logic_vector(7 downto 0) := "11111111";
begin
	process(CLK, A, B, enable)
	begin
		ready <= '0';
		if (rising_edge(CLK)) then
			if (enable = '1') then

			case OP_SEL is
				when "0000" =>
					O <= std_logic_vector(resize((signed(A) + signed(B)), 16));
				when "0001" =>
					O <= std_logic_vector(resize((signed(A) - signed(B)), 16));
				when "0010" =>
					O <= std_logic_vector(resize(signed(A) * signed(B), 16));
				when "0011" =>
					O <= std_logic_vector(resize(signed(A) * signed(ones), 16));
				when "0100" =>
					O <= std_logic_vector(resize(signed(A) * signed(A), 16));
				when "0101" =>
					O <= std_logic_vector(resize(signed(A) * 2, 16));
				when "0110" =>
					O <= std_logic_vector(resize(signed(A) AND signed(B), 16));
				when "0111" =>
					O <= std_logic_vector(resize(signed(A) OR signed(B), 16));
				
				when "1000" =>
					O <= std_logic_vector(resize(signed(A) NAND signed(B), 16));
				when "1001" =>
					O <= std_logic_vector(resize(signed(A) NOR signed(B), 16));
				when "1010" =>
					O <= std_logic_vector(resize(signed(A) XOR signed(B), 16));
				when "1011" =>
					O <= std_logic_vector(resize(signed(A) + "00000001", 16));
				
				when "1100" =>
					O <= std_logic_vector(resize(signed(A) - "00000001", 16));
				when "1101" =>
					O <= std_logic_vector(resize(shift_left(signed(A),1), 16));
				when "1110" =>
					O <= std_logic_vector(resize(shift_right(unsigned(A),1), 16));
				when "1111" =>
					O <= std_logic_vector(resize(shift_right(signed(A),1), 16));
				when others => O <= "1111111111111111"; -- Error state	
			end case;
				ready <= '1';
			else
				ready <= '0';
			end if;
		end if;
	end process;
end Behavioral;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
 
entity binary_bcd is
    generic(N: positive := 16);
    port(
        clk, reset: in std_logic;
        binary_in: in std_logic_vector(N-1 downto 0);
        bcd0, bcd1, bcd2, bcd3, bcd4: out std_logic_vector(3 downto 0);
		  is_neg, ready: out std_logic
    );
end binary_bcd ;
  
architecture Behavioral of binary_bcd is
    type states is (start, shift, done);
    signal state, state_next: states;
 
    signal binary, binary_next: std_logic_vector(N-1 downto 0);
    signal bcds, bcds_reg, bcds_next: std_logic_vector(19 downto 0);
    -- output register keep output constant during conversion
    signal bcds_out_reg, bcds_out_reg_next: std_logic_vector(19 downto 0);
    -- need to keep track of shifts
    signal shift_counter, shift_counter_next: natural range 0 to N;
	 signal binary_temp: std_logic_vector(N-1 downto 0);
	 signal temp_digit: std_logic;
begin
 
    process(clk, reset)
    begin
        if reset = '1' then
            binary <= (others => '0');
            bcds <= (others => '0');
            state <= start;
            bcds_out_reg <= (others => '0');
            shift_counter <= 0;
        elsif rising_edge(clk) then
            binary <= binary_next;
            bcds <= bcds_next;
            state <= state_next;
            bcds_out_reg <= bcds_out_reg_next;
            shift_counter <= shift_counter_next;
        end if;
    end process;
 
    convert:
    process(state, binary, binary_in, bcds, bcds_reg, shift_counter)
    begin
		  	 
		  if (binary_in(15) = '1') then
				is_neg <= '1';
				binary_temp <= (NOT binary_in) + "0000000000000001";
		  else
				is_neg <= '0';
				binary_temp <= binary_in;
		  end if;
	 
        state_next <= state;
		  
		  if state_next = start then
			  ready <= '1';
		  else
			  ready <= '0';
		  end if;
		  
        bcds_next <= bcds;
        binary_next <= binary;
        shift_counter_next <= shift_counter;
 
        case state is
            when start =>
                state_next <= shift;
                binary_next <= binary_temp;
                bcds_next <= (others => '0');
                shift_counter_next <= 0;
            when shift =>
                if shift_counter = N then
                    state_next <= done;
                else
                    binary_next <= binary(N-2 downto 0) & 'L';
                    bcds_next <= bcds_reg(18 downto 0) & binary(N-1);
                    shift_counter_next <= shift_counter + 1;
                end if;
            when done =>
                state_next <= start;
        end case;
    end process;
 
    bcds_reg(19 downto 16) <= bcds(19 downto 16) + 3 when bcds(19 downto 16) > 4 else
                              bcds(19 downto 16);
    bcds_reg(15 downto 12) <= bcds(15 downto 12) + 3 when bcds(15 downto 12) > 4 else
                              bcds(15 downto 12);
    bcds_reg(11 downto 8) <= bcds(11 downto 8) + 3 when bcds(11 downto 8) > 4 else
                             bcds(11 downto 8);
    bcds_reg(7 downto 4) <= bcds(7 downto 4) + 3 when bcds(7 downto 4) > 4 else
                            bcds(7 downto 4);
    bcds_reg(3 downto 0) <= bcds(3 downto 0) + 3 when bcds(3 downto 0) > 4 else
                            bcds(3 downto 0);
	
    bcds_out_reg_next <= bcds when state = done else
                         bcds_out_reg;
 
    bcd4 <= bcds_out_reg(19 downto 16);
    bcd3 <= bcds_out_reg(15 downto 12);
    bcd2 <= bcds_out_reg(11 downto 8);
    bcd1 <= bcds_out_reg(7 downto 4);
    bcd0 <= bcds_out_reg(3 downto 0);
	 
end Behavioral;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity bcd_seg7 is
port( bcd        : in  std_logic_vector(3 downto 0);
		enable     : in  std_logic;
		clk        : in  std_logic;   
		is_neg_in  : in  std_logic;
		is_neg_out : out std_logic;
	   seg7_out   : out std_logic_vector(6 downto 0));
end bcd_seg7;

architecture Behavioral of bcd_seg7 is
	begin
		process(BCD, clk, enable)
		begin
			if (rising_edge(clk) AND enable = '1') then
				
				if (is_neg_in = '1') then
					is_neg_out <= '1';
				else
					is_neg_out <= '0';
				end if;
				
				case BCD is
					when "0000" => seg7_out <= "0111111";
					when "0001" => seg7_out <= "0000110";
					when "0010" => seg7_out <= "1011011";
					when "0011" => seg7_out <= "1001111";
					when "0100" => seg7_out <= "1100110";
					when "0101" => seg7_out <= "1101101";
					when "0110" => seg7_out <= "1111101";
					when "0111" => seg7_out <= "0000111";
					when "1000" => seg7_out <= "1111111";
					when "1001" => seg7_out <= "1101111";
					when others => null;
				end case;
				
			end if;	
		end process;
end Behavioral;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity vhdl_calc is 
port( A			: in  STD_LOGIC_VECTOR (7 downto 0);
		B			: in  STD_LOGIC_VECTOR (7 downto 0);
		OP_SEL	: in  STD_LOGIC_VECTOR (3 downto 0);
		CLK		: in  STD_LOGIC;
		ENABLE	: in  STD_LOGIC;
		IS_NEG	: out STD_LOGIC;
		SEG7_4	: out STD_LOGIC_VECTOR (6 downto 0);
		SEG7_3	: out STD_LOGIC_VECTOR (6 downto 0);
		SEG7_2	: out STD_LOGIC_VECTOR (6 downto 0);
		SEG7_1	: out STD_LOGIC_VECTOR (6 downto 0);
		SEG7_0	: out STD_LOGIC_VECTOR (6 downto 0)
);
end vhdl_calc;

architecture Structural of vhdl_calc is

component alu is
	port(
		A      : in  std_logic_vector(7 downto 0);
		B      : in  std_logic_vector(7 downto 0);
		OP_SEL : in  std_logic_vector(3 downto 0);
 		CLK    : in  std_logic;
		enable : in  std_logic;
		ready  : out std_logic;
		O      : out std_logic_vector(15 downto 0)
	);
end component;

component binary_bcd is
    generic(N: positive := 16);
    port(
        clk, reset: in std_logic;
        binary_in: in std_logic_vector(N-1 downto 0);
        bcd0, bcd1, bcd2, bcd3, bcd4: out std_logic_vector(3 downto 0);
		  is_neg, ready: out std_logic
    );
end  component;

component bcd_seg7 is
port( bcd        : in  std_logic_vector(3 downto 0);
		enable     : in  std_logic;
		clk        : in  std_logic;   
		is_neg_in  : in  std_logic;
		is_neg_out : out std_logic;
	   seg7_out   : out std_logic_vector(6 downto 0)
);
end component;

signal alu_out    : std_logic_vector (15 downto 0);
signal alu_rdy    : std_logic;

signal bcd_out_4  : std_logic_vector (3 downto 0);
signal bcd_out_3  : std_logic_vector (3 downto 0);
signal bcd_out_2  : std_logic_vector (3 downto 0);
signal bcd_out_1  : std_logic_vector (3 downto 0);
signal bcd_out_0  : std_logic_vector (3 downto 0);

signal bcd_is_neg : std_logic;
signal bcd_rdy    : std_logic;

signal is_neg_fin0 : std_logic;
signal is_neg_fin1 : std_logic;
signal is_neg_fin2 : std_logic;
signal is_neg_fin3 : std_logic;
signal is_neg_fin4 : std_logic; 

begin

alu1   : alu
	port map(
		A 				=> A,
		B 				=> B,
		OP_SEL 		=> OP_SEL,
		CLK 			=> CLK,
		ENABLE 		=> ENABLE,
		READY 		=> ALU_RDY,
		O 				=> ALU_OUT
	);
	
bcd1   : binary_bcd
	port map(
		CLK			=> CLK,
		RESET			=>	ALU_RDY,
		BINARY_IN	=> ALU_OUT,
		BCD0			=>	BCD_OUT_0,
		BCD1			=> BCD_OUT_1,
		BCD2			=>	BCD_OUT_2,
		BCD3			=>	BCD_OUT_3,
		BCD4			=>	BCD_OUT_4,
		IS_NEG		=> BCD_IS_NEG,
		READY			=>	BCD_RDY
	);

seg7_i0 : bcd_seg7	
	port map(
		BCD			=> BCD_OUT_0,
		ENABLE		=> BCD_RDY,
		CLK			=>	CLK,
		IS_NEG_IN	=>	BCD_IS_NEG,
		IS_NEG_OUT	=>	IS_NEG,
		SEG7_OUT		=>	SEG7_0
	);
	
seg7_i1 : bcd_seg7	
	port map(
		BCD			=> BCD_OUT_1,
		ENABLE		=> BCD_RDY,
		CLK			=>	CLK,
		IS_NEG_IN	=>	BCD_IS_NEG,
		IS_NEG_OUT	=>	IS_NEG_FIN1,
		SEG7_OUT		=>	SEG7_1
	);

seg7_i2 : bcd_seg7	
	port map(
		BCD			=> BCD_OUT_2,
		ENABLE		=> BCD_RDY,
		CLK			=>	CLK,
		IS_NEG_IN	=>	BCD_IS_NEG,
		IS_NEG_OUT	=>	IS_NEG_FIN2,
		SEG7_OUT		=>	SEG7_2
	);

seg7_i3 : bcd_seg7	
	port map(
		BCD			=> BCD_OUT_3,
		ENABLE		=> BCD_RDY,
		CLK			=>	CLK,
		IS_NEG_IN	=>	BCD_IS_NEG,
		IS_NEG_OUT	=>	IS_NEG_FIN3,
		SEG7_OUT		=>	SEG7_3
	);

seg7_i4 : bcd_seg7	
	port map(
		BCD			=> BCD_OUT_4,
		ENABLE		=> BCD_RDY,
		CLK			=>	CLK,
		IS_NEG_IN	=>	BCD_IS_NEG,
		IS_NEG_OUT	=>	IS_NEG_FIN4,
		SEG7_OUT		=>	SEG7_4
	);	
	

	
end Structural;
