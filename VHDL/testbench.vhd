library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity my_tb is	-- empty entity for test_banch is just for standard
end my_tb;

architecture beh of my_tb is
	component GEN_CONV_CODE is
		port (
			x	:	in std_ulogic;
			a_k	:	out std_ulogic;
			c_k :	out std_ulogic;
			clk	:	in std_ulogic;
			rst	:	in std_ulogic
		);
	end component GEN_CONV_CODE;

	signal x_tb		: std_ulogic := '0';
	signal clk_tb	: std_ulogic := '0';
	signal rst_tb	: std_ulogic := '1';

begin

	clk_tb <= not clk_tb after 1 ns;

	i_DUT: GEN_CONV_CODE
		port map (
			x => x_tb,
			a_k => open,
			c_k => open,
			clk => clk_tb,
			rst => rst_tb
			);
		
		drive_p: process
			begin
			-- test reset
				rst_tb <= '1';
				wait for 8 ns;
				rst_tb <= '0';
				wait for 8 ns;
			-- test sequence "1111111111111..."
				x_tb <= '1';
				wait for 32 ns;

			-- test sequence "1010101010101..."
				x_tb <= '0';
				wait for 1 ns;
				rst_tb <= '1';
				wait for 8 ns;
				rst_tb <= '0';
				wait for 8 ns;
				for i in 0 to 31 loop
					x_tb <= not x_tb;
					wait for 2 ns;
				end loop;
				x_tb <= not x_tb after 2 ns;

	end process;
end beh;