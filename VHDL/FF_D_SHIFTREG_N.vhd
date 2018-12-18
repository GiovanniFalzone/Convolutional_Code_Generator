library IEEE;
use IEEE.std_logic_1164.all;

entity FF_D_SHIFTREG_N is
	generic (Nbit : positive := 8);
	port(
			d : in std_ulogic;
			q : out std_ulogic_vector(0 to Nbit - 1);	-- output dello stato
			clk : in std_ulogic;
			rst : in std_ulogic
		);
end FF_D_SHIFTREG_N;

architecture rtl of FF_D_SHIFTREG_N is
	component FF_D
	port (
		d	:	in std_ulogic;
		q	:	out std_ulogic;
		clk	:	in std_ulogic;
		rst	:	in std_ulogic
	);
	end component FF_D;

	signal wire : std_ulogic_vector(0 to Nbit - 2);

begin
-- generation il primo FFD è connesso all'ingresso, gli altri hanno come ingresso
-- l'output dello stadio precedente, l'output di ogni stadio è riportato come output del modulo
	GEN: for i in 0 to Nbit-1  generate
		FIRST: if i = 0 generate
			ff_d_F : FF_D port map(d, wire(i), clk, rst);
			q(i) <= wire(i);
		end generate FIRST;

		MIDDLE: if i > 0 and i < Nbit-1 generate
			ff_d_M : FF_D port map(wire(i-1), wire(i), clk, rst);
			q(i) <= wire(i);
		end generate MIDDLE;

		LAST: if i = Nbit-1 generate
			ff_d_L : FF_D port map(wire(i-1), q(i), clk, rst);
		end generate LAST;
	end generate GEN;
end rtl;